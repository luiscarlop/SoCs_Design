--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:29:29 05/07/2026
-- Design Name:   
-- Module Name:   V:/LAB_3B/tbTOP_RAM_memory.vhd
-- Project Name:  LAB_3B
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TOP_RAM_memory
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
 
ENTITY tbTOP_RAM_memory IS
END tbTOP_RAM_memory;
 
ARCHITECTURE behavior OF tbTOP_RAM_memory IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TOP_RAM_memory
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         btn : IN  std_logic;
         row_select : IN  std_logic_vector(3 downto 0);
         col_select : IN  std_logic_vector(3 downto 0);
         color_in : IN  std_logic_vector(11 downto 0);
         sync_h : OUT  std_logic;
         sync_v : OUT  std_logic;
         rgb_out : OUT  std_logic_vector(11 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal btn : std_logic := '0';
   signal row_select : std_logic_vector(3 downto 0) := (others => '0');
   signal col_select : std_logic_vector(3 downto 0) := (others => '0');
   signal color_in : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal sync_h : std_logic;
   signal sync_v : std_logic;
   signal rgb_out : std_logic_vector(11 downto 0);
	
	constant TARGET_ROW  : integer := 5;
    constant TARGET_COL  : integer := 7;
    constant TARGET_ADDR : integer := TARGET_ROW * 16 + TARGET_COL; -- 87

    constant COLOR_RED   : unsigned(11 downto 0) := x"F00"; -- R=F G=0 B=0
    constant COLOR_BLACK : unsigned(11 downto 0) := x"000";

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TOP_RAM_memory PORT MAP (
          clk => clk,
          reset => reset,
          btn => btn,
          row_select => row_select,
          col_select => col_select,
          color_in => color_in,
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
      -- Wait for global reset to finish
      wait for 100 ns;

      row_select <= std_logic_vector(to_unsigned(TARGET_ROW, 4));
      col_select <= std_logic_vector(to_unsigned(TARGET_COL, 4));
      color_in <= std_logic_vector(COLOR_RED);
      btn <= '1'; -- Simulate button press to write to RAM

      wait for 6 ms; -- Wait for the write operation to complete
      btn <= '0'; -- Release button
      wait for 10 ms; -- Wait to observe the change on the VGA output
      -- insert stimulus here 

      wait;
   end process;

END;
