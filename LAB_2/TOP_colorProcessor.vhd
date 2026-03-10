----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:48:26 02/24/2026 
-- Design Name: 
-- Module Name:    TOP_colorProcessor - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP_colorProcessor is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rgb_in : in  STD_LOGIC_VECTOR (11 downto 0);
           rgb_out : out  STD_LOGIC_VECTOR (11 downto 0);
           sync_h : out  STD_LOGIC;
           sync_v : out  STD_LOGIC
           );
end TOP_colorProcessor;

architecture Behavioral of TOP_colorProcessor is
    -- component clkEnable      -- Ignore for implementing MMCM --
    --     generic (   N : positive := 3;
    --                 LIMIT : positive := 6);

    --     Port ( clk : in  STD_LOGIC;
    --            reset : in  STD_LOGIC;
    --            enable : out  STD_LOGIC);
    -- end component;

    component VGA
        Port ( enable : in  STD_LOGIC;
               clk : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               sync_h : out  STD_LOGIC;
               sync_v : out  STD_LOGIC;
               inhibColor : out  STD_LOGIC);
    end component;

    signal CLKIN1 : STD_LOGIC;
    signal CLKOUT0 : STD_LOGIC;
    signal CLKFBIN : STD_LOGIC;
    signal CLKFBOUT : STD_LOGIC;
    signal clk_25MHz : STD_LOGIC;
    signal inhibColor : STD_LOGIC;

begin
    -- Module_clkEnable_25MHz: clkEnable
    --     generic map (
    --         N => 2,
    --         LIMIT => 4
    --     )
    --     Port map (
    --         clk => clk,
    --         reset => reset,
    --         enable => clk_25MHz
    --     );

    Module_MMCM: MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
        CLKFBOUT_MULT_F => 12.0,   -- Multiply value for all CLKOUT (2.000-64.000). VCO = 100MHz * 12 = 1200 MHz
        CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
        CLKIN1_PERIOD => 10.0,     -- Input clock period in ns (100 MHz = 10.0 ns).
        -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        CLKOUT0_DIVIDE_F => 48.0,   -- 1200 MHz / 48 = 25 MHz
        CLKOUT0_PHASE => 0.0,

        CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
        REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
        STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
    )
    port map (
        -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0 => CLKOUT0,     -- 1-bit output: CLKOUT0  (160 MHz -> clk_1)
        CLKOUT0B => open,       -- 1-bit output: Inverted CLKOUT0 (not used)
        CLKOUT1 => open,     -- 1-bit output: CLKOUT1  (120 MHz -> clk_2)
        CLKOUT1B => open,       -- 1-bit output: Inverted CLKOUT1 (not used)
        CLKOUT2 => open,     -- 1-bit output: CLKOUT2  (100 MHz -> clk_3)
        CLKOUT2B => open,       -- 1-bit output: Inverted CLKOUT2 (not used)
        CLKOUT3 => open,     -- 1-bit output: CLKOUT3  ( 60 MHz -> clk_4)
        CLKOUT3B => open,       -- 1-bit output: Inverted CLKOUT3 (not used)
        CLKOUT4 => open,     -- 1-bit output: CLKOUT4  ( 25 MHz -> clk_5)
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
        I => clk  -- Clock buffer input (connect directly to top-level port)
    );

    BUFG_inst_clkout0 : BUFG
    port map (
        O => clk_25Mhz, -- 1-bit output: Clock output
        I => CLKOUT0  -- 1-bit input: Clock input
    );

    BUFG_inst_clkfbout : BUFG
    port map (
        O => CLKFBIN, -- 1-bit output: Clock output
        I => CLKFBOUT  -- 1-bit input: Clock input
    );

    Module_VGA: VGA
        Port map (
            enable => '1',
            clk => clk_25MHz,
            reset => reset,
            sync_h => sync_h,
            sync_v => sync_v,
            inhibColor => inhibColor
        );

    rgb_out_process: process(clk_25MHz, reset)
    begin
        if reset = '1' then
            rgb_out <= (others => '0');
        elsif(clk_25MHz'event and clk_25MHz = '1') then
            -- if clk_25MHz = '1' then
                if inhibColor = '1' then
                    rgb_out <= (others => '0');
                else
                    rgb_out <= rgb_in;
                -- end if;
            end if;
        end if;
    end process;

end Behavioral;
