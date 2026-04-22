----------------------------------------------------------------------------------
-- Company: Polytechnic University of Cartagena
-- Engineer: Luis Carretero Lopez
--
-- Create Date:    00:00:00 04/20/2026
-- Design Name:
-- Module Name:    ButtonCounterStm - Behavioral
-- Project Name:   LAB_4C
-- Target Devices:
-- Tool versions:
-- Description: Top template with entity and Behavioral architecture blocks.
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
use IEEE.NUMERIC_STD.ALL;

entity ButtonCounterStm is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           BTN : in  STD_LOGIC_VECTOR(1 downto 0);
           ModeSelector : in  STD_LOGIC_VECTOR(1 downto 0);
           ShowCounter : out  STD_LOGIC_VECTOR(7 downto 0));
end ButtonCounterStm;

architecture Behavioral of ButtonCounterStm is
    component buttonCounterContinous
        generic (
            STABILIZATION_TIME : integer := 500000;
            HOLD : boolean := false
        );
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               input : in STD_LOGIC;
               output : out STD_LOGIC);
    end component;

    signal btn_count : std_logic_vector(1 downto 0);
    signal btn_count_continous : std_logic_vector(1 downto 0);
    signal tick_1ms : std_logic;
    signal counter_1ms : unsigned(16 downto 0);
    signal hold_limit : integer range 99 to 399 := 399; -- 399 for 400ms, 99 for 100ms
    signal event_counter : integer range 0 to 399 := 0;
    signal hold_ms : integer range 0 to 3000;
    signal hold_enabled : std_logic;
    signal value : unsigned(7 downto 0);

    type states_t is (IDLE, HOLD, WAIT_RELEASE);
    signal state, next_state : states_t;

begin
    stm_process: process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
        elsif (clk'event and clk = '1') then
            state <= next_state;
        end if;
    end process;

    output_process: process (state)
    begin
        case state is
            when IDLE         => hold_enabled <= '0';
            when HOLD         => hold_enabled <= '1';
            when WAIT_RELEASE => hold_enabled <= '1';
        end case;
    end process;

    next_state_process: process (state, hold_ms, btn_count_continous)
    begin
        case state is
            when IDLE =>
                if btn_count_continous(0) = '1' or btn_count_continous(1) = '1' then
                    next_state <= HOLD;
                else
                    next_state <= IDLE;
                end if;
            when HOLD =>
                if btn_count_continous(0) = '1' or btn_count_continous(1) = '1' then
                    if hold_ms >= 3000 then
                        next_state <= WAIT_RELEASE;
                    else
                        next_state <= HOLD;
                    end if;
                else
                    next_state <= IDLE;
                end if;
            when WAIT_RELEASE =>
                if btn_count_continous(0) = '1' or btn_count_continous(1) = '1' then
                    next_state <= WAIT_RELEASE;
                else
                    next_state <= IDLE;
                end if;
        end case;
    end process;

    generate_debounce_stm: for i in 0 to 1 generate
        debounce_stm_i:buttonCounterContinous
            generic map (
                STABILIZATION_TIME => 500000,
                HOLD => false
            )
            port map (
                clk => clk,
                reset => reset,
                input => BTN(i),
                output => btn_count(i)
            );
    end generate;

    generate_debounce_continous: for i in 0 to 1 generate
        debounce_continous_i:buttonCounterContinous
            generic map (
                STABILIZATION_TIME => 500000,
                HOLD => true
            )
            port map (
                clk => clk,
                reset => reset,
                input => BTN(i),
                output => btn_count_continous(i)
            );
    end generate;

    process_counter_1ms: process(clk, reset)
    begin
        if reset = '1' then
            counter_1ms <= (others => '0');
        elsif (clk'event and clk = '1') then
            if hold_enabled = '1' then
                if counter_1ms < 99999 then
                    counter_1ms <= counter_1ms + 1;
                    tick_1ms <= '0';
                else
                    tick_1ms <= '1';
                    counter_1ms <= (others => '0');
                end if;
            else
                tick_1ms <= '0';
                counter_1ms <= (others => '0');
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

    process_hold_limit: process(ModeSelector, hold_ms)
    begin
        hold_limit <= 399; -- Default to 400ms
        if ModeSelector(1) = '1' then
            if hold_ms >= 500 and hold_ms < 1500 then
                hold_limit <= 299; -- 300ms
            elsif hold_ms >= 1500 and hold_ms < 2000 then
                hold_limit <= 199; -- 200ms
            elsif hold_ms >= 2000 and hold_ms < 2500 then
                hold_limit <= 159; -- 150ms
            elsif hold_ms >= 2500 then
                hold_limit <= 99; -- 100ms
            end if;
        end if;
    end process;

    process_show_counter: process (clk, reset)
    begin
        if reset = '1' then
            value <= 100;
        elsif (clk'event and clk = '1') then
            if ModeSelector = "00" then
                if btn_count(0) = '1' and value < 255 then
                    value <= value + 1;
                elsif btn_count(1) = '1' and value > 1 then
                    value <= value - 1;
                end if;
            elsif ModeSelector = "01" or ModeSelector(1) = '1' then
                if event_counter = hold_limit then
                    if btn_count_continous(0) = '1' and value < 255 then
                        value <= value + 1;
                    elsif btn_count_continous(1) = '1' and value > 1 then
                        value <= value - 1;
                    end if;
                end if;
            end if;
        end if; 
    end process;

    ShowCounter <= std_logic_vector(value);

end Behavioral;
