----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:16:20 02/20/2026 
-- Design Name: 
-- Module Name:    sine_rom - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sine_rom is
    Port ( clk : in  STD_LOGIC;
           addr_in : in  STD_LOGIC_VECTOR (7 downto 0);
           sine_out : out  STD_LOGIC_VECTOR (7 downto 0));
end sine_rom;

architecture Behavioral of sine_rom is

begin


end Behavioral;

