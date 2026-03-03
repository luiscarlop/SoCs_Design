----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:48:26 02/24/2026 
-- Design Name: 
-- Module Name:    TOP_colorProcessor - Behavioral 
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

entity TOP_colorProcessor is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rgb_in : in  STD_LOGIC_VECTOR (11 downto 0);
           rgb_out : out  STD_LOGIC_VECTOR (11 downto 0);
           sync_h : out  STD_LOGIC;
           sync_v : out  STD_LOGIC
           );
end TOP_colorProcessor;

architecture Behavioral of TOP_colorProcessor is
    component clkEnable
        generic (   N : positive := 3;
                    LIMIT : positive := 6);

        Port ( clk : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               enable : out  STD_LOGIC);
    end component;

    component VGA
        Port ( enable : in  STD_LOGIC;
               clk : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               sync_h : out  STD_LOGIC;
               sync_v : out  STD_LOGIC;
               inhibColor : out  STD_LOGIC);
    end component;

    signal enable_25MHz : STD_LOGIC;
    signal inhibColor : STD_LOGIC;

begin
    Module_clkEnable_25MHz: clkEnable
        generic map (
            N => 2,
            LIMIT => 4
        )
        Port map (
            clk => clk,
            reset => reset,
            enable => enable_25MHz
        );

    Module_VGA: VGA
        Port map (
            enable => enable_25MHz,
            clk => clk,
            reset => reset,
            sync_h => sync_h,
            sync_v => sync_v,
            inhibColor => inhibColor
        );

    rgb_out_process: process(clk, reset)
    begin
        if reset = '1' then
            rgb_out <= (others => '0');
        elsif(clk'event and clk = '1') then
            if enable_25MHz = '1' then
                if inhibColor = '1' then
                    rgb_out <= (others => '0');
                else
                    rgb_out <= rgb_in;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
