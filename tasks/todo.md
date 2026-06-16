# Task Plan

- [x] Inspect LAB_2 source/project files
- [x] Create LAB_4A scaffold from LAB_2
- [x] Update project metadata names for LAB_4A
- [x] Add docs page for LAB_4A
- [x] Validate resulting structure

## Review
- LAB_4A scaffold created from LAB_2 source-only files.
- ISE project metadata updated for LAB_4A naming and testbench root.
- Documentation added at docs/05_LAB_4A_Project.md.

## Fixes (STM Migration)
- [x] Replace LAB_4A source set with LAB_3A modules
- [x] Repoint LAB_4A.xise to TOP_ROMPixelArt and STM testbench
- [x] Keep internal design name as LAB_4A
- [x] Remove leftover non-source artifacts in LAB_4A
- [x] Update LAB_4A documentation for STM module set

## LAB_4C Scaffold
- [x] Create LAB_4C directory and base project file
- [x] Create minimal TOP template (entity + Behavioral architecture)
- [x] Point project to shared modules folder (`../modules`)
- [x] Update LAB_4C project metadata and simulation top

## Review (LAB_4C)
- LAB_4C project created as a clean template based on LAB_4A.
- Top source is a minimal `ButtonCounterStm` template with empty Behavioral architecture.
- Project references shared `../modules/antiBouncesSTM.vhd` and removes testbench references.

## LAB_5 Project File
- [x] Replace local anti-bounce source with shared `modules/buttonCounterContinous.vhd` and `modules/movement_stm.vhd`
- [x] Verify LAB_5.xise source associations stay in compile order

## Review (LAB_5 Project File)
- LAB_5.xise now references `../modules/buttonCounterContinous.vhd` and `../modules/movement_stm.vhd`.
- The local `antiBouncesSTM.vhd` entry was removed from the project source list.

## LAB_6C Audio Record/Playback Fix

**Goal:** Make LAB_6C record line-in audio into RAM with BTNR and play recorded audio with BTNL, using switches SW2-SW7 to change playback pitch.

**Root-cause evidence:**
- `LAB_6C/audio.syr` reports `doutb` from both `recorded_audio` RAM instances as loadless/unconnected.
- `LAB_6C/audio.vhd` currently drives `hphone_l/r` from live `line_in_l/r`, so playback never uses the recorded samples.
- Pitch control is already represented by `playback_div_limit`; it only becomes audible once playback output is sourced from RAM.

- [x] Connect headphone output to `delayed_line_in_l/r` while playback is active.
- [x] Preserve mute behavior as the top priority.
- [x] Keep direct line-in monitoring when playback is stopped.
- [x] Run static checks for RAM output usage and updated report expectations.
- [x] Document verification results in this file.

## Review (LAB_6C Audio Record/Playback Fix)
- `LAB_6C/audio.vhd` now routes RAM read data (`delayed_line_in_l/r`) to `hphone_l/r` whenever playback is active.
- Mute still forces both headphone channels to zero before playback/direct-monitor selection.
- When playback is stopped, the output still monitors live `line_in_l/r`.
- Static verification passed with `git diff --check`; local synthesis/simulation could not be run because `xst` and `ghdl` are not installed in this environment.
