--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:24:25 04/20/2026
-- Design Name:   
-- Module Name:   V:/LAB_4A/tbButtonCounterStm.vhd
-- Project Name:  LAB_4A
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ButtonCounterStm
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
 
ENTITY tbButtonCounterStm IS
END tbButtonCounterStm;
 
ARCHITECTURE behavior OF tbButtonCounterStm IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ButtonCounterStm
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         BTN : IN  std_logic_vector(3 downto 0);
         CounterSelector : IN  std_logic_vector(1 downto 0);
         PressCounterOut : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal BTN : std_logic_vector(3 downto 0) := (others => '0');
   signal CounterSelector : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal PressCounterOut : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ButtonCounterStm PORT MAP (
          clk => clk,
          reset => reset,
          BTN => BTN,
          CounterSelector => CounterSelector,
          PressCounterOut => PressCounterOut
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
        CounterSelector <= "00"; -- select UP counter
        
        BTN <= "0001"; -- press UP button
        wait for 10 ms;
        BTN <= "0000"; -- release UP button
        wait for 10 ms;
        BTN <= "0010"; -- press DOWN button
        wait for 10 ms;
        BTN <= "0000"; -- release DOWN button
        wait for 10 ms;
        BTN <= "0001"; -- press UP button again
        wait for 10 ms;
        BTN <= "0000"; -- release UP button
        wait for 10 ms;
        PressRIGHTbutton : for i in 0 to 10 loop
            BTN <= "0100"; -- press RIGHT button
            wait for 10 ms;
            BTN <= "0000"; -- release RIGHT button
            wait for 10 ms;
        end loop; -- PressRIGHTbutton
        CounterSelector <= "10"; -- select DOWN counter
        wait for 10 ms;
        CounterSelector <= "11"; -- select RIGHT counter


        -- insert stimulus here 

      wait;
   end process;

END;
