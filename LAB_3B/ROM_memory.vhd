----------------------------------------------------------------------------------
-- Company: Polytechnic University of Cartagena
-- Engineer: Luis Carretero Lopez
-- 
-- Create Date:    09:34:11 03/24/2026 
-- Design Name: 
-- Module Name:    ROM_memory - Behavioral 
-- Project Name:  ROM Memory
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity ROM_memory is
    Generic (   SPRITE_ID : integer := 0;
                addr_width : integer := 7; -- 7 bits for 128 words
                data_width : integer := 12 -- 12 bits for RGB color
                );
    Port ( clk : in STD_LOGIC;
           addr : in unsigned(addr_width-1 downto 0); -- addr_width bits for 2^addr_width words
           data_o : out unsigned(data_width-1 downto 0));
end ROM_memory;

architecture Behavioral of ROM_memory is
    constant ROM : sprite_t := SPRITE_BANK(SPRITE_ID);

begin
    process(clk)
    begin
        if (clk'event and clk = '1') then
            data_o <= ROM(to_integer(addr));
        end if;
    end process;
end Behavioral;
