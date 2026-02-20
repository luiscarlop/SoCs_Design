# Phase 1: Baseband Direct Digital Synthesizer (DDS)

## 1. System Description
This project implements a pure DDS (Direct Digital Synthesizer) carrier generator in hardware (Programmable Logic of the Zynq-7000). The goal is to generate a digital sinusoidal signal whose frequency can be tuned in real-time using external switches, without altering the system's master clock.



This design follows a hierarchical methodology, dividing the system into smaller modules to manage complexity.

## 2. Global Specifications
* **System Clock (clk):** 100 MHz (GCLK from the ZedBoard).
* **Reset:** Asynchronous, active high.
* **Input Interface:** 8 bits (Switches SW0-SW7). Defines the "Tuning Word" ($M$).
* **Output Interface:** 8 bits. Digital amplitude of the sinusoidal wave.
* **Phase Accumulator Resolution ($N$):** 16 bits.
* **ROM Depth:** 256 memory positions ($2^8$).

## 3. Design Hierarchy
The design consists of three VHDL modules:
1. `phase_acum.vhd`: Phase accumulator (computation module).
2. `sine_rom.vhd`: ROM memory with pre-calculated wave values.
3. `Top_DDS.vhd`: Top entity that instantiates and interconnects the two previous modules.

