----------------------------------------------------------------------------------
-- Company: Polytechnic University of Cartagena
-- Engineer: Luis Carretero Lopez
--
-- Create Date:    15:30:23 04/10/2026
-- Design Name:
-- Module Name:    ButtonCounterStm - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: Empty template for the ButtonCounter state-machine top module.
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ButtonCounterStm is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           BTN : in  STD_LOGIC_VECTOR(3 downto 0);
           CounterSelector : in  STD_LOGIC_VECTOR(1 downto 0);
           PressCounterOut : out  STD_LOGIC_VECTOR(7 downto 0));
end ButtonCounterStm;

-- BTN(0) -> UP
-- BTN(1) -> DOWN
-- BTN(2) -> RIGHT
-- BTN(3) -> LEFT

-- CounterSelector(0) -> 00: UP Counter
-- CounterSelector(1) -> 01: LEFT Counter
-- CounterSelector(2) -> 10: DOWN Counter
-- CounterSelector(3) -> 11: RIGHT Counter

architecture Behavioral of ButtonCounterStm is
    component antiBouncesSTM
        generic (
            STABILIZATION_TIME : integer := 500000
        );
        Port ( clk : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               input : in  STD_LOGIC;
               output : out  STD_LOGIC);
    end component;

    signal btn_count : STD_LOGIC_VECTOR(3 downto 0);
    signal press_counter_U, press_counter_D, press_counter_R, press_counter_L : unsigned(7 downto 0);
begin
    gen_debounce_stm: for i in 0 to 3 generate
        debounce_stm_i:antiBouncesSTM
            generic map (
                STABILIZATION_TIME => 500000
            )
            port map (
                clk => clk,
                reset => reset,
                input => BTN(i),
                output => btn_count(i)
            );
    end generate;

    process(clk, reset)
    begin
        if reset = '1' then
            press_counter_U <= (others => '0');
            press_counter_D <= (others => '0');
            press_counter_R <= (others => '0');
            press_counter_L <= (others => '0');
        elsif (clk'event and clk = '1') then
            if btn_count(0) = '1' then
                press_counter_U <= press_counter_U + 1;
            elsif btn_count(1) = '1' then
                press_counter_D <= press_counter_D + 1;
            elsif btn_count(2) = '1' then
                press_counter_R <= press_counter_R + 1;
            elsif btn_count(3) = '1' then
                press_counter_L <= press_counter_L + 1;
            end if;
        end if;
    end process;

    showCounterSelector: process(clk, reset)
    begin
        if reset = '1' then
            PressCounterOut <= (others => '0');
        elsif (clk'event and clk = '1') then
            case CounterSelector is
                when "00" => PressCounterOut <= std_logic_vector(press_counter_U);
                when "01" => PressCounterOut <= std_logic_vector(press_counter_L);
                when "10" => PressCounterOut <= std_logic_vector(press_counter_D);
                when "11" => PressCounterOut <= std_logic_vector(press_counter_R);
                when others => PressCounterOut <= (others => '0');
            end case;
        end if;
    end process;
end Behavioral;

