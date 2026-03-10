----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:33:52 03/03/2026 
-- Design Name: 
-- Module Name:    TOP_mmcm - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TOP_mmcm is
    Port (  clk_in : in STD_LOGIC;
            reset : in STD_LOGIC;
            clk_in_out : out STD_LOGIC;
            clk_1 : out STD_LOGIC;
            clk_2 : out STD_LOGIC;
            clk_3 : out STD_LOGIC;
            clk_4 : out STD_LOGIC;
            clk_5 : out STD_LOGIC);
end TOP_mmcm;

architecture Behavioral of TOP_mmcm is

    signal CLKIN1   : STD_LOGIC;
    signal CLKOUT0  : STD_LOGIC;
    signal CLKOUT1  : STD_LOGIC;
    signal CLKOUT2  : STD_LOGIC;
    signal CLKOUT3  : STD_LOGIC;
    signal CLKOUT4  : STD_LOGIC;
    signal CLKFBOUT : STD_LOGIC;
    signal CLKFBIN  : STD_LOGIC;

begin
    MMCME2_BASE_inst : MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
        CLKFBOUT_MULT_F => 12.0,   -- Multiply value for all CLKOUT (2.000-64.000). VCO = 100MHz * 12 = 1200 MHz
        CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
        CLKIN1_PERIOD => 10.0,     -- Input clock period in ns (100 MHz = 10.0 ns).
        -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        CLKOUT1_DIVIDE => 10,      -- 1200 MHz / 10  = 120 MHz
        CLKOUT2_DIVIDE => 12,      -- 1200 MHz / 12  = 100 MHz
        CLKOUT3_DIVIDE => 20,      -- 1200 MHz / 20  =  60 MHz
        CLKOUT4_DIVIDE => 48,      -- 1200 MHz / 48  =  25 MHz
        --CLKOUT5_DIVIDE => 1,     -- not used
        --CLKOUT6_DIVIDE => 1,     -- not used
        CLKOUT0_DIVIDE_F => 7.5,   -- 1200 MHz / 7.5 = 160 MHz
        -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT1_DUTY_CYCLE => 0.5,
        CLKOUT2_DUTY_CYCLE => 0.5,
        CLKOUT3_DUTY_CYCLE => 0.5,
        CLKOUT4_DUTY_CYCLE => 0.5,
        --CLKOUT5_DUTY_CYCLE => 0.5,  -- not used
        --CLKOUT6_DUTY_CYCLE => 0.5,  -- not used
        -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
        CLKOUT0_PHASE => 0.0,
        CLKOUT1_PHASE => 0.0,
        CLKOUT2_PHASE => 0.0,
        CLKOUT3_PHASE => 0.0,
        CLKOUT4_PHASE => 0.0,
        --CLKOUT5_PHASE => 0.0,  -- not used
        --CLKOUT6_PHASE => 0.0,  -- not used
        CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
        REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
        STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
    )
    port map (
        -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0 => CLKOUT0,     -- 1-bit output: CLKOUT0  (160 MHz -> clk_1)
        CLKOUT0B => open,       -- 1-bit output: Inverted CLKOUT0 (not used)
        CLKOUT1 => CLKOUT1,     -- 1-bit output: CLKOUT1  (120 MHz -> clk_2)
        CLKOUT1B => open,       -- 1-bit output: Inverted CLKOUT1 (not used)
        CLKOUT2 => CLKOUT2,     -- 1-bit output: CLKOUT2  (100 MHz -> clk_3)
        CLKOUT2B => open,       -- 1-bit output: Inverted CLKOUT2 (not used)
        CLKOUT3 => CLKOUT3,     -- 1-bit output: CLKOUT3  ( 60 MHz -> clk_4)
        CLKOUT3B => open,       -- 1-bit output: Inverted CLKOUT3 (not used)
        CLKOUT4 => CLKOUT4,     -- 1-bit output: CLKOUT4  ( 25 MHz -> clk_5)
        CLKOUT5 => open,        -- 1-bit output: CLKOUT5 (not used)
        CLKOUT6 => open,        -- 1-bit output: CLKOUT6 (not used)
        -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
        CLKFBOUT => CLKFBOUT,   -- 1-bit output: Feedback clock
        CLKFBOUTB => open,      -- 1-bit output: Inverted CLKFBOUT (not used)
        -- Status Ports: 1-bit (each) output: MMCM status ports
        LOCKED => open,         -- 1-bit output: LOCK (not used)
        -- Clock Inputs: 1-bit (each) input: Clock input
        CLKIN1 => CLKIN1,       -- 1-bit input: Clock
        -- Control Ports: 1-bit (each) input: MMCM control ports
        PWRDWN => '0',          -- 1-bit input: Power-down (tied low)
        RST => reset,           -- 1-bit input: Reset
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN => CLKFBIN      -- 1-bit input: Feedback clock
    );
        
    IBUFG_inst : IBUFG
    port map (
        O => CLKIN1, -- Clock buffer output
        I => clk_in  -- Clock buffer input (connect directly to top-level port)
    );

    BUFG_inst_clkout0 : BUFG
    port map (
        O => clk_1, -- 1-bit output: Clock output
        I => CLKOUT0  -- 1-bit input: Clock input
    );

    BUFG_inst_clkout1 : BUFG
    port map (
        O => clk_2, -- 1-bit output: Clock output
        I => CLKOUT1  -- 1-bit input: Clock input
    );

    BUFG_inst_clkout2 : BUFG
    port map (
        O => clk_3, -- 1-bit output: Clock output
        I => CLKOUT2  -- 1-bit input: Clock input
    );

    BUFG_inst_clkout3 : BUFG
    port map (
        O => clk_4, -- 1-bit output: Clock output (60 MHz)
        I => CLKOUT3  -- 1-bit input: Clock input
    );

    BUFG_inst_clkout4 : BUFG
    port map (
        O => clk_5, -- 1-bit output: Clock output (25 MHz)
        I => CLKOUT4  -- 1-bit input: Clock input
    );

    BUFG_inst_clkfbout : BUFG
    port map (
        O => CLKFBIN, -- 1-bit output: Clock output
        I => CLKFBOUT  -- 1-bit input: Clock input
    );

    clk_in_out <= CLKIN1; -- Connect input clock to output port for measurement

end Behavioral;

