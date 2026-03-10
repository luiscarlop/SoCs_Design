--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:49:27 03/10/2026
-- Design Name:   
-- Module Name:   V:/LAB_2B/tbTOP_mmcm.vhd
-- Project Name:  LAB_2B
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TOP_mmcm
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
 
ENTITY tbTOP_mmcm IS
END tbTOP_mmcm;
 
ARCHITECTURE behavior OF tbTOP_mmcm IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TOP_mmcm
    PORT(
         clk_in : IN  std_logic;
         reset : IN  std_logic;
         clk_in_out : OUT  std_logic;
         clk_1 : OUT  std_logic;
         clk_2 : OUT  std_logic;
         clk_3 : OUT  std_logic;
         clk_4 : OUT  std_logic;
         clk_5 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal clk_in_out : std_logic;
   signal clk_1 : std_logic;
   signal clk_2 : std_logic;
   signal clk_3 : std_logic;
   signal clk_4 : std_logic;
   signal clk_5 : std_logic;

   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TOP_mmcm PORT MAP (
          clk_in => clk_in,
          reset => reset,
          clk_in_out => clk_in_out,
          clk_1 => clk_1,
          clk_2 => clk_2,
          clk_3 => clk_3,
          clk_4 => clk_4,
          clk_5 => clk_5
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      reset <= '1';
      wait for 100 ns;
      reset <= '0';

      -- run long enough to observe all clock outputs (slowest is clk_5 at 25 MHz = 40 ns period)
      wait for 5 us;

      wait;
   end process;

END;
