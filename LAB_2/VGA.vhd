----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:45:35 02/24/2026 
-- Design Name: 
-- Module Name:    VGA - Behavioral 
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA is
    Port ( enable : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           sync_h : out  STD_LOGIC;
           sync_v : out  STD_LOGIC;
           inhibColor : out  STD_LOGIC);
end VGA;

architecture Behavioral of VGA is

    signal inh_h, inh_v : STD_LOGIC;
    signal pixel, line : unsigned(9 downto 0);

begin
process(clk, reset) -- Pixel counter
        begin
            if reset = '1' then
                pixel <= (others => '0');
            elsif (clk'event and clk = '1') then
                if enable = '1' then
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
                if enable = '1' then
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
    inhibColor <= inh_h or inh_v;


end Behavioral;

