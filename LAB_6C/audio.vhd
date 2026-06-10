-- Proyecto b�sico para adquisici�n y generacion de Audio.

-- A�adir MMCM para generar la se�al de reloj clk_48MHz a partir de la se�al de reloj de entrada clk_100_in (de 100 MHz)

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
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
    switch : in std_logic_vector(7 downto 2);
    --switch<7>:switch<5> -> increase speed
    --switch<4>:switch<2> -> decrease speed
    LEDs : out std_logic_vector(7 downto 0);

    mute          : in std_logic; -- SW0
    record_button : in std_logic; -- BTNR
    play_button   : in std_logic -- BTNL
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
  signal playback_div_limit   : integer range 0 to 2828 := 1000;
  signal playback_div_counter : integer range 0 to 2828 := 0;
  signal playback_event       : std_logic;
  -- seales generales ---
  signal clk_48MHz, clk_11MHz : std_logic;
  signal switch_reg           : std_logic_vector(7 downto 0);

  signal CLKIN1           : std_logic;
  signal CLKOUT0, CLKOUT1 : std_logic;
  signal CLKFBIN          : std_logic;
  signal CLKFBOUT         : std_logic;
  -------------------------------------------

  -- signals for delay control ---
  signal record_pressed, play_event, play_pause : std_logic;

  signal freq_divider_counter : integer range 0 to 999 := 0;
  signal freq_divider_event   : std_logic;
  signal write_enable         : std_logic_vector(0 downto 0);

  -- señales Analog Devices Audio Codec 1761---
  signal AC_MCLK_i            : std_logic;
  signal line_in_l, line_in_r : std_logic_vector(15 downto 0);
  signal hphone_l, hphone_r   : std_logic_vector(15 downto 0);
  -------------------------------------------

  signal delayed_line_in_l, delayed_line_in_r : std_logic_vector(15 downto 0);
  signal addra, addrb                         : std_logic_vector(16 downto 0); -- 17 bits for 128k samples
  signal addr_counter_a                       : integer range 0 to 110999 := 0; -- Counter for addressing RAM (111k samples)
  signal addr_counter_b                       : integer range 0 to 110999 := 0; -- Counter for addressing RAM (111k samples)

begin

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
    clka  => clk_11MHz,
    wea   => write_enable,
    addra => addra,
    dina  => line_in_l,
    clkb  => clk_48MHz,
    addrb => addrb,
    doutb => delayed_line_in_l
  );

  Module_RAM_audio_r : recorded_audio
  port map
  (
    clka  => clk_11MHz,
    wea   => write_enable,
    addra => addra,
    dina  => line_in_r,
    clkb  => clk_48MHz,
    addrb => addrb,
    doutb => delayed_line_in_r
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

  Module_MMCM : MMCME2_BASE
  generic map(
    BANDWIDTH        => "OPTIMIZED",
    CLKFBOUT_MULT_F  => 12.0, -- VCO = 100MHz * 12 = 1200 MHz
    CLKFBOUT_PHASE   => 0.0,
    CLKIN1_PERIOD    => 10.0,
    CLKOUT0_DIVIDE_F => 25.0, -- 1200 MHz / 25 = 48 MHz
    CLKOUT0_PHASE    => 0.0,
    CLKOUT1_DIVIDE   => 109, -- 1200 MHz / 109 = 11 MHz
    CLKOUT1_PHASE    => 0.0,

    CLKOUT4_CASCADE => FALSE,
    DIVCLK_DIVIDE   => 1,
    REF_JITTER1     => 0.0,
    STARTUP_WAIT    => FALSE
  )
  port map
  (
    CLKOUT0   => CLKOUT0,
    CLKOUT0B  => open,
    CLKOUT1   => CLKOUT1,
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

  BUFG_inst_clkout1 : BUFG
  port map
  (
    O => clk_11MHz,
    I => CLKOUT1
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
      if play_event = '1' then
        play_pause <= not play_pause;
      end if;
    end if;
  end process process_play_pause;

  -- case switch(7 downto 2) is 
  -- 111xxx -> +1.5 octaves
  -- 011xxx -> +1 octave
  -- 001xxx -> +0.5 octaves
  -- 000111 -> -1.5 octaves
  -- 000011 -> -1 octave
  -- 000001 -> -0.5 octaves
  -- others -> default
  process_set_playback_freq : process (switch)
  begin
    if switch(7 downto 5) = "111" then
      playback_div_limit <= 354;
    elsif switch(7 downto 5) = "011" then
      playback_div_limit <= 500;
    elsif switch(7 downto 5) = "001" then
      playback_div_limit <= 707;
    elsif switch(4 downto 2) = "111" then
      playback_div_limit <= 2828;
    elsif switch(4 downto 2) = "011" then
      playback_div_limit <= 2000;
    elsif switch(4 downto 2) = "001" then
      playback_div_limit <= 1414;
    else
      playback_div_limit <= 1000;
    end if;
  end process;

  process_playback : process (clk_11MHz, reset)
  begin
    if reset = '1' then
      playback_div_counter <= 0;
    elsif (clk_11MHz'event and clk_11MHz = '1') then
      if playback_div_counter < playback_div_limit - 1 then
        playback_div_counter <= playback_div_counter + 1;
        playback_event       <= '0';
      else
        playback_event       <= '1';
        playback_div_counter <= 0;
      end if;
    end if;
  end process;

  process_11khz : process (clk_11MHz, reset)
  begin
    if reset = '1' then
      freq_divider_counter <= 0;
    elsif (clk_11MHz'event and clk_11MHz = '1') then
      if freq_divider_counter < 999 then
        freq_divider_counter <= freq_divider_counter + 1;
        freq_divider_event   <= '0';
      else
        freq_divider_event   <= '1';
        freq_divider_counter <= 0;
      end if;
    end if;
  end process;

  write_enable <= "1" when freq_divider_event = '1' and record_pressed = '1' else
    "0";

  addra <= std_logic_vector(to_unsigned(addr_counter_a, addra'length));
  addrb <= std_logic_vector(to_unsigned(addr_counter_b, addrb'length));

  AC_MCLK <= AC_MCLK_i;

  process_addr : process (clk_11MHz, reset)
  begin
    if reset = '1' then
      addr_counter_a <= 0;
      addr_counter_b <= 0;
    elsif (clk_11MHz'event and clk_11MHz = '1') then
      if freq_divider_event = '1' and record_pressed = '1' then
        if addr_counter_a < 110999 then
          addr_counter_a <= addr_counter_a + 1;
        else
          addr_counter_a <= 0;
        end if;
      end if;

      if playback_event = '1' and play_pause = '1' then
        if addr_counter_b < 110999 then
          addr_counter_b <= addr_counter_b + 1;
        else
          addr_counter_b <= 0;
        end if;
      end if;
    end if;
  end process;

  process (clk_48MHz)
  begin
    if (clk_48MHz = '1' and clk_48MHz'event) then
      switch_reg <= switch & "0" & mute;
    end if;
  end process;
  process (clk_48MHz)
  begin
    if (clk_48MHz = '1' and clk_48MHz'event) then
      LEDs <= switch_reg;
    end if;
  end process;

  process (clk_48MHz)
  begin
    if (clk_48MHz = '1' and clk_48MHz'event) then
      if mute = '1' then
        hphone_l <= (others => '0');
        hphone_r <= (others => '0');
      else
        hphone_l <= line_in_l;
        hphone_r <= line_in_r;
      end if;
    end if;
  end process;

end Behavioral;