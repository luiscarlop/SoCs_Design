----------------------------------------------------------------------------------
-- Module Name:    antiBouncesSTM - Behavioral
-- Description:    Debounce STM with 20ms hold timer.
--                 Outputs a single 1-cycle pulse after input is stable HIGH
--                 for DEBOUNCE_TIME cycles. Ignores re-presses until release.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity antiBouncesSTM is
    Port ( clk    : in  STD_LOGIC;
           reset  : in  STD_LOGIC;
           input  : in  STD_LOGIC;
           output : out STD_LOGIC);
end antiBouncesSTM;

architecture Behavioral of antiBouncesSTM is

    -- 20ms at 25MHz = 500,000 cycles -> 20-bit counter
    constant DEBOUNCE_TIME : integer := 500000;

    type states_t is (IDLE, COUNTING, PULSE, WAIT_RELEASE);
    signal state : states_t := IDLE;

    signal counter : integer range 0 to DEBOUNCE_TIME := 0;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            state   <= IDLE;
            counter <= 0;
            output  <= '0';
        elsif (clk'event and clk = '1') then
            output <= '0'; -- default: no pulse

            case state is
                when IDLE =>
                    if input = '1' then
                        counter <= 0;
                        state   <= COUNTING;
                    end if;

                when COUNTING =>
                    if input = '0' then
                        -- bounced, restart
                        state   <= IDLE;
                        counter <= 0;
                    elsif counter = DEBOUNCE_TIME - 1 then
                        -- stable for 20ms: emit pulse
                        state   <= PULSE;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;

                when PULSE =>
                    output <= '1';  -- single cycle pulse
                    state  <= WAIT_RELEASE;

                when WAIT_RELEASE =>
                    if input = '0' then
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
