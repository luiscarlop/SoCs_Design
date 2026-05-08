--------------------------------------------------------------------------------
-- Company: Polytechnic University of Cartagena
-- Engineer: Luis Carretero Lopez
--
-- Module Name: tbRAM_memory
-- Description: Testbench for RAM_memory.
--              Writes red (x"F00") to address 87 (row=5, col=7 in a 16x16 grid)
--              then reads back to confirm the value is stored correctly.
--              Also scans addresses 80-95 to verify only addr=87 returns red.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tbRAM_memory is
end tbRAM_memory;

architecture behavior of tbRAM_memory is

    component RAM_memory
        Generic (
            addr_width : integer := 8;
            data_width : integer := 12
        );
        Port (
            clk          : in  STD_LOGIC;
            addr         : in  unsigned(addr_width-1 downto 0);
            write_enable : in  STD_LOGIC;
            data_in      : in  unsigned(data_width-1 downto 0);
            data_o       : out unsigned(data_width-1 downto 0)
        );
    end component;

    -- 25 MHz clock (same as VGA pixel clock)
    constant CLK_PERIOD : time := 40 ns;

    -- Pixel to paint red: row=5, col=7 → addr = 5*16 + 7 = 87
    constant TARGET_ROW  : integer := 5;
    constant TARGET_COL  : integer := 7;
    constant TARGET_ADDR : integer := TARGET_ROW * 16 + TARGET_COL; -- 87

    constant COLOR_RED   : unsigned(11 downto 0) := x"F00"; -- R=F G=0 B=0
    constant COLOR_BLACK : unsigned(11 downto 0) := x"000";

    signal clk          : STD_LOGIC := '0';
    signal addr         : unsigned(7 downto 0)  := (others => '0');
    signal write_enable : STD_LOGIC := '0';
    signal data_in      : unsigned(11 downto 0) := (others => '0');
    signal data_o       : unsigned(11 downto 0);

begin

    uut: RAM_memory
        generic map (
            addr_width => 8,
            data_width => 12
        )
        port map (
            clk          => clk,
            addr         => addr,
            write_enable => write_enable,
            data_in      => data_in,
            data_o       => data_o
        );

    clk_process: process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_proc: process
    begin
        -- ----------------------------------------------------------------
        -- 1. Let everything settle (all addresses already reset to 0)
        -- ----------------------------------------------------------------
        wait for 5 * CLK_PERIOD;

        -- ----------------------------------------------------------------
        -- 2. Write red to addr=87 (row=5, col=7)
        -- ----------------------------------------------------------------
        addr         <= to_unsigned(TARGET_ADDR, 8);  -- 87
        data_in      <= COLOR_RED;                     -- x"F00"
        write_enable <= '1';
        wait for CLK_PERIOD;   -- one rising edge: write is committed
        write_enable <= '0';

        -- ----------------------------------------------------------------
        -- 3. Read back addr=87 (synchronous RAM: data_o valid 1 cycle later)
        --    The write cycle itself already did a read-first read, so
        --    data_o is already x"F00" after that clock edge.
        --    One more cycle confirms steady-state read.
        -- ----------------------------------------------------------------
        wait for CLK_PERIOD;
        -- data_o should now be x"F00"
        assert data_o = COLOR_RED
            report "FAIL: addr=87 expected RED (F00) but got " &
                   integer'image(to_integer(data_o))
            severity error;

        -- ----------------------------------------------------------------
        -- 4. Scan addresses 80..95 — only 87 must be red
        -- ----------------------------------------------------------------
        for i in 80 to 95 loop
            addr <= to_unsigned(i, 8);
            wait for CLK_PERIOD;   -- wait one cycle for synchronous read
            if i = TARGET_ADDR then
                assert data_o = COLOR_RED
                    report "FAIL: addr=" & integer'image(i) &
                           " should be RED but is " &
                           integer'image(to_integer(data_o))
                    severity error;
            else
                assert data_o = COLOR_BLACK
                    report "FAIL: addr=" & integer'image(i) &
                           " should be BLACK but is " &
                           integer'image(to_integer(data_o))
                    severity error;
            end if;
        end loop;

        -- ----------------------------------------------------------------
        -- 5. Write a second colour (green) to addr=0 and verify it
        -- ----------------------------------------------------------------
        addr         <= to_unsigned(0, 8);
        data_in      <= x"0F0";   -- G=F
        write_enable <= '1';
        wait for CLK_PERIOD;
        write_enable <= '0';
        wait for CLK_PERIOD;

        assert data_o = x"0F0"
            report "FAIL: addr=0 expected GREEN (0F0) but got " &
                   integer'image(to_integer(data_o))
            severity error;

        -- ----------------------------------------------------------------
        -- 6. Go back to addr=87 — must still be red (no corruption)
        -- ----------------------------------------------------------------
        addr <= to_unsigned(TARGET_ADDR, 8);
        wait for CLK_PERIOD;

        assert data_o = COLOR_RED
            report "FAIL: addr=87 corrupted after writing addr=0"
            severity error;

        report "SIMULATION COMPLETE — all checks passed" severity note;
        wait;
    end process;

end behavior;
