----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:49:06 02/13/2026 
-- Design Name: 
-- Module Name:    LAB_1A - Behavioral 
-- Project Name: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LAB_1A is
    Port ( rgb_in : in  STD_LOGIC_VECTOR (11 downto 0);
           rgb_out : out  STD_LOGIC_VECTOR (11 downto 0);
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           sync_h : out STD_LOGIC;
           sync_v : out STD_LOGIC);

end LAB_1A;

architecture Behavioral of LAB_1A is
    signal pixel : unsigned(9 downto 0);
    signal line : unsigned(9 downto 0);
    signal color_inhibit : STD_LOGIC;
    signal inh_h : STD_LOGIC;
    signal inh_v : STD_LOGIC;
    -- Clock enable signal for output register
    signal clk_enable : STD_LOGIC;
    signal clk_div : unsigned(1 downto 0);

begin
    process(clk, reset) -- Clock prescaler
        begin
            if reset = '1' then
                clk_div <= (others => '0');
            elsif (clk'event and clk = '1') then
                clk_div <= clk_div + 1;
            end if;
        end process;

    clk_enable <= '1' when clk_div = 3 else '0';

    process(clk, reset) -- Pixel counter
        begin
            if reset = '1' then
                pixel <= (others => '0');
            elsif (clk'event and clk = '1') then
                if clk_enable = '1' then
                    if pixel = 793 then
                        pixel <= (others => '0');
                    else
                        pixel <= pixel + 1;
                    end if;
                end if;
            end if;
        end process;

    process(clk, reset) -- Line counter
        begin
            if reset = '1' then
                line <= (others => '0');
            elsif (clk'event and clk = '1') then
                if clk_enable = '1' then
                    if pixel = 793 then
                        if line = 527 then
                            line <= (others => '0');
                        else
                            line <= line + 1;
                        end if;
                    end if;
                end if;
            end if;
        end process;

    -- Sync signals logic
    sync_h <= '0' when pixel >= 649 and pixel <= 747 else '1';
    sync_v <= '0' when line >= 489 and line <= 491 else '1';

    -- Color inhibit logic
    inh_h <= '1' when (pixel >= 639 and pixel <= 792) else '0';
    inh_v <= '1' when (line >= 479 and line <= 526) else '0';
    color_inhibit <= inh_h or inh_v;

    -- Register for output RGB values
    process(clk)
        begin
            if (clk'event and clk = '1') then
                if clk_enable = '1' then
                    if color_inhibit = '1' then
                        rgb_out <= (others => '0');
                    else
                        rgb_out <= rgb_in;
                    end if;
                end if;
            end if;
        end process;



end Behavioral;

