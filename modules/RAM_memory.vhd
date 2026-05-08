----------------------------------------------------------------------------------
-- Company: Polytechnic University of Cartagena
-- Engineer: Luis Carretero Lopez
-- 
-- Create Date:    09:34:11 03/24/2026 
-- Design Name: 
-- Module Name:    RAM_memory - Behavioral 
-- Project Name:  RAM Memory
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

entity RAM_memory is
    Generic (   addr_width : integer := 7; -- 7 bits for 128 words
                data_width : integer := 12 -- 12 bits for RGB color
                );
    Port ( clk : in STD_LOGIC;
           addr : in unsigned(addr_width-1 downto 0); -- addr_width bits for 2^addr_width words
           write_enable : in STD_LOGIC;
           data_in : in unsigned(data_width-1 downto 0);
           data_o : out unsigned(data_width-1 downto 0));
end RAM_memory;

architecture Behavioral of RAM_memory is
    type RAM_type is array (0 to 2**addr_width - 1) of unsigned(data_width-1 downto 0);
    signal RAM : RAM_type := (others => (others => '0')); -- Initialize RAM with zeros

begin
    process(clk)
    begin
        if (clk'event and clk = '1') then
            if write_enable = '1' then
                RAM(to_integer(addr)) <= data_in; -- Write data to ROM at the specified address
            end if;
        end if;
    end process;

    -- Asynchronous read process
    data_o <= RAM(to_integer(addr)); -- Read data from ROM at the specified address
end Behavioral;

