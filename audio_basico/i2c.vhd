----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: A controller to send I2C commands to the ADAU1761 codec
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity i2c is
    Port ( clk : in  STD_LOGIC;
           i2c_sda_i : IN std_logic;      
           i2c_sda_o : OUT std_logic;      
           i2c_sda_t : OUT std_logic;      
           i2c_scl : out  STD_LOGIC);
end i2c;

architecture Behavioral of i2c is

 component i3c2 is
   Generic( clk_divide : STD_LOGIC_VECTOR (7 downto 0):=(others=>'0'));  
    Port ( clk : in  STD_LOGIC;
           inst_address : out  STD_LOGIC_VECTOR (9 downto 0);
           inst_data : in  STD_LOGIC_VECTOR (8 downto 0);
           i2c_scl : out  STD_LOGIC := '1';
           i2c_sda_i : in  STD_LOGIC;
           i2c_sda_o : out  STD_LOGIC := '0';
           i2c_sda_t : out STD_LOGIC := '1';
           inputs : in  STD_LOGIC_VECTOR (15 downto 0);
           outputs : out  STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
           reg_addr : out  STD_LOGIC_VECTOR (4 downto 0);
           reg_data : out  STD_LOGIC_VECTOR (7 downto 0);
           reg_write : out  STD_LOGIC;
           debug_scl : out  STD_LOGIC := '1';
           debug_sda : out  STD_LOGIC;
           error : out STD_LOGIC);
end component;

 component ADAU1761_configuration_data
	PORT(
		clk     : IN std_logic;
		address : IN std_logic_vector(9 downto 0);          
		data    : OUT std_logic_vector(8 downto 0)
		);
 end component;
   
   signal inst_address : std_logic_vector(9 downto 0);          
   signal inst_data    : std_logic_vector(8 downto 0);
	
	
begin

	modulo_adau1761_configuration_data: adau1761_configuration_data PORT MAP
		(
			clk     => clk,
			address => inst_address,
			data    => inst_data
		);

	modulo_i3c2: i3c2 
		GENERIC MAP 
		 (
			clk_divide => "01111000"   -- 120 (48,000/120 = 400kHz I2C clock)
		 ) 
		PORT MAP
		 (
			clk 				=> clk,
			inst_address	=> inst_address,
			inst_data		=> inst_data,
			i2c_scl			=> i2c_scl,
			i2c_sda_i		=> i2c_sda_i,
			i2c_sda_o		=> i2c_sda_o,
			i2c_sda_t		=> i2c_sda_t,
			inputs			=> (others => '0'),
			outputs			=> open,
			reg_addr			=> open,
			reg_data			=> open,
			reg_write		=> open,
			debug_scl		=> open,
			debug_sda		=> open,
			error 			=> open
		);

end Behavioral;




