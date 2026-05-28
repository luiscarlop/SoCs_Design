-- Proyecto b�sico para adquisici�n y generacion de Audio.

-- A�adir MMCM para generar la se�al de reloj clk_48MHz a partir de la se�al de reloj de entrada clk_100_in (de 100 MHz)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library unisim;
use unisim.vcomponents.all;

entity audio is
    Port ( clk_100_in	: in    STD_LOGIC;
           AC_ADR0  	: out   STD_LOGIC;
           AC_ADR1		: out   STD_LOGIC;
           AC_GPIO0		: out   STD_LOGIC;  -- I2S MISO
           AC_GPIO1		: in    STD_LOGIC;  -- I2S MOSI
           AC_GPIO2		: in    STD_LOGIC;  -- I2S_bclk
           AC_GPIO3		: in    STD_LOGIC;  -- I2S_LR
           AC_MCLK		: out   STD_LOGIC;
           AC_SCK		: out   STD_LOGIC;
           AC_SDA		: inout STD_LOGIC;
			  
		   reset 		: in std_logic; -- BTNC
           switch		: in STD_LOGIC_VECTOR(7 downto 0);
		   LEDs 		: out std_logic_vector(7 downto 0);

		   mute			: in std_logic;					  -- SW0
		   delay_enable : in std_logic;					  -- SW1 -> 0: IN -> OUT, SW1 -> 1: IN -> DELAYED OUT
		   delay_select	: in std_logic_vector(1 downto 0) -- <01> -> BTNR, <10> -> BTNL
        );
end audio;

architecture Behavioral of audio is

