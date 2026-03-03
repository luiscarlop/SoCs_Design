--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:57:19 03/03/2026
-- Design Name:   
-- Module Name:   V:/LAB_1C/tbLAB_1C.vhd
-- Project Name:  LAB_1C
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TOP_module
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
 
ENTITY tbLAB_1C IS
END tbLAB_1C;
 
ARCHITECTURE behavior OF tbLAB_1C IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TOP_module
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable_1MHz_out : OUT  std_logic;
         enable_48KHz_out : OUT  std_logic;
         enable_22kHz_out : OUT  std_logic;
         enable_7kHz_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal enable_1MHz_out : std_logic;
   signal enable_48KHz_out : std_logic;
   signal enable_22kHz_out : std_logic;
   signal enable_7kHz_out : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TOP_module PORT MAP (
          clk => clk,
          reset => reset,
          enable_1MHz_out => enable_1MHz_out,
          enable_48KHz_out => enable_48KHz_out,
          enable_22kHz_out => enable_22kHz_out,
          enable_7kHz_out => enable_7kHz_out
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

      -- insert stimulus here

      wait;
   end process;

END;
