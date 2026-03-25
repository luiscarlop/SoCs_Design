----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:43:38 03/25/2026 
-- Design Name: 
-- Module Name:    antiBouncesSTM - Behavioral 
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

entity antiBouncesSTM is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           input : in  STD_LOGIC;
           output : out  STD_LOGIC);
end antiBouncesSTM;

architecture Behavioral of antiBouncesSTM is

    type states_t is (IDLE, EDGE, ENABLED);
    signal state, next_state : states_t;

begin
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
        elsif (clk'event and clk = '1') then
            state <= next_state;
        end if;
    end process;

    output_process: process(state)
    begin
        case state is
            when IDLE       => output <= '0';
            when EDGE       => output <= '1';
            when ENABLED    => output <= '1';
        end case;
    end process;

    next_state_process: process(state, input)
    begin
        case state is
            when IDLE =>
                if input = '1' then
                    next_state <= EDGE;
                else
                    next_state <= IDLE;
                end if;
            when EDGE =>
                if input = '1' then
                    next_state <= ENABLED;
                else
                    next_state <= IDLE;
                end if;
            when ENABLED =>
                if input = '1' then
                    next_state <= ENABLED;
                else
                    next_state <= IDLE;
                end if;
        end case;
    end process;
end Behavioral;

