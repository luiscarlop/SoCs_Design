--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:22:33 03/17/2026
-- Design Name:   
-- Module Name:   V:/LAB_1E/utTOP_fancyPixels.vhd
-- Project Name:  LAB_1E
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TOP_fancyPixels
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
 
ENTITY utTOP_fancyPixels IS
END utTOP_fancyPixels;
 
ARCHITECTURE behavior OF utTOP_fancyPixels IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TOP_fancyPixels
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         rgb_in : IN  std_logic_vector(11 downto 0);
         rgb_out : OUT  std_logic_vector(11 downto 0);
         sync_h : OUT  std_logic;
         sync_v : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal rgb_in : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal rgb_out : std_logic_vector(11 downto 0);
   signal sync_h : std_logic;
   signal sync_v : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TOP_fancyPixels PORT MAP (
          clk => clk,
          reset => reset,
          rgb_in => rgb_in,
          rgb_out => rgb_out,
          sync_h => sync_h,
          sync_v => sync_v
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
      rgb_in <= (others => '0');

      wait;
   end process;

END;
