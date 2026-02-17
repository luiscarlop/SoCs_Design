--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:06:53 02/17/2026
-- Design Name:   
-- Module Name:   V:/LAB_1/tbLAB_1.vhd
-- Project Name:  LAB_1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LAB_1A
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
USE ieee.numeric_std.ALL;
 
ENTITY tbLAB_1 IS
END tbLAB_1;
 
ARCHITECTURE behavior OF tbLAB_1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LAB_1A
    PORT(
         rgb_in : IN  std_logic_vector(11 downto 0);
         rgb_out : OUT  std_logic_vector(11 downto 0);
         clk : IN  std_logic;
         reset : IN  std_logic;
         sync_h : OUT  std_logic;
         sync_v : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rgb_in : std_logic_vector(11 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal rgb_out : std_logic_vector(11 downto 0);
   signal sync_h : std_logic;
   signal sync_v : std_logic;

   -- Clock period definitions
   constant clk_period : time := 40 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LAB_1A PORT MAP (
          rgb_in => rgb_in,
          rgb_out => rgb_out,
          clk => clk,
          reset => reset,
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
      rgb_in <= (others => '1');
      reset <= '1';
      wait for 33ns;
      -- insert stimulus here 
      reset <= '0';


      wait;
   end process;

END;
