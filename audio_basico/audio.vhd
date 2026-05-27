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
			  
--			  reset : in std_logic;
           switch		: in    STD_LOGIC_VECTOR(7 downto 0);
			  LEDs 		: out std_logic_vector(7 downto 0)
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
 -------------------------------------------


-- se�ales generales ---
signal clk_48MHz : std_logic;
signal switch_reg : std_logic_vector(7 downto 0);

signal CLKIN1 : STD_LOGIC;
signal CLKOUT0 : STD_LOGIC;
signal CLKFBIN : STD_LOGIC;
signal CLKFBOUT : STD_LOGIC;
 -------------------------------------------

 
 -- se�ales Analog Devices Audio Codec 1761---
signal AC_MCLK_i : std_logic;
signal new_sample : std_logic;
signal line_in_l, line_in_r  : std_logic_vector(15 downto 0);
signal hphone_l, hphone_r   : std_logic_vector(15 downto 0);
 -------------------------------------------


 -- Declara componente para generar la se�al de reloj clk_48MHz -----
 -- AQUI -------------------------------------------------------------
 --------------------------------------------------------------------


begin


 -- Instancia componente que genera la se�al de reloj clk_48MHz -----
 -- AQUI -------------------------------------------------------------
 --------------------------------------------------------------------
 Module_MMCM: MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED",
        CLKFBOUT_MULT_F => 12.0, -- VCO = 100MHz * 12 = 1200 MHz
        CLKFBOUT_PHASE => 0.0,
        CLKIN1_PERIOD => 10.0,
        CLKOUT0_DIVIDE_F => 25.0, -- 1200 MHz / 25 = 48 MHz
        CLKOUT0_PHASE => 0.0,
        CLKOUT4_CASCADE => FALSE,
        DIVCLK_DIVIDE => 1,
        REF_JITTER1 => 0.0,
        STARTUP_WAIT => FALSE
    )
    port map (
        CLKOUT0 => CLKOUT0,
        CLKOUT0B => open,
        CLKOUT1 => open,
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

    BUFG_inst_clkfbout : BUFG
    port map (
        O => CLKFBIN,
        I => CLKFBOUT
    );


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
			hphone_l <= line_in_l;
			hphone_r <= line_in_r;
      end if;
   end process;
	

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

	AC_MCLK <= AC_MCLK_i;


   
end Behavioral;