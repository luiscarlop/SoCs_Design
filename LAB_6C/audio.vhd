-- Proyecto b�sico para adquisici�n y generacion de Audio.

-- A�adir MMCM para generar la se�al de reloj clk_48MHz a partir de la se�al de reloj de entrada clk_100_in (de 100 MHz)

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity audio is
  port (
    clk_100_in : in std_logic;
    AC_ADR0    : out std_logic;
    AC_ADR1    : out std_logic;
    AC_GPIO0   : out std_logic; -- I2S MISO
    AC_GPIO1   : in std_logic; -- I2S MOSI
    AC_GPIO2   : in std_logic; -- I2S_bclk
    AC_GPIO3   : in std_logic; -- I2S_LR
    AC_MCLK    : out std_logic;
    AC_SCK     : out std_logic;
    AC_SDA     : inout std_logic;

    reset  : in std_logic; -- BTNC
    switch : in std_logic_vector(7 downto 1);
    LEDs : out std_logic_vector(7 downto 0);

    mute          : in std_logic; -- SW0
    record_button : in std_logic; -- BTNR
    play_button   : in std_logic; -- BTNL
    pitch_up      : in std_logic; -- BTNU
    pitch_down    : in std_logic -- BTND
  );
end audio;

architecture Behavioral of audio is

  -- declaracion componentes ---
  component ADAU1761_controlador
    port (
      clk       : in std_logic;
      AC_GPIO1  : in std_logic;
      AC_GPIO2  : in std_logic;
      AC_GPIO3  : in std_logic;
      hphone_l  : in std_logic_vector(15 downto 0);
      hphone_r  : in std_logic_vector(15 downto 0);
      AC_SDA    : inout std_logic;
      AC_ADR0   : out std_logic;
      AC_ADR1   : out std_logic;
      AC_GPIO0  : out std_logic;
      AC_MCLK   : out std_logic;
      AC_SCK    : out std_logic;
      line_in_l : out std_logic_vector(15 downto 0);
      line_in_r : out std_logic_vector(15 downto 0)
    );
  end component;

  component recorded_audio
    port (
      clka  : in std_logic;
      wea   : in std_logic_vector(0 downto 0);
      addra : in std_logic_vector(16 downto 0);
      dina  : in std_logic_vector(15 downto 0);
      clkb  : in std_logic;
      addrb : in std_logic_vector(16 downto 0);
      doutb : out std_logic_vector(15 downto 0)
    );
  end component;

  component ButtonCounterContinous
    generic (
      STABILIZATION_TIME : integer := 500000;
      HOLD               : boolean := false
    );
    port (
      clk    : in std_logic;
      reset  : in std_logic;
      input  : in std_logic;
      output : out std_logic);
  end component;
  -------------------------------------------
  constant C_BASE_DIV : integer := 4364; -- Base divisor for 11 kHz playback at 48 MHz clock
  constant C_MIN_DIV  : integer := 2182; -- Minimum divisor for 22 kHz playback (2x speed)
  constant C_MAX_DIV  : integer := 10909; -- Maximum divisor for 5 kHz playback (0.5x speed)
  constant C_PITCH_STEP : integer := 436;
  signal pitch_div : integer range C_MIN_DIV to C_MAX_DIV := C_BASE_DIV;

  signal playback_div_limit   : integer range C_MIN_DIV to C_MAX_DIV := C_BASE_DIV;
  signal playback_div_counter : integer range 0 to C_MAX_DIV := 0;
  signal playback_event       : std_logic;
  -- seales generales ---
  signal clk_48MHz            : std_logic;
  signal switch_reg           : std_logic_vector(7 downto 0);

  signal CLKIN1           : std_logic;
  signal CLKOUT0       : std_logic;
  signal CLKFBIN          : std_logic;
  signal CLKFBOUT         : std_logic;
  -------------------------------------------

  -- signals for pitch control ---
  signal record_pressed, play_event, play_pause, pitch_up_event, pitch_down_event : std_logic;

  signal freq_divider_counter : integer range 0 to C_BASE_DIV := 0;
  signal write_enable         : std_logic_vector(0 downto 0);
  signal has_data             : std_logic;

  -- señales Analog Devices Audio Codec 1761---
  signal AC_MCLK_i            : std_logic;
  signal line_in_l, line_in_r : std_logic_vector(15 downto 0);
  signal hphone_l, hphone_r   : std_logic_vector(15 downto 0);
  -------------------------------------------

  signal internal_line_in_l, internal_line_in_r : std_logic_vector(15 downto 0);
  signal addra, addrb                         : std_logic_vector(16 downto 0); -- 17 bits for 128k samples
  signal addr_counter_a                       : integer range 0 to 110999 := 0; -- Counter for addressing RAM (111k samples)
  signal addr_counter_b                       : integer range 0 to 110999 := 0; -- Counter for addressing RAM (111k samples)

  signal recorded_length : integer range 0 to 110999 := 0; -- Length of recorded audio in samples

  type states_t is (IDLE, RECORDING, REPLAY);
  signal state, next_state : states_t;

