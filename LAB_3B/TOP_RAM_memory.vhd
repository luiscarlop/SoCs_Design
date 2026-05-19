----------------------------------------------------------------------------------
-- Company: Polytechnic University of Cartagena
-- Engineer: Luis Carretero Lopez
-- 
-- Create Date:    09:33:23 03/24/2026 
-- Design Name: 
-- Module Name:    RAM_memory - Behavioral 
-- Project Name:   RAM Memory
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TOP_RAM_memory is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           btn : in STD_LOGIC;
           row_select : in STD_LOGIC_VECTOR(3 downto 0);
           col_select : in STD_LOGIC_VECTOR(3 downto 0);
           color_in : in STD_LOGIC_VECTOR(11 downto 0);
           sync_h : out  STD_LOGIC;
           sync_v : out  STD_LOGIC;
           rgb_out : out  STD_LOGIC_VECTOR (11 downto 0)
           );
end TOP_RAM_memory;

architecture Behavioral of TOP_RAM_memory is
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

    component RAM_memory
        Generic (addr_width : integer := 7; -- 7 bits for 128 words (9x9 sprite)
                data_width : integer := 12 -- 12 bits for RGB color
                );
        Port ( clk : in STD_LOGIC;
               addr : in unsigned(addr_width-1 downto 0); -- addr_width bits for 2^addr_width words
               write_enable : in STD_LOGIC;
               data_in : in unsigned(data_width-1 downto 0);
               data_o : out unsigned(data_width-1 downto 0));
    end component;

    component antiBouncesSTM
        generic (
            STABILIZATION_TIME : integer := 500000
        );
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               input : in STD_LOGIC;
               output : out STD_LOGIC);
    end component;

    signal CLKIN1 : STD_LOGIC;
    signal CLKOUT0 : STD_LOGIC;
    signal CLKFBIN : STD_LOGIC;
    signal CLKFBOUT : STD_LOGIC;
    signal clk_25MHz : STD_LOGIC;
    signal inhibColor : STD_LOGIC;
    signal pixel_o : unsigned(9 downto 0);
    signal line_o : unsigned(9 downto 0);

    signal ram_addr, write_addr : unsigned(6 downto 0); -- 7 bits for 128 words 
    signal ram_addr_mux : unsigned(6 downto 0);

    signal ram_data : unsigned(11 downto 0);

    signal write_enable_debounced : STD_LOGIC;

    constant C_BLACK  : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    constant C_WHITE  : STD_LOGIC_VECTOR(11 downto 0) := (others => '1');

