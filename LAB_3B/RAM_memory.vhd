----------------------------------------------------------------------------------
-- Company: Polytechnic University of Cartagena
-- Engineer: Luis Carretero Lopez
--
-- Module Name: RAM_memory - Behavioral
-- Description: Synchronous read/write single-port RAM.
--              On each rising edge: if write_enable='1', data_in is written to
--              mem(addr). data_o always reflects mem(addr) (read-first mode).
--              ISE infers BRAM from this pattern.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM_memory is
    Generic (
        addr_width : integer := 8;   -- 8 bits → 256 words (16x16)
        data_width : integer := 12   -- 12 bits RGB
    );
    Port (
        clk          : in  STD_LOGIC;
        addr         : in  unsigned(addr_width-1 downto 0);
        write_enable : in  STD_LOGIC;
        data_in      : in  unsigned(data_width-1 downto 0);
        data_o       : out unsigned(data_width-1 downto 0)
    );
end RAM_memory;

architecture Behavioral of RAM_memory is
    type ram_t is array (0 to 2**addr_width - 1) of unsigned(data_width-1 downto 0);
    signal mem : ram_t := (others => (others => '0')); -- initialised to black
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                mem(to_integer(addr)) <= data_in;
            end if;
            data_o <= mem(to_integer(addr)); -- synchronous read (read-first)
        end if;
    end process;
end Behavioral;