begin

  -------------------------------------------
  ------------------ FSM --------------------
  -------------------------------------------

  next_state_process : process (clk_48MHz, reset)
  begin
    if reset = '1' then
      state <= IDLE;
    elsif (clk_48MHz'event and clk_48MHz = '1') then
      state <= next_state;
    end if;
  end process;

  transition_process : process (state, record_pressed, play_pause, has_data)
  begin
    case state is
      when IDLE =>
        if record_pressed = '1' then
          next_state <= RECORDING;
        elsif play_event = '1' and has_data = '1' then
          next_state <= REPLAY;
        else
          next_state <= IDLE;
        end if;
      when RECORDING =>
        if record_pressed = '1' then
          next_state <= RECORDING;
        else
          next_state <= IDLE;
        end if;
      when REPLAY =>
        if play_pause = '1' then
          next_state <= REPLAY;
        else
          next_state <= IDLE;
        end if;
    end case;
  end process;
        

  modulo_ADAU1761_controlador : ADAU1761_controlador
  port map
  (
    clk       => clk_48MHz,
    AC_ADR0   => AC_ADR0,
    AC_ADR1   => AC_ADR1,
    AC_GPIO0  => AC_GPIO0,
    AC_GPIO1  => AC_GPIO1,
    AC_GPIO2  => AC_GPIO2,
    AC_GPIO3  => AC_GPIO3,
    AC_MCLK   => AC_MCLK_i,
    AC_SCK    => AC_SCK,
    AC_SDA    => AC_SDA,
    hphone_l  => hphone_l,
    hphone_r  => hphone_r,
    line_in_l => line_in_l,
    line_in_r => line_in_r
  );

  Module_RAM_audio_l : recorded_audio
  port map
  (
    clka  => clk_48MHz,
    wea   => write_enable,
    addra => addra,
    dina  => line_in_l,
    clkb  => clk_48MHz,
    addrb => addrb,
    doutb => internal_line_in_l
  );

  Module_RAM_audio_r : recorded_audio
  port map
  (
    clka  => clk_48MHz,
    wea   => write_enable,
    addra => addra,
    dina  => line_in_r,
    clkb  => clk_48MHz,
    addrb => addrb,
    doutb => internal_line_in_r
  );

  Module_btn_record : ButtonCounterContinous
  generic map(
    STABILIZATION_TIME => 240000, -- 5ms at 48MHz
    HOLD               => true
  )
  port map
  (
    clk    => clk_48MHz,
    reset  => reset,
    input  => record_button, -- BTNR
    output => record_pressed
  );

  Module_btn_play : ButtonCounterContinous
  generic map(
    STABILIZATION_TIME => 240000, -- 5ms at 48MHz
    HOLD               => false
  )
  port map
  (
    clk    => clk_48MHz,
    reset  => reset,
    input  => play_button,
    output => play_event
  );

  Module_btn_pitch_up : ButtonCounterContinous
  generic map(
    STABILIZATION_TIME => 240000, -- 5ms at 48MHz
    HOLD               => false
  )
  port map
  (
    clk    => clk_48MHz,
    reset  => reset,
    input  => pitch_up, -- BTNU
    output => pitch_up_event
  );

  Module_btn_pitch_down : ButtonCounterContinous
  generic map(
    STABILIZATION_TIME => 240000, -- 5ms at 48MHz
    HOLD               => false
  )
  port map
  (
    clk    => clk_48MHz,
    reset  => reset,
    input  => pitch_down, -- BTND
    output => pitch_down_event
  );

  Module_MMCM : MMCME2_BASE
  generic map(
    BANDWIDTH        => "OPTIMIZED",
    CLKFBOUT_MULT_F  => 12.0, -- VCO = 100MHz * 12 = 1200 MHz
    CLKFBOUT_PHASE   => 0.0,
    CLKIN1_PERIOD    => 10.0,
    CLKOUT0_DIVIDE_F => 25.0, -- 1200 MHz / 25 = 48 MHz
    CLKOUT0_PHASE    => 0.0,

    CLKOUT4_CASCADE => FALSE,
    DIVCLK_DIVIDE   => 1,
    REF_JITTER1     => 0.0,
    STARTUP_WAIT    => FALSE
  )
  port map
  (
    CLKOUT0   => CLKOUT0,
    CLKOUT0B  => open,
    CLKOUT1   => open,
    CLKOUT1B  => open,
    CLKOUT2   => open,
    CLKOUT2B  => open,
    CLKOUT3   => open,
    CLKOUT3B  => open,
    CLKOUT4   => open,
    CLKOUT5   => open,
    CLKOUT6   => open,
    CLKFBOUT  => CLKFBOUT,
    CLKFBOUTB => open,
    LOCKED    => open,
    CLKIN1    => CLKIN1,
    PWRDWN    => '0',
    RST       => reset,
    CLKFBIN   => CLKFBIN
  );

  IBUFG_inst : IBUFG
  port map
  (
    O => CLKIN1,
    I => clk_100_in
  );

  BUFG_inst_clkout0 : BUFG
  port map
  (
    O => clk_48MHz,
    I => CLKOUT0
  );

  BUFG_inst_clkfbout : BUFG
  port map
  (
    O => CLKFBIN,
    I => CLKFBOUT
  );

  -------------------------------------------------------------
  --              			PROCESS
  -------------------------------------------------------------

  process_play_pause : process (clk_48MHz, reset)
  begin
    if reset = '1' then
      play_pause <= '0';
    elsif clk_48MHz'event and clk_48MHz = '1' then
      if state = IDLE then
        play_pause <= '0'; -- Reset play_pause when returning to IDLE
      elsif play_event = '1' then
        play_pause <= not play_pause;
      end if;
    end if;
  end process;

  process_pitch_control : process (clk_48MHz, reset)
  begin
    if reset = '1' then
      pitch_div <= C_BASE_DIV;
    elsif clk_48MHz'event and clk_48MHz = '1' then
      if pitch_up_event = '1' then
        if pitch_div > C_MIN_DIv + C_PITCH_STEP then
          pitch_div <= pitch_div - C_PITCH_STEP;
        end if;
      elsif pitch_down_event = '1' then
        if pitch_div < C_MAX_DIV - C_PITCH_STEP then
          pitch_div <= pitch_div + C_PITCH_STEP;
        end if;
      end if;
      playback_div_limit <= pitch_div;
    end if;
  end process;

  process_playback : process (clk_48MHz, reset)
  begin
    if reset = '1' then
      playback_div_counter <= 0;
    elsif (clk_48MHz'event and clk_48MHz = '1') then
      if playback_div_counter < playback_div_limit - 1 then
        playback_div_counter <= playback_div_counter + 1;
        playback_event       <= '0';
      else
        playback_event       <= '1';
        playback_div_counter <= 0;
      end if;
    end if;
  end process;

  process_stored_length : process (clk_48MHz, reset)
  begin
    if reset = '1' then
      recorded_length <= 0;
    elsif (clk_48MHz'event and clk_48MHz = '1') then
      if next_state = RECORDING and state /= RECORDING then
        recorded_length <= 0; -- Reset recorded length when starting a new recording
      elsif state = RECORDING then
        if write_enable = "1" then
          if recorded_length < 110999 then
            recorded_length <= recorded_length + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  process_11khz : process (clk_48MHz, reset)
  begin
    if reset = '1' then
      freq_divider_counter <= 0;
      write_enable   <= "0";
    elsif (clk_48MHz'event and clk_48MHz = '1') then
      if freq_divider_counter < 4364 then
        freq_divider_counter <= freq_divider_counter + 1;
        write_enable   <= "0";
      else
        if record_pressed = '1' and state = RECORDING then
          write_enable   <= "1";
        else
          write_enable   <= "0";
        end if;
        freq_divider_counter <= 0;
      end if;
    end if;
  end process;

  addra <= std_logic_vector(to_unsigned(addr_counter_a, addra'length));
  addrb <= std_logic_vector(to_unsigned(addr_counter_b, addrb'length));

  AC_MCLK <= AC_MCLK_i;

  process_addr : process (clk_48MHz, reset)
  begin
    if reset = '1' then
      addr_counter_a <= 0;
      addr_counter_b <= 0;
    elsif (clk_48MHz'event and clk_48MHz = '1') then
      case state is
        when IDLE =>
          addr_counter_a <= 0;
          addr_counter_b <= 0;
        when RECORDING =>
          if write_enable = "1" then
            if addr_counter_a < 110999 then
              addr_counter_a <= addr_counter_a + 1;
            end if;
          end if;
        when REPLAY =>
          if playback_event = '1' then
            if addr_counter_b < recorded_length then
              addr_counter_b <= addr_counter_b + 1;
            else
              addr_counter_b <= 0;
            end if;
          end if;
      end case;
    end if;
  end process;

  process_has_data : process (clk_48MHz, reset)
  begin
    if reset = '1' then
      has_data <= '0';
    elsif (clk_48MHz'event and clk_48MHz = '1') then
      if write_enable = "1" then
        has_data <= '1';
      end if;
    end if;
  end process;

  process (clk_48MHz)
  begin
    if (clk_48MHz = '1' and clk_48MHz'event) then
      switch_reg <= switch & mute;
    end if;
  end process;

  process_LED_indicator : process (clk_48MHz)
  begin
    if (clk_48MHz = '1' and clk_48MHz'event) then
      if state = RECORDING then
        LEDs(7) <= '1'; -- Turn on LED7 when recording
      else
        LEDs(7) <= '0'; -- Turn off LED7 when not recording
      end if;

      if state = REPLAY then
        LEDs(6) <= '1'; -- Turn on LED6 when playing
      else
        LEDs(6) <= '0'; -- Turn off LED6 when not playing
      end if;

      if playback_div_limit < C_BASE_DIV then
        LEDs(5) <= '1'; -- Turn on LED5 when pitch is up (faster)
      else
        LEDs(5) <= '0'; -- Turn off LED5 when pitch is normal or down
      end if;

      if playback_div_limit > C_BASE_DIV then
        LEDs(4) <= '1'; -- Turn on LED4 when pitch is down (slower)
      else
        LEDs(4) <= '0'; -- Turn off LED4 when pitch is normal or up
      end if;

      if has_data = '1' then
        LEDs(3) <= '1'; -- Turn on LED3 when there is recorded data
      else
        LEDs(3) <= '0'; -- Turn off LED3 when there is no recorded data
      end if;
      LEDs(2 downto 0) <= switch_reg(2 downto 0);
    end if;
  end process;

  process (clk_48MHz)
  begin
    if (clk_48MHz = '1' and clk_48MHz'event) then
      if mute = '1' then
        hphone_l <= (others => '0');
        hphone_r <= (others => '0');
      elsif state = REPLAY then
        hphone_l <= internal_line_in_l;
        hphone_r <= internal_line_in_r;
      elsif switch(1) = '1' then
        hphone_l <= line_in_l;
        hphone_r <= line_in_r;
      else
        hphone_l <= (others => '0');
        hphone_r <= (others => '0');
      end if;
    end if;
  end process;

end Behavioral;
