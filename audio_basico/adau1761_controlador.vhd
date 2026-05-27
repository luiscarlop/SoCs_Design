----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Create Date:    19:23:40 01/06/2014 
-- Module Name:    adau1761_test - Behavioral 
-- Description:  Implement a Line in => I2S => FPGA => I2S => Headphones 
--               using the ADAU1761 codec
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library unisim;
use unisim.vcomponents.all;

entity ADAU1761_controlador is
    Port ( clk    	: in  STD_LOGIC;
           AC_ADR0   : out   STD_LOGIC;
           AC_ADR1   : out   STD_LOGIC;
           AC_GPIO0  : out   STD_LOGIC;  -- I2S MISO
           AC_GPIO1  : in    STD_LOGIC;  -- I2S MOSI
           AC_GPIO2  : in    STD_LOGIC;  -- I2S_bclk
           AC_GPIO3  : in    STD_LOGIC;  -- I2S_LR
           AC_MCLK   : out   STD_LOGIC;
           AC_SCK    : out   STD_LOGIC;
           AC_SDA    : inout STD_LOGIC;
           hphone_l  : in    std_logic_vector(15 downto 0);
           hphone_r  : in    std_logic_vector(15 downto 0);
           line_in_l : out   std_logic_vector(15 downto 0);
           line_in_r : out   std_logic_vector(15 downto 0)
--         new_sample: out   std_logic
        );
end ADAU1761_controlador;


architecture Behavioral of ADAU1761_controlador is

	COMPONENT i2c
	PORT(
		clk       : IN std_logic;    
		i2c_sda_i : IN std_logic;      
		i2c_sda_o : OUT std_logic;      
		i2c_sda_t : OUT std_logic;      
		i2c_scl   : OUT std_logic);
	END COMPONENT;

	COMPONENT I2S_data_interface
	PORT(
		clk         : IN  std_logic;
		audio_l_in  : IN  std_logic_vector(15 downto 0);
		audio_r_in  : IN  std_logic_vector(15 downto 0);
		i2s_bclk    : IN  std_logic;
		i2s_lr      : IN  std_logic;          
		audio_l_out : OUT std_logic_vector(15 downto 0);
		audio_r_out : OUT std_logic_vector(15 downto 0);
		new_sample  : OUT std_logic;
		i2s_d_out   : OUT std_logic;
		i2s_d_in    : IN  std_logic
		);
	END COMPONENT;

   signal codec_master_clk    : std_logic;

   signal i2c_scl   : std_logic;
   signal i2c_sda_i : std_logic;
   signal i2c_sda_o : std_logic;
   signal i2c_sda_t : std_logic;
   
   signal i2s_mosi  : std_logic;
   signal i2s_miso  : std_logic;
   signal i2s_bclk  : std_logic;
   signal i2s_lr    : std_logic;

begin
   AC_ADR0       <= '1';
   AC_ADR1       <= '1';
   AC_GPIO0      <= i2s_MISO;
   i2s_MOSI      <= AC_GPIO1;
   i2s_bclk      <= AC_GPIO2;
   i2s_lr        <= AC_GPIO3;
   AC_MCLK       <= codec_master_clk;
   AC_SCK        <= i2c_scl;
   
process(clk)
   begin
      if (clk = '1' and clk'event) then
         codec_master_clk <= not codec_master_clk;
      end if;
   end process;


	i2s_sda_obuf : IOBUF
   port map (
      IO => AC_SDA,   -- Buffer inout port (connect directly to top-level port)
      O => i2c_sda_i, -- Buffer output (to fabric)
      I => i2c_sda_o, -- Buffer input  (from fabric)
      T => i2c_sda_t  -- 3-state enable input, high=input, low=output 
   );
   
	modulo_i2c: i2c PORT MAP(
		clk       => clk,
		i2c_sda_i => i2c_sda_i,
		i2c_sda_o => i2c_sda_o,
		i2c_sda_t => i2c_sda_t,
		i2c_scl   => i2c_scl
	);
     
   
	modulo_i2s_data_interface: i2s_data_interface PORT MAP(
		clk         => clk,
		audio_l_out => line_in_l,
		audio_r_out => line_in_r,
		audio_l_in  => hphone_l,
		audio_r_in  => hphone_r,
--		new_sample  => new_sample,

		i2s_bclk    => i2s_bclk,
		i2s_d_out   => i2s_MISO,
		i2s_d_in    => i2s_MOSI,
		i2s_lr      => i2s_lr
	);
end Behavioral;