----------------------------------------------------------------------------------
-- Company: Polytechnic University of Cartagena
-- Engineer: Luis Carretero Lopez
-- 
-- Create Date:    09:33:23 05/12/2026 
-- Design Name: 
-- Module Name:    TOP_CoreGenerator - Behavioral 
-- Project Name:   ROM Pixel Art
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.ROM_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


-- BTN encoding:
-- 0001: BTNL
-- 0010: BTNU
-- 0100: BTNR
-- 1000: BTND

-- color_in encoding:
-- 000: black
-- 001: blue
-- 010: green
-- 011: cyan
-- 100: red
-- 101: magenta
-- 110: yellow
-- 111: white

entity TOP_CoreGenerator is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           show_image : in  STD_LOGIC;
           BTN : in  STD_LOGIC_VECTOR(3 downto 0);
           color_in : in  STD_LOGIC_VECTOR (2 downto 0); 
           sync_h : out  STD_LOGIC;
           sync_v : out  STD_LOGIC;
           image_out : out  STD_LOGIC_VECTOR (11 downto 0)
           );
end TOP_CoreGenerator;

architecture Behavioral of TOP_CoreGenerator is
    component VGA
        Generic (
            G_EXPOSE_PIXEL : boolean := false;
            G_EXPOSE_LINE  : boolean := false
        );
        Port ( enable : in  STD_LOGIC;
               clk : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               sync_h : out  STD_LOGIC;
               sync_v : out  STD_LOGIC;
               inhibColor : out  STD_LOGIC;
               pixel_o : out unsigned(9 downto 0);
               line_o : out unsigned(9 downto 0));
    end component;

    component movement_stm
        generic (
            CLK_FREQ : integer := 100000000 -- 100 MHz
        );
        Port ( clk : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               btn_forward : in  STD_LOGIC;
               btn_backward : in  STD_LOGIC;
               step_size : out  unsigned(4 downto 0);
               move_forward : out  STD_LOGIC;
               move_backward : out  STD_LOGIC);
    end component;

    COMPONENT ROM_memory
        PORT (
            clka  : IN  STD_LOGIC;
            ena   : IN  STD_LOGIC;
            addra : IN  STD_LOGIC_VECTOR(13 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    signal CLKIN1 : STD_LOGIC;
    signal CLKOUT0 : STD_LOGIC;
    signal CLKFBIN : STD_LOGIC;
    signal CLKFBOUT : STD_LOGIC;
    signal clk_25MHz : STD_LOGIC;
    signal inhibColor : STD_LOGIC;
    signal sprite : t_window;
    signal pixel_o : unsigned(9 downto 0);
    signal line_o : unsigned(9 downto 0);
    signal rom_addr : unsigned(13 downto 0);
    signal rom_data : STD_LOGIC_VECTOR(11 downto 0);

    signal step_size_x, step_size_y : unsigned(4 downto 0);

    -- Current sprite position
    signal x0_pos : unsigned(9 downto 0) := to_unsigned(C_CENTER.x0, 10); -- center x
    signal y0_pos : unsigned(9 downto 0) := to_unsigned(C_CENTER.y0, 10); -- center y
    signal x1_pos : unsigned(9 downto 0) := to_unsigned(C_CENTER.x1, 10); -- center x + sprite width
    signal y1_pos : unsigned(9 downto 0) := to_unsigned(C_CENTER.y1, 10); -- center y + sprite height

    -- Direction signals
    signal move_right, move_left, move_down, move_up : STD_LOGIC;

    constant C_BLACK  : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    constant C_BLUE   : STD_LOGIC_VECTOR(11 downto 0) := "000000000111";
    constant C_GREEN  : STD_LOGIC_VECTOR(11 downto 0) := "000000111000";
    constant C_CYAN   : STD_LOGIC_VECTOR(11 downto 0) := "000000111111";
    constant C_RED    : STD_LOGIC_VECTOR(11 downto 0) := "111000000000";
    constant C_MAGENTA: STD_LOGIC_VECTOR(11 downto 0) := "111000000111";
    constant C_YELLOW : STD_LOGIC_VECTOR(11 downto 0) := "111000111000";
    constant C_WHITE  : STD_LOGIC_VECTOR(11 downto 0) := (others => '1');

    -- Bounds for the screen
    constant X_MIN : unsigned(9 downto 0) := to_unsigned(0, 10);
    constant X_MAX : unsigned(9 downto 0) := to_unsigned(639, 10);
    constant Y_MIN : unsigned(9 downto 0) := to_unsigned(0, 10);
    constant Y_MAX : unsigned(9 downto 0) := to_unsigned(479, 10);

begin
    -- Modules --
    Module_MMCM: MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED",
        CLKFBOUT_MULT_F => 12.0,
        CLKFBOUT_PHASE => 0.0,
        CLKIN1_PERIOD => 10.0,
        CLKOUT0_DIVIDE_F => 48.0,
        CLKOUT0_PHASE => 0.0,
        CLKOUT4_CASCADE => FALSE,
        DIVCLK_DIVIDE => 1,
        REF_JITTER1 => 0.0,
        STARTUP_WAIT => FALSE
    )
    port map (
        CLKOUT0 => CLKOUT0,
        CLKOUT0B => open,
        CLKOUT1 => open,
        CLKOUT1B => open,
        CLKOUT2 => open,
        CLKOUT2B => open,
        CLKOUT3 => open,
        CLKOUT3B => open,
        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKOUT6 => open,
        CLKFBOUT => CLKFBOUT,
        CLKFBOUTB => open,
        LOCKED => open,
        CLKIN1 => CLKIN1,
        PWRDWN => '0',
        RST => reset,
        CLKFBIN => CLKFBIN
    );

    IBUFG_inst : IBUFG
    port map (
        O => CLKIN1,
        I => clk
    );

    BUFG_inst_clkout0 : BUFG
    port map (
        O => clk_25MHz,
        I => CLKOUT0
    );

    BUFG_inst_clkfbout : BUFG
    port map (
        O => CLKFBIN,
        I => CLKFBOUT
    );

    Module_VGA: VGA
        generic map (
            G_EXPOSE_PIXEL => TRUE,
            G_EXPOSE_LINE => TRUE
        )
        Port map (
            enable => '1',
            clk => clk_25MHz,
            reset => reset,
            sync_h => sync_h,
            sync_v => sync_v,
            inhibColor => inhibColor,
            pixel_o => pixel_o,
            line_o => line_o
        );

    Module_ROM: ROM_memory
        PORT MAP (
            clka  => clk_25MHz,
            ena   => '1',
            addra => std_logic_vector(rom_addr),
            douta => rom_data
        );

    Module_movement_stm_x: movement_stm
        generic map (
            CLK_FREQ => 25000000 -- 25 MHz
        )
        port map (
            clk => clk_25MHz,
            reset => reset,
            btn_forward => BTN(2), -- BTNR
            btn_backward => BTN(0), -- BTNL
            step_size => step_size_x, 
            move_forward => move_right,
            move_backward => move_left
        );
    
    Module_movement_stm_y: movement_stm
        generic map (
            CLK_FREQ => 25000000 -- 25 MHz
        )
        port map (
            clk => clk_25MHz,
            reset => reset,
            btn_forward => BTN(3), -- BTND
            btn_backward => BTN(1), -- BTNU
            step_size => step_size_y, 
            move_forward => move_down,
            move_backward => move_up
        );

    -- Processes --
    rom_addr <= to_unsigned(to_integer(line_o - y0_pos) * 100 +
                            to_integer((pixel_o + 2) - x0_pos), 14)
        when pixel_o + 2 >= x0_pos and pixel_o + 2 <= x1_pos and
             line_o  >= y0_pos     and line_o  <= y1_pos
        else (others => '0');

    movement_process: process(clk_25MHz, reset)
    begin
        if reset = '1' then
            x0_pos <= to_unsigned(C_CENTER.x0, 10);
            y0_pos <= to_unsigned(C_CENTER.y0, 10);
            x1_pos <= to_unsigned(C_CENTER.x1, 10);
            y1_pos <= to_unsigned(C_CENTER.y1, 10);
        elsif (clk_25MHz'event and clk_25MHz = '1') then
            if move_right = '1' and x1_pos < X_MAX + step_size_x then
                x0_pos <= x0_pos + step_size_x;
                x1_pos <= x1_pos + step_size_x;
            elsif move_left = '1' and x0_pos > step_size_x then
                x0_pos <= x0_pos - step_size_x;
                x1_pos <= x1_pos - step_size_x;
            end if;

            if move_down = '1' and y1_pos < Y_MAX + step_size_y then
                y0_pos <= y0_pos + step_size_y;
                y1_pos <= y1_pos + step_size_y;
            elsif move_up = '1' and y0_pos > step_size_y then
                y0_pos <= y0_pos - step_size_y;
                y1_pos <= y1_pos - step_size_y;
            end if;
        end if;
    end process;

    image_out_process: process(clk_25MHz, reset)
        begin
            if reset = '1' then
                image_out <= C_BLACK;
            elsif (clk_25MHz'event and clk_25MHz = '1') then
                if inhibColor = '1' then
                    image_out <= C_BLACK;
                else
                    if  pixel_o >= x0_pos and pixel_o <= x1_pos and 
                        line_o >= y0_pos and line_o <= y1_pos then
                            if show_image = '0' then
                                case color_in is
                                    when "001" => image_out <= C_BLUE;
                                    when "010" => image_out <= C_GREEN;
                                    when "011" => image_out <= C_CYAN;
                                    when "100" => image_out <= C_RED;
                                    when "101" => image_out <= C_MAGENTA;
                                    when "110" => image_out <= C_YELLOW;
                                    when "111" => image_out <= C_WHITE;
                                    when others => image_out <= C_BLACK;
                                end case;
                            else
                                image_out <= rom_data;
                            end if;
                    else
                        image_out <= C_BLACK;
                    end if;
                end if;
            end if;
        end process;
end Behavioral;