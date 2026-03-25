--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:23:10 03/25/2026
-- Design Name:   
-- Module Name:   V:/LAB_3A/tbTOP_ROMPixelArt.vhd
-- Project Name:  LAB_3A
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TOP_ROMPixelArt
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tbTOP_ROMPixelArt IS
END tbTOP_ROMPixelArt;
 
ARCHITECTURE behavior OF tbTOP_ROMPixelArt IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TOP_ROMPixelArt
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         selector : IN  std_logic;
         rgb_in : IN  std_logic_vector(11 downto 0);
         sync_h : OUT  std_logic;
         sync_v : OUT  std_logic;
         rgb_out : OUT  std_logic_vector(11 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal selector : std_logic := '0';
   signal rgb_in : std_logic_vector(11 downto 0);
 	--Outputs
   signal sync_h : std_logic;
   signal sync_v : std_logic;
   signal rgb_out : std_logic_vector(11 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TOP_ROMPixelArt PORT MAP (
          clk => clk,
          reset => reset,
          selector => selector,
          rgb_in => rgb_in,
          sync_h => sync_h,
          sync_v => sync_v,
          rgb_out => rgb_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin	
      -- hold reset state for 100 ns.
      reset <= '1';
      wait for 100 ns;
      reset <= '0';

      rgb_in <= (others => '0');
      selector <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