-- declaracion componentes ---
	COMPONENT ADAU1761_controlador
	PORT(
		clk			: IN 	std_logic;
		AC_GPIO1	: IN 	std_logic;
		AC_GPIO2	: IN 	std_logic;
		AC_GPIO3	: IN 	std_logic;
		hphone_l	: IN 	std_logic_vector(15 downto 0);
		hphone_r	: IN 	std_logic_vector(15 downto 0);    
		AC_SDA 		: INOUT std_logic;      
		AC_ADR0		: OUT 	std_logic;
		AC_ADR1		: OUT 	std_logic;
		AC_GPIO0	: OUT 	std_logic;
		AC_MCLK		: OUT 	std_logic;
		AC_SCK 		: OUT 	std_logic;
		line_in_l	: OUT 	std_logic_vector(15 downto 0);
		line_in_r	: OUT 	std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT recorded_audio
	PORT (
		clka : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		clkb : IN STD_LOGIC;
		addrb : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
	END COMPONENT;

	component ButtonCounterContinous
        generic (
            STABILIZATION_TIME : integer := 500000;
            HOLD : boolean := false
        );
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               input : in STD_LOGIC;
               output : out STD_LOGIC);
    end component;
 -------------------------------------------


-- se�ales generales ---
signal clk_48MHz, clk_11MHz : std_logic;
signal switch_reg : std_logic_vector(7 downto 0);

signal CLKIN1 : STD_LOGIC;
signal CLKOUT0, CLKOUT1 : STD_LOGIC;
signal CLKFBIN  : STD_LOGIC;
signal CLKFBOUT : STD_LOGIC;
-------------------------------------------

constant DELAY_STEP_MS : integer := 250;

-- signals for delay control ---
signal delay_time : integer range 0 to 10000 := 0; -- Delay time in ms
signal increase_delay, decrease_delay : std_logic;
signal tick_1ms : std_logic;
signal counter_1ms : integer range 0 to 10999 := 0; -- 1ms with 11MHz clock
signal counter_event : integer range 0 to 40*DELAY_STEP_MS - 1 := 0; -- Max delay of 10s (40*250ms)
signal delay_samples : integer range 0 to 109999 := 0; -- Max samples for 10s delay at 11MHz

signal freq_divider_counter : integer range 0 to 999 := 0;
signal freq_divider_event : std_logic;
signal write_enable : std_logic_vector(0 downto 0);

-- señales Analog Devices Audio Codec 1761---
signal AC_MCLK_i : std_logic;
signal new_sample : std_logic;
signal line_in_l, line_in_r  : std_logic_vector(15 downto 0);
signal hphone_l, hphone_r   : std_logic_vector(15 downto 0);
-------------------------------------------

signal delayed_line_in_l, delayed_line_in_r : std_logic_vector(15 downto 0);
signal addra, addrb : std_logic_vector(16 downto 0); -- 17 bits for 128k samples
signal addr_counter_a : integer range 0 to 110999 := 0; -- Counter for addressing RAM (111k samples)
signal addr_counter_b : integer range 0 to 110999 := 0; -- Counter for addressing RAM (111k samples)

-- Declara componente para generar la se�al de reloj clk_48MHz -----
-- AQUI -------------------------------------------------------------
--------------------------------------------------------------------


begin

	modulo_ADAU1761_controlador: ADAU1761_controlador PORT MAP(
		clk	     => clk_48MHz,
		AC_ADR0    => AC_ADR0,
		AC_ADR1    => AC_ADR1,
		AC_GPIO0   => AC_GPIO0,
		AC_GPIO1   => AC_GPIO1,
		AC_GPIO2   => AC_GPIO2,
		AC_GPIO3   => AC_GPIO3,
		AC_MCLK    => AC_MCLK_i,
		AC_SCK     => AC_SCK,
		AC_SDA     => AC_SDA,
		hphone_l   => hphone_l,
		hphone_r   => hphone_r,
		line_in_l  => line_in_l,
		line_in_r  => line_in_r
	);

	Module_RAM_audio_l : recorded_audio
	PORT MAP (
		clka => clk_11MHz,
		wea => write_enable,
		addra => addra,
		dina => line_in_l,
		clkb => clk_48MHz,
		addrb => addrb,
		doutb => delayed_line_in_l
	);

	Module_RAM_audio_r : recorded_audio
	PORT MAP (
		clka => clk_11MHz,
		wea => write_enable,
		addra => addra,
		dina => line_in_r,
		clkb => clk_48MHz,
		addrb => addrb,
		doutb => delayed_line_in_r
	);

	Module_btn_increase_delay: ButtonCounterContinous
		generic map (
			STABILIZATION_TIME => 240000, -- 5ms at 48MHz
			HOLD => false
		)
		port map (
			clk => clk_48MHz,
			reset => reset,
			input => delay_select(0), -- BTNR
			output => increase_delay
		);

	Module_btn_decrease_delay: ButtonCounterContinous
		generic map (
			STABILIZATION_TIME => 240000, -- 5ms at 48MHz
			HOLD => false
		)
		port map (
			clk => clk_48MHz,
			reset => reset,
			input => delay_select(1), -- BTNL
			output => decrease_delay
		);

 	Module_MMCM: MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED",
        CLKFBOUT_MULT_F => 12.0, -- VCO = 100MHz * 12 = 1200 MHz
        CLKFBOUT_PHASE => 0.0,
        CLKIN1_PERIOD => 10.0,
        CLKOUT0_DIVIDE_F => 25.0, -- 1200 MHz / 25 = 48 MHz
        CLKOUT0_PHASE => 0.0,
		CLKOUT1_DIVIDE => 109,     -- 1200 MHz / 109 = 11 MHz
        CLKOUT1_PHASE => 0.0,

        CLKOUT4_CASCADE => FALSE,
        DIVCLK_DIVIDE => 1,
        REF_JITTER1 => 0.0,
        STARTUP_WAIT => FALSE
    )
    port map (
        CLKOUT0 => CLKOUT0,
        CLKOUT0B => open,
        CLKOUT1 => CLKOUT1,
        CLKOUT1B => open,
        CLKOUT2 => open,
        CLKOUT2B => open,
        CLKOUT3 => open,
        CLKOUT3B => open,
        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKOUT6 => open,
        CLKFBOUT => CLKFBOUT,
        CLKFBOUTB => open,
        LOCKED => open,
        CLKIN1 => CLKIN1,
        PWRDWN => '0',
        RST => reset,
        CLKFBIN => CLKFBIN
    );

    IBUFG_inst : IBUFG
    port map (
        O => CLKIN1,
        I => clk_100_in
    );

    BUFG_inst_clkout0 : BUFG
    port map (
        O => clk_48MHz,
        I => CLKOUT0
    );

	BUFG_inst_clkout1 : BUFG
    port map (
        O => clk_11MHz,
        I => CLKOUT1
    );

    BUFG_inst_clkfbout : BUFG
    port map (
        O => CLKFBIN,
        I => CLKFBOUT
    );

	-------------------------------------------------------------
	--              			PROCESS
	-------------------------------------------------------------
	process_11khz: process(clk_11MHz, reset)
	begin
		if reset = '1' then
			freq_divider_counter <= 0;
		elsif (clk_11MHz'event and clk_11MHz = '1') then
			if freq_divider_counter < 999 then
				freq_divider_counter <= freq_divider_counter + 1;
				freq_divider_event <= '0';
			else
				freq_divider_event <= '1';
				freq_divider_counter <= 0;
			end if;
		end if;
	end process;

	process_delay_control: process(clk_11MHz, reset)
	begin
		if reset = '1' then
			delay_time <= 0;
		elsif (clk_11MHz'event and clk_11MHz = '1') then
			if increase_delay = '1' and delay_time < 40*DELAY_STEP_MS then
				delay_time <= delay_time + DELAY_STEP_MS;
			elsif decrease_delay = '1' and delay_time >= DELAY_STEP_MS then
				delay_time <= delay_time - DELAY_STEP_MS;
			end if;
		end if;
	end process;

	write_enable <= "1" when freq_divider_event = '1' else "0";
	delay_samples <= delay_time * 11; -- 11 samples per ms at 11 MHz

	addra <= std_logic_vector(to_unsigned(addr_counter_a, addra'length));
	addrb <= std_logic_vector(to_unsigned(addr_counter_b, addrb'length));

	AC_MCLK <= AC_MCLK_i;

	process_addr: process(clk_11MHz, reset)
	begin
	if reset = '1' then
		addr_counter_a <= 0;
		addr_counter_b <= 0;
	elsif (clk_11MHz'event and clk_11MHz = '1') then
		if freq_divider_event = '1' then
			if addr_counter_a < 110999 then
				addr_counter_a <= addr_counter_a + 1;
			else
				addr_counter_a <= 0;
			end if;

			if delay_enable = '1' then
				if addr_counter_a >= delay_samples then
					addr_counter_b <= addr_counter_a - delay_samples;
				else
					addr_counter_b <= addr_counter_a + (111000 - delay_samples);
				end if;
			else
				addr_counter_b <= addr_counter_a; -- Directly pass through when delay is disabled
			end if;
		end if;
	end if;
	end process;

	process_counter_1ms: process(clk_11MHz, reset)
	begin
		if reset = '1' then
			counter_1ms <= 0;
		elsif (clk_11MHz'event and clk_11MHz = '1') then
			if counter_1ms <  10999 then
				counter_1ms <= counter_1ms + 1;
				tick_1ms <= '0';
			else
				tick_1ms <= '1';
				counter_1ms <= 0;
			end if;
		end if;
	end process;

	process_counter_event: process(clk_11MHz, reset)
	begin
		if reset = '1' then
			counter_event <= 0;
		elsif (clk_11MHz'event and clk_11MHz = '1') then
			if tick_1ms = '1' then
				if counter_event < delay_time - 1 then
					counter_event <= counter_event + 1;
				else
					counter_event <= 0;
				end if;
			end if;
		end if;
	end process;

	process(clk_48MHz)
	begin
		if (clk_48MHz = '1' and clk_48MHz'event) then
			switch_reg <= switch;
		end if;
	end process;


	process(clk_48MHz)
	begin
		if (clk_48MHz = '1' and clk_48MHz'event) then
				LEDs <= switch_reg;
		end if;
	end process;


		
	process(clk_48MHz)
	begin
		if (clk_48MHz = '1' and clk_48MHz'event) then
			if mute = '1' then
				hphone_l <= (others => '0');
				hphone_r <= (others => '0');
			elsif delay_enable = '1' then
				hphone_l <= delayed_line_in_l;
				hphone_r <= delayed_line_in_r;
			else
				hphone_l <= line_in_l;
				hphone_r <= line_in_r;
			end if;
		end if;
	end process;
   
end Behavioral;