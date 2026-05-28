----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:43:38 03/25/2026 
-- Design Name: 
-- Module Name:    movement_stm - Behavioral 
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

entity movement_stm is
    Generic (
        CLK_FREQ : integer := 100000000 -- 100 MHz
        COUNT_LIMIT : integer := 100 -- Number of ms to wait (default: 100ms)
    );
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           event_out : out  STD_LOGIC);
end movement_stm;

architecture Behavioral of movement_stm is

    constant counter_1ms_limit : integer := CLK_FREQ / 1000; -- Number of clock cycles in 1 ms

    signal tick_1ms : STD_LOGIC;
    signal counter_1ms : integer range 0 to counter_1ms_limit - 1 := 0; -- Scales with CLK_FREQ
    signal event_counter : integer range 0 to COUNT_LIMIT - 1 := 0;

begin
    process_counter_1ms: process(clk, reset)
    begin
        if reset = '1' then
            counter_1ms <= 0;
        elsif (clk'event and clk = '1') then
            if enable = '1' then
                if counter_1ms < counter_1ms_limit - 1 then
                    counter_1ms <= counter_1ms + 1;
                    tick_1ms <= '0';
                else
                    tick_1ms <= '1';
                    counter_1ms <= 0;
                end if;
            else
                tick_1ms <= '0';
                counter_1ms <= 0;
            end if;
        end if;
    end process;

    process_counter_400ms: process (clk, reset)
    begin
        if reset = '1' then
            event_counter <= 0;
        elsif (clk'event and clk = '1') then
            if hold_enabled = '0' then
                event_counter <= 0;
            elsif tick_1ms = '1' then
                if event_counter >= hold_limit then
                    event_counter <= 0;
                else
                    event_counter <= event_counter + 1;
                end if;
            end if;
        end if;
    end process;

    process_hold_ms: process(clk, reset)
    begin
        if reset = '1' then
            hold_ms <= 0;
        elsif (clk'event and clk = '1') then
            if hold_enabled = '0' then
                hold_ms <= 0;
            elsif tick_1ms = '1' and hold_ms < 3000 then
                hold_ms <= hold_ms + 1;
            end if;
        end if;
    end process;

    process_hold_limit: process(state, hold_ms)
    begin
        hold_limit <= 399; -- Default to 400ms
        i_step_size <= to_unsigned(4, 5); -- Default to 4 pixels
        if state = MOVE then
            if hold_ms >= 500 and hold_ms < 1500 then
                hold_limit <= 299; -- 300ms
                i_step_size <= to_unsigned(8, 5); -- 8 pixels
            elsif hold_ms >= 1500 and hold_ms < 2000 then
                hold_limit <= 199; -- 200ms
                i_step_size <= to_unsigned(12, 5); -- 12 pixels
            elsif hold_ms >= 2000 and hold_ms < 2500 then
                hold_limit <= 159; -- 150ms
                i_step_size <= to_unsigned(16, 5); -- 16 pixels
            elsif hold_ms >= 2500 then
                hold_limit <= 99; -- 100ms
                i_step_size <= to_unsigned(20, 5); -- 20 pixels
            end if;
        end if;
    end process;

    move_process: process(clk, reset)
    begin
        if reset = '1' then
            i_move <= "00";
        elsif (clk'event and clk = '1') then
            if tick_1ms = '1' and event_counter = hold_limit then
                if i_forward = '1' then
                    i_move <= "10"; -- Move forward
                elsif i_backward = '1' then
                    i_move <= "01"; -- Move backward
                end if;
            else
                i_move <= "00"; -- No movement
            end if;
        end if;
    end process;

    output_process: process(state, i_move, i_step_size)
    begin
        case state is
            when IDLE         =>    move_forward <= '0'; -- No movement
                                    step_size <= (others => '0');
            when MOVE         =>    move_forward <= i_move(1);
                                    move_backward <= i_move(0);
                                    step_size <= i_step_size;
            when WAIT_RELEASE =>    move_forward <= i_move(1);
                                    move_backward <= i_move(0);
                                    step_size <= i_step_size;
        end case;
    end process;

    next_state_process: process(state, hold_ms, i_forward, i_backward)
    begin
        case state is
            when IDLE =>
                if i_forward = '1' or i_backward = '1' then
                    next_state <= MOVE;
                else
                    next_state <= IDLE;
                end if;
            when MOVE =>
                if i_forward = '1' or i_backward = '1' then
                    if hold_ms >= 3000 then
                        next_state <= WAIT_RELEASE;
                    else
                        next_state <= MOVE;
                    end if;
                else
                    next_state <= IDLE;
                end if;
            when WAIT_RELEASE =>
                if i_forward = '1' or i_backward = '1' then
                    next_state <= WAIT_RELEASE;
                else
                    next_state <= IDLE;
                end if;
        end case;
    end process;
end Behavioral;

