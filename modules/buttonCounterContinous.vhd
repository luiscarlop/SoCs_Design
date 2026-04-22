----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:43:38 03/25/2026 
-- Design Name: 
-- Module Name:    buttonCounterContinous - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity buttonCounterContinous is
    Generic (
        -- Time to wait for the signal to stabilize after detecting an edge (in clock cycles)
        -- Adjust this value based on your clock frequency and expected bounce duration
            STABILIZATION_TIME : integer := 500000; -- e.g., 500,000 cycles at 100 MHz = 5 ms
        HOLD : boolean := false -- If true, the output will remain high until the button is released
    );
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           input : in  STD_LOGIC;
           output : out  STD_LOGIC);
end buttonCounterContinous;

architecture Behavioral of buttonCounterContinous is

    type states_t is (IDLE, COUNTING, EDGE, WAIT_RELEASE);
    signal state, next_state : states_t;

    signal counter : integer range 0 to STABILIZATION_TIME := 0;

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
            when IDLE         => output <= '0';
            when COUNTING     => output <= '0';
            when EDGE         => output <= '1';
            when WAIT_RELEASE =>
                if HOLD then
                    output <= '1';
                else
                    output <= '0';
                end if;
        end case;
    end process;

    counter_process: process(state, clk)
    begin
        if (clk'event and clk = '1') then
            if state = COUNTING then
                if counter < STABILIZATION_TIME then
                    counter <= counter + 1;
                else
                    counter <= 0; -- Reset counter for next use
                end if;
            else
                counter <= 0; -- Ensure counter is reset when not counting
            end if;
        end if;
    end process;

    next_state_process: process(state, input, counter)
    begin
        case state is
            when IDLE =>
                if input = '1' then
                    next_state <= COUNTING;
                else
                    next_state <= IDLE;
                end if;
            when COUNTING =>
                if input = '1' then
                    if counter < STABILIZATION_TIME then
                        next_state <= COUNTING;
                    else
                        next_state <= EDGE;
                    end if;
                else
                    next_state <= IDLE;
                end if;
            when EDGE =>
                if input = '1' then
                    next_state <= WAIT_RELEASE;
                else
                    next_state <= IDLE;
                end if;
            when WAIT_RELEASE =>
                if input = '1' then
                    next_state <= WAIT_RELEASE;
                else
                    next_state <= IDLE;
                end if;
        end case;
    end process;
end Behavioral;

