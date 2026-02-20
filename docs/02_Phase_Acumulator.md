# Specifications: Phase Accumulator (`phase_acum.vhd`)

## 1. Description
The phase accumulator is the engine of the DDS. It is a sequential system that stores the current state of the phase. In each clock cycle, it adds the "Tuning Word" received from the switches to its internal value. When it overflows, the wave cycle starts over.

## 2. Ports (Entity)
* `clk` : in STD_LOGIC
* `reset` : in STD_LOGIC
* `tuning_word` : in STD_LOGIC_VECTOR (7 downto 0)
* `phase_out` : out STD_LOGIC_VECTOR (15 downto 0)

## 3. Design Instructions (RTL)
1. **Libraries:** Make sure to include `IEEE.NUMERIC_STD.ALL` to use `unsigned` types in arithmetic operations.
2. **Internal Signal:** Declare an internal signal `phase_reg` of type `unsigned(15 downto 0)` to maintain the sum state.
3. **Sequential Process:** * Sensitive to `clk` and `reset`.
   * The reset must be asynchronous and should only be used for system initialization, setting the internal signal to zero.
   * Strict design rule: Use `elsif (clk'event and clk = '1') then` for rising edge detection.
4. **Addition:** On the rising edge, `phase_reg` must be updated by adding its current value plus `tuning_word`. 
   * *Warning:* Since `tuning_word` is 8 bits and the register is 16, you must extend/cast `tuning_word` by concatenating zeros to the left or using the `resize()` function from `numeric_std`.
5. **Combinational Output:** Assign the value of the internal signal to the output port `phase_out` outside the process (casting to `std_logic_vector`).
