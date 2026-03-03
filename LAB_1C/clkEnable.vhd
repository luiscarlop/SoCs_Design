----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:51:52 03/03/2026 
-- Design Name: 
-- Module Name:    clkEnable - Behavioral 
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

entity clkEnable is
    generic (   N : positive := 3;
                LIMIT : positive := 8);

    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : out  STD_LOGIC);
end clkEnable;

architecture Behavioral of clkEnable is
    signal clk_div : unsigned(N-1 downto 0);
begin
process(clk, reset) -- Clock prescaler
        begin
            if reset = '1' then
                clk_div <= (others => '0');
            elsif (clk'event and clk = '1') then
                if clk_div = LIMIT-1 then
                    clk_div <= (others => '0');
                else
                    clk_div <= clk_div + 1;
                end if;
            end if;
        end process;

    enable <= '1' when clk_div = LIMIT-1 else '0';

end Behavioral;

