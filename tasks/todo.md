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
