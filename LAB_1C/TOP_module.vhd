----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:52:17 03/03/2026 
-- Design Name: 
-- Module Name:    TOP_module - Behavioral 
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

entity TOP_module is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable_1MHz_out : out  STD_LOGIC;
           enable_48KHz_out : out  STD_LOGIC;
           enable_22kHz_out : out  STD_LOGIC;
           enable_7kHz_out : out  STD_LOGIC
           );
end TOP_module;

architecture Behavioral of TOP_module is
    component clkEnable
        generic (   N : positive := 3;
                    LIMIT : positive := 8);

        Port ( clk : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               enable : out  STD_LOGIC);
    end component;

begin
    Module_clkEnable_1MHz: clkEnable
        generic map (
            N => 7,
            LIMIT => 100
        )
        Port map (
            clk => clk,
            reset => reset,
            enable => enable_1MHz_out
        );

    Module_clkEnable_48KHz: clkEnable
        generic map (
            N => 12,
            LIMIT => 2083
        )
        Port map (
            clk => clk,
            reset => reset,
            enable => enable_48KHz_out
        );

    Module_clkEnable_22kHz: clkEnable
        generic map (
            N => 13,
            LIMIT => 4545
        )
        Port map (
            clk => clk,
            reset => reset,
            enable => enable_22kHz_out
        );

    Module_clkEnable_7kHz: clkEnable
        generic map (
            N => 14,
            LIMIT => 14286
        )
        Port map (
            clk => clk,
            reset => reset,
            enable => enable_7kHz_out
        );

end Behavioral;