begin
    Module_MMCM: MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
        CLKFBOUT_MULT_F => 12.0,   -- Multiply value for all CLKOUT (2.000-64.000). VCO = 100MHz * 12 = 1200 MHz
        CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
        CLKIN1_PERIOD => 10.0,     -- Input clock period in ns (100 MHz = 10.0 ns).
        -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        CLKOUT0_DIVIDE_F => 48.0,   -- 1200 MHz / 48 = 25 MHz
        CLKOUT0_PHASE => 0.0,

        CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
        REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
        STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
    )
    port map (
        -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0 => CLKOUT0,     -- 1-bit output: CLKOUT0  (25 MHz -> clk_25MHz)
        CLKOUT0B => open,       -- 1-bit output: Inverted CLKOUT0 (not used)
        CLKOUT1 => open,     -- 1-bit output: CLKOUT1  (100 MHz -> clk_100MHz)
        CLKOUT1B => open,       -- 1-bit output: Inverted CLKOUT1 (not used)
        CLKOUT2 => open,        -- 1-bit output: CLKOUT2  (not used)
        CLKOUT2B => open,       -- 1-bit output: Inverted CLKOUT2 (not used)
        CLKOUT3 => open,        -- 1-bit output: CLKOUT3  (not used)
        CLKOUT3B => open,       -- 1-bit output: Inverted CLKOUT3 (not used)
        CLKOUT4 => open,        -- 1-bit output: CLKOUT4  (not used)
        CLKOUT5 => open,        -- 1-bit output: CLKOUT5 (not used)
        CLKOUT6 => open,        -- 1-bit output: CLKOUT6 (not used)
        -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
        CLKFBOUT => CLKFBOUT,   -- 1-bit output: Feedback clock
        CLKFBOUTB => open,      -- 1-bit output: Inverted CLKFBOUT (not used)
        -- Status Ports: 1-bit (each) output: MMCM status ports
        LOCKED => open,         -- 1-bit output: LOCK (not used)
        -- Clock Inputs: 1-bit (each) input: Clock input
        CLKIN1 => CLKIN1,       -- 1-bit input: Clock
        -- Control Ports: 1-bit (each) input: MMCM control ports
        PWRDWN => '0',          -- 1-bit input: Power-down (tied low)
        RST => reset,           -- 1-bit input: Reset
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN => CLKFBIN      -- 1-bit input: Feedback clock
    );
        
    IBUFG_inst : IBUFG
    port map (
        O => CLKIN1, -- Clock buffer output
        I => clk  -- Clock buffer input (connect directly to top-level port)
    );

    BUFG_inst_clkout0 : BUFG
    port map (
        O => clk_25MHz, -- 1-bit output: Clock output
        I => CLKOUT0  -- 1-bit input: Clock input
    );

    BUFG_inst_clkfbout : BUFG
    port map (
        O => CLKFBIN, -- 1-bit output: Clock output
        I => CLKFBOUT  -- 1-bit input: Clock input
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

    Module_RAM: RAM_memory
        Generic map (addr_width => 7)
        Port map (
            clk    => clk_25MHz,
            addr   => ram_addr_mux,
            write_enable => write_enable_debounced, -- Use button to enable writing to RAM
            data_in => unsigned(color_in), -- Data to write into RAM (from color_in)
            data_o => ram_data
        );

    Module_antiBouncesSTM: antiBouncesSTM
        Generic map (
            STABILIZATION_TIME => 125000 -- Adjust as needed for button debounce time (125000 cycles at 25 MHz = 5 ms)
        )
        Port map (
            clk => clk_25MHz,
            reset => reset,
            input => btn,
            output => write_enable_debounced
        );

    --   9x9 sprite centered at (320, 240):
    --     X window: 312..327, Y window: 232..247
    --   2-cycle pipeline (RAM register + rgb_out_process register):
    --     ram_addr pre-fetch starts 2 pixels early (pixel_o - 310)
    --     Guard: pixel_o >= 310 so RAM has data ready at pixel 312
    -- Fetch window [314,322] feeds the 2-cycle pipeline (RAM + rgb_out register).
    -- pixel=323 is still inside the display check [315,323], so we hold the
    -- col-8 address one extra cycle to keep BRAM output stable at edge E(323->324)
    -- and avoid a timing race where rgb_out captures mem[0] (the else default)
    -- instead of the actual col-8 data.
    ram_addr <= to_unsigned(to_integer(line_o - 235) * 9 +
                            to_integer(pixel_o - 314), 7)
        when pixel_o >= 314 and pixel_o <= 322 and
             line_o  >= 235 and line_o  <= 243
        else to_unsigned(to_integer(line_o - 235) * 9 + 8, 7)
        when pixel_o = 323 and
             line_o  >= 235 and line_o  <= 243
        else (others => '0');

    write_addr <= to_unsigned(to_integer(unsigned(row_select)) * 9 +
                            to_integer(unsigned(col_select)), 7);
    
    ram_addr_mux <= write_addr when write_enable_debounced = '1' else ram_addr;

    rgb_out_process: process(clk_25MHz, reset)
        begin
            if reset = '1' then
                rgb_out <= C_BLACK;
            elsif (clk_25MHz'event and clk_25MHz = '1') then
                if inhibColor = '1' then
                    rgb_out <= C_BLACK;
                else
                    if  pixel_o >= 315 and pixel_o <= 323 and
                        line_o  >= 235 and line_o  <= 243 then
                            rgb_out <= std_logic_vector(ram_data);
                    else
                        rgb_out <= C_BLACK;
                    end if;
                end if;
            end if;
        end process;
end Behavioral;
