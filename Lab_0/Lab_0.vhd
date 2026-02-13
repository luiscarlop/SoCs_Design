----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:06:04 02/10/2026 
-- Design Name: 
-- Module Name:    Lab_0 - Behavioral 
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

entity Lab_0 is
    Port ( entrada : in  STD_LOGIC_VECTOR (7 downto 0);
           salida : out  STD_LOGIC_VECTOR (7 downto 0);
			  ciclos : out  STD_LOGIC_VECTOR (7 downto 0);
			  actualiza : in STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC);
end Lab_0;

architecture Behavioral of Lab_0 is
	signal count_aux : unsigned(32 downto 0);
begin
--	process(clk, reset) -- Register
--		begin
--			if reset = '1' then
--				salida <= (others => '0');
--			elsif (clk'event and clk = '1') then
--				if actualiza = '1' then
--					salida <= entrada;
--				end if;
--		end if;
--	end process;

	process(clk, reset) -- Counter
		begin
			if reset = '1' then
				count_aux <= (others => '0');
			elsif (clk'event and clk = '1') then
					count_aux <= count_aux + 1;
			end if;
		end process;
	ciclos <= STD_LOGIC_VECTOR(count_aux(32 downto 25));
end Behavioral;

