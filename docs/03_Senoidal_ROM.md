# Specifications: Sinusoidal ROM (`sine_rom.vhd`)

## 1. Description
This module acts as a Look-Up Table (LUT). It stores a complete period of a pre-calculated sinusoidal wave. It receives a phase (address) and returns the corresponding amplitude (data).

## 2. Ports (Entity)
* `clk` : in STD_LOGIC
* `addr_in` : in STD_LOGIC_VECTOR (7 downto 0)
* `sine_out` : out STD_LOGIC_VECTOR (7 downto 0)

## 3. Design Instructions (RTL)
1. **Array Definition:** You must define a custom array data type for the ROM memory of 256 words, 8 bits each:
   `type rom_type is array (255 downto 0) of std_logic_vector (7 downto 0);`
2. **Constant Initialization:** Declare a constant of type `rom_type` and assign the 256 hexadecimal values of the sinusoidal wave (this code will be generated with an auxiliary Python script).
3. **Synchronous Read:** * Implement a process sensitive only to `clk`.
   * On the rising edge `(clk'event and clk = '1')`, assign to `sine_out` the value stored in the ROM constant pointed to by `addr_in`.
   * Converting the address to integer is necessary: `ROM(to_integer(unsigned(addr_in)))`.
