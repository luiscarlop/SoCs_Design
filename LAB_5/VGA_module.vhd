----------------------------------------------------------------------------------
-- Company: Polytechnic University of Cartagena
-- Engineer: Luis Carretero Lopez
-- 
-- Create Date:    09:33:46 03/24/2026 
-- Design Name: 
-- Module Name:    VGA_module - Behavioral 
-- Project Name:    VGA Module
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

entity VGA is
    generic (
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
end VGA;

architecture Behavioral of VGA is

    signal inh_h, inh_v : STD_LOGIC;
    signal pixel_cnt, line_cnt : unsigned(9 downto 0);

begin
process(clk, reset)
        begin
            if reset = '1' then
                pixel_cnt <= (others => '0');
            elsif (clk'event and clk = '1') then
                if enable = '1' then
                    if pixel_cnt = 793 then
                        pixel_cnt <= (others => '0');
                    else
                        pixel_cnt <= pixel_cnt + 1;
                    end if;
                end if;
            end if;
        end process;

    process(clk, reset)
        begin
            if reset = '1' then
                line_cnt <= (others => '0');
            elsif (clk'event and clk = '1') then
                if enable = '1' then
                    if pixel_cnt = 793 then
                        if line_cnt = 527 then
                            line_cnt <= (others => '0');
                        else
                            line_cnt <= line_cnt + 1;
                        end if;
                    end if;
                end if;
            end if;
        end process;

    process(clk, reset)
    begin
        if reset = '1' then
            sync_h <= '1';
            sync_v <= '1';
        elsif (clk'event and clk = '1') then
            if pixel_cnt >= 649 and pixel_cnt <= 747 then
                sync_h <= '0';
            else
                sync_h <= '1';
            end if;
            if line_cnt >= 489 and line_cnt <= 491 then
                sync_v <= '0';
            else
                sync_v <= '1';
            end if;
        end if;
    end process;

    inh_h <= '1' when (pixel_cnt >= 640 and pixel_cnt <= 792) else '0';
    inh_v <= '1' when (line_cnt >= 480 and line_cnt <= 526) else '0';
    inhibColor <= inh_h or inh_v;

    pixel_o <= pixel_cnt when G_EXPOSE_PIXEL else (others => '0');
    line_o <= line_cnt when G_EXPOSE_LINE else (others => '0');

end Behavioral;