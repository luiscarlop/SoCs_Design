# LAB_4A Project (ISE)

This project is now a minimal STM-only design with one top file and one testbench.

## Folder
- `LAB_4A/`

## Included Files
- `LAB_4A.xise`: ISE project for the button-counter STM design
- `ButtonCounterStm.vhd`: top-level button counter with internal debounce state machine
- `tbButtonCounterStm.vhd`: behavioral simulation testbench

## Moved To /modules
- `ROM_memory.vhd`
- `ROM_pkg.vhd`
- `VGA_module.vhd`
- `VGA_PixelArt_pinout.ucf`
- `antiBouncesSTM.vhd`

## How To Use
1. Open `LAB_4A/LAB_4A.xise` in Xilinx ISE 14.7.
2. Verify top module is `ButtonCounterStm`.
3. Run behavioral simulation with `tbButtonCounterStm`.
4. Run Synthesize and Implement as needed.

## Notes
- LAB_4A keeps source/configuration files only.
- Internal project design name is set to `LAB_4A`.
