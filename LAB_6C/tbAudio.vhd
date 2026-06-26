--------------------------------------------------------------------------------
-- Testbench: tbAudio
-- Drives the audio UUT with a 32-point sine wave over I2S.
--
-- Clock strategy:
--   SIMULATION generic bypasses the MMCM; clk_100_in is used directly as
--   clk_48MHz inside the UUT.  Driven at 20833 ps (~48 MHz).
--
-- I2S format (matches i2s_data_interface.vhd):
--   BCLK period = 32 x CLK_PERIOD (~1.5 MHz)
--   32 BCLK cycles per channel: 16 data bits (MSB first) + 16 zero padding
--   64 BCLK cycles per stereo frame
--   LR = '0' -> Left channel   LR = '1' -> Right channel
--   LR and MOSI change on BCLK falling edge
--
-- Test sequence:
--   1. Reset
--   2. Hold record_button past the 240 000-cycle debounce ->
--      state enters RECORDING, sine frames written to RAM, has_data = '1'
--   3. Release record_button -> state returns to IDLE
--   4. Hold play_button past debounce -> play_event fires, state -> REPLAY
--   5. Release play_button; observe REPLAY on LED[6]
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tbAudio is
end tbAudio;

architecture behavior of tbAudio is

  --------------------------------------------------------------------------
  -- Component declaration (must match audio entity including SIMULATION generic)
  --------------------------------------------------------------------------
  component audio
    generic (
      SIMULATION : boolean := false
    );
    port (
      clk_100_in    : in    std_logic;
      AC_ADR0       : out   std_logic;
      AC_ADR1       : out   std_logic;
      AC_GPIO0      : out   std_logic;
      AC_GPIO1      : in    std_logic;
      AC_GPIO2      : in    std_logic;
      AC_GPIO3      : in    std_logic;
      AC_MCLK       : out   std_logic;
      AC_SCK        : out   std_logic;
      AC_SDA        : inout std_logic;
      reset         : in    std_logic;
      switch        : in    std_logic_vector(7 downto 1);
      LEDs          : out   std_logic_vector(7 downto 0);
      mute          : in    std_logic;
      record_button : in    std_logic;
      play_button   : in    std_logic;
      pitch_up      : in    std_logic;
      pitch_down    : in    std_logic
    );
  end component;

  --------------------------------------------------------------------------
  -- Timing constants
  --------------------------------------------------------------------------
  -- 1/48 MHz = 20.833 ns ~ 20833 ps
  constant CLK_PERIOD    : time := 20833 ps;
  -- BCLK half-period: 16 system clocks -> BCLK ~1.5 MHz
  -- The i2s_data_interface uses a 10-bit shift register to detect edges;
  -- 16 cycles per half-period is well within its timing margin.
  constant BCLK_HALF     : time := CLK_PERIOD * 16;
  -- Hold buttons for 241 000 cycles, just above the 240 000-cycle debounce
  constant DEBOUNCE_WAIT : time := CLK_PERIOD * 241000;

  --------------------------------------------------------------------------
  -- 32-point sine LUT, 16-bit signed (two's complement)
  -- value[k] = round(32767 * sin(2*pi*k/32))
  --------------------------------------------------------------------------
  type sine_lut_t is array (0 to 31) of std_logic_vector(15 downto 0);
  constant SINE_LUT : sine_lut_t := (
    x"0000",  -- k= 0   sin(  0.00 deg) =      0
    x"18F9",  -- k= 1   sin( 11.25 deg) =   6393
    x"30FB",  -- k= 2   sin( 22.50 deg) =  12539
    x"471C",  -- k= 3   sin( 33.75 deg) =  18204
    x"5A82",  -- k= 4   sin( 45.00 deg) =  23170
    x"6A6D",  -- k= 5   sin( 56.25 deg) =  27245
    x"7641",  -- k= 6   sin( 67.50 deg) =  30273
    x"7D8A",  -- k= 7   sin( 78.75 deg) =  32138
    x"7FFF",  -- k= 8   sin( 90.00 deg) =  32767
    x"7D8A",  -- k= 9   sin(101.25 deg) =  32138
    x"7641",  -- k=10   sin(112.50 deg) =  30273
    x"6A6D",  -- k=11   sin(123.75 deg) =  27245
    x"5A82",  -- k=12   sin(135.00 deg) =  23170
    x"471C",  -- k=13   sin(146.25 deg) =  18204
    x"30FB",  -- k=14   sin(157.50 deg) =  12539
    x"18F9",  -- k=15   sin(168.75 deg) =   6393
    x"0000",  -- k=16   sin(180.00 deg) =      0
    x"E707",  -- k=17   sin(191.25 deg) =  -6393
    x"CF05",  -- k=18   sin(202.50 deg) = -12539
    x"B8E4",  -- k=19   sin(213.75 deg) = -18204
    x"A57E",  -- k=20   sin(225.00 deg) = -23170
    x"9593",  -- k=21   sin(236.25 deg) = -27245
    x"89BF",  -- k=22   sin(247.50 deg) = -30273
    x"8276",  -- k=23   sin(258.75 deg) = -32138
    x"8001",  -- k=24   sin(270.00 deg) = -32767
    x"8276",  -- k=25   sin(281.25 deg) = -32138
    x"89BF",  -- k=26   sin(292.50 deg) = -30273
    x"9593",  -- k=27   sin(303.75 deg) = -27245
    x"A57E",  -- k=28   sin(315.00 deg) = -23170
    x"B8E4",  -- k=29   sin(326.25 deg) = -18204
    x"CF05",  -- k=30   sin(337.50 deg) = -12539
    x"E707"   -- k=31   sin(348.75 deg) =  -6393
  );

  --------------------------------------------------------------------------
  -- Testbench signals
  --------------------------------------------------------------------------
  signal clk_100_in    : std_logic := '0';
  signal AC_GPIO1      : std_logic := '0';  -- I2S MOSI (sine data in)
  signal AC_GPIO2      : std_logic := '0';  -- I2S BCLK
  signal AC_GPIO3      : std_logic := '0';  -- I2S LR
  signal reset         : std_logic := '0';
  signal switch        : std_logic_vector(7 downto 1) := (others => '0');
  signal mute          : std_logic := '0';
  signal record_button : std_logic := '0';
  signal play_button   : std_logic := '0';
  signal pitch_up      : std_logic := '0';
  signal pitch_down    : std_logic := '0';
  signal AC_SDA        : std_logic;
  signal AC_ADR0       : std_logic;
  signal AC_ADR1       : std_logic;
  signal AC_GPIO0      : std_logic;
  signal AC_MCLK       : std_logic;
  signal AC_SCK        : std_logic;
  signal LEDs          : std_logic_vector(7 downto 0);

begin

  --------------------------------------------------------------------------
  -- UUT
  --------------------------------------------------------------------------
  uut : audio
    generic map (
      SIMULATION => true    -- bypasses MMCM; clk_100_in driven as 48 MHz
    )
    port map (
      clk_100_in    => clk_100_in,
      AC_ADR0       => AC_ADR0,
      AC_ADR1       => AC_ADR1,
      AC_GPIO0      => AC_GPIO0,
      AC_GPIO1      => AC_GPIO1,
      AC_GPIO2      => AC_GPIO2,
      AC_GPIO3      => AC_GPIO3,
      AC_MCLK       => AC_MCLK,
      AC_SCK        => AC_SCK,
      AC_SDA        => AC_SDA,
      reset         => reset,
      switch        => switch,
      LEDs          => LEDs,
      mute          => mute,
      record_button => record_button,
      play_button   => play_button,
      pitch_up      => pitch_up,
      pitch_down    => pitch_down
    );

  --------------------------------------------------------------------------
  -- System clock ~48 MHz
  --------------------------------------------------------------------------
  clk_proc : process
  begin
    clk_100_in <= '0'; wait for CLK_PERIOD / 2;
    clk_100_in <= '1'; wait for CLK_PERIOD / 2;
  end process;

  --------------------------------------------------------------------------
  -- I2S sine generator
  --
  -- Produces continuous BCLK / LR / MOSI from the sine LUT.
  -- One stereo frame = 64 BCLK cycles:
  --   Cycles  0-31  LR='0'  16 data bits (MSB first) then 16 zeros  (Left)
  --   Cycles 32-63  LR='1'  16 data bits (MSB first) then 16 zeros  (Right)
  --
  -- MOSI and LR update on the BCLK falling edge (standard I2S timing).
  -- i2s_data_interface.vhd captures MOSI on the BCLK rising edge.
  --------------------------------------------------------------------------
  i2s_gen : process
    variable sample_idx : integer range 0 to 31 := 0;
    variable sample     : std_logic_vector(15 downto 0);
  begin
    AC_GPIO2 <= '0';
    AC_GPIO3 <= '0';
    AC_GPIO1 <= '0';
    wait until reset = '0';
    wait for CLK_PERIOD * 5;   -- brief settling

    loop
      sample := SINE_LUT(sample_idx);

      -- ---- Left channel (LR = '0') -----------------------------------------
      -- 16 data bits, MSB first
      for bit_idx in 15 downto 0 loop
        AC_GPIO2 <= '0';          -- BCLK low  (data is set / stable here)
        AC_GPIO3 <= '0';          -- LR = Left
        AC_GPIO1 <= sample(bit_idx);
        wait for BCLK_HALF;
        AC_GPIO2 <= '1';          -- BCLK high (i2s_data_interface samples here)
        wait for BCLK_HALF;
      end loop;

      -- 16 zero-padding cycles
      for pad in 0 to 15 loop
        AC_GPIO2 <= '0';
        AC_GPIO1 <= '0';
        wait for BCLK_HALF;
        AC_GPIO2 <= '1';
        wait for BCLK_HALF;
      end loop;

      -- ---- Right channel (LR = '1') ----------------------------------------
      -- LR rises on the falling edge at the channel boundary (standard I2S).
      -- 16 data bits, MSB first  (same sine sample on both channels)
      for bit_idx in 15 downto 0 loop
        AC_GPIO2 <= '0';
        AC_GPIO3 <= '1';          -- LR = Right (rising edge on first iteration)
        AC_GPIO1 <= sample(bit_idx);
        wait for BCLK_HALF;
        AC_GPIO2 <= '1';
        wait for BCLK_HALF;
      end loop;

      -- 16 zero-padding cycles
      for pad in 0 to 15 loop
        AC_GPIO2 <= '0';
        AC_GPIO1 <= '0';
        wait for BCLK_HALF;
        AC_GPIO2 <= '1';
        wait for BCLK_HALF;
      end loop;

      -- Advance sine table index
      if sample_idx = 31 then
        sample_idx := 0;
      else
        sample_idx := sample_idx + 1;
      end if;
    end loop;
  end process;

  --------------------------------------------------------------------------
  -- Stimulus: reset -> record -> play
  --------------------------------------------------------------------------
  stim_proc : process
  begin
    -- ---- Reset --------------------------------------------------------------
    reset <= '1';
    wait for 200 ns;
    reset <= '0';

    -- ---- Record -------------------------------------------------------------
    -- ButtonCounterContinous (HOLD=true, STABILIZATION_TIME=240000):
    --   Hold button > 240000 cycles -> record_pressed stays '1' while held.
    -- After debounce: FSM enters RECORDING.
    -- write_enable fires every 4365 cycles (~91 us); samples fill RAM.
    -- has_data goes '1' after the first write_enable.
    wait for CLK_PERIOD * 10;
    record_button <= '1';
    wait for DEBOUNCE_WAIT;        -- 241 000 cycles: debounce done, RECORDING
    wait for CLK_PERIOD * 100000;   -- record for ~10 ms (100 samples)
    record_button <= '0';
    -- record_pressed -> '0'; FSM: RECORDING -> IDLE

    wait for CLK_PERIOD * 10;   -- gap

    -- ---- Play ---------------------------------------------------------------
    -- ButtonCounterContinous (HOLD=false, STABILIZATION_TIME=240000):
    --   Hold button > 240000 cycles -> play_event pulses '1' for exactly
    --   1 clock cycle (EDGE state).
    -- That cycle: play_pause toggles '0'->'1' AND FSM -> REPLAY (has_data='1').
    play_button <= '1';
    wait for DEBOUNCE_WAIT;        -- 241 000 cycles: play_event fires
    play_button <= '0';            -- release; ButtonCounterContinous -> IDLE

    -- ---- Observe playback ---------------------------------------------------
    -- Expected: LEDs[6] = '1'  (REPLAY state)
    --           addr_counter_b increments on each playback_event (~91 us period)
    --           hphone_l/r driven from RAM (recorded sine samples)
    wait for CLK_PERIOD * 100000;  -- watch ~2 ms of playback
    
    for i in 0 to 4 loop
      pitch_up <= '1';
      wait for DEBOUNCE_WAIT;        -- 241 000 cycles: pitch_up event fires
      pitch_up <= '0';
      wait for CLK_PERIOD * 100;
    end loop;

    play_button <= '1';
    wait for DEBOUNCE_WAIT;        -- 241 000 cycles: play_event fires
    play_button <= '0'; 

    wait;   -- hold here; stop simulation manually in ISim
  end process;

end behavior;
