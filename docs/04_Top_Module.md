# Specifications: Top Module (`Top_DDS.vhd`)

## 1. Description
This is the main module that will be mapped to the physical pins of the ZedBoard. Its only function is structural: to instantiate the design components and route them.

## 2. Ports (Entity)
* `clk` : in STD_LOGIC
* `reset` : in STD_LOGIC
* `sw_tuning` : in STD_LOGIC_VECTOR (7 downto 0)
* `sine_out` : out STD_LOGIC_VECTOR (7 downto 0)

## 3. Design Instructions (Structural)
1. **Component Declaration:** In the declarative zone of the architecture (before `begin`), use the `component` keyword to declare `phase_acum` and `sine_rom` with the exact ports you defined in their files.
2. **Internal Wires:** Declare an internal signal `phase_wire` of 16 bits (`STD_LOGIC_VECTOR`) to connect the accumulator output with the ROM input.
3. **Instantiation (Port Map):**
   * Instantiate the `phase_acum` connecting the external pins `clk`, `reset` and `sw_tuning` to its inputs, and map its output to `phase_wire`.
   * Instantiate the `sine_rom` connecting the `clk`. 
   * **Phase Truncation:** Connect to the ROM's `addr_in` input *only* the 8 most significant bits of the internal wire: `phase_wire(15 downto 8)`.
   * Connect the ROM output directly to the external port `sine_out`.

