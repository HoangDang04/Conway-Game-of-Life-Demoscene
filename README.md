![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout Demoscene – Conway’s Game of Life

This project implements a **Conway’s Game of Life demoscene** on a Tiny Tapeout ASIC.  
The design uses VGA output to visualize evolving patterns seeded with **University of Waterloo-themed pixel art** and optionally produces PWM audio output.  

> 🙏 Thank you to [Tiny Tapeout](https://tinytapeout.com) for providing the framework that makes this project possible.

---

## Project Outline

- **Concept**: A cellular automaton where each cell has two states: alive or dead.  
- **Rules**:
  - Alive cell with **2 or 3 neighbors → stays alive**  
  - Alive cell with **0–1 or 4–8 neighbors → dies**  
  - Dead cell with **3 neighbors → becomes alive**  
  - Dead cell with **0–2 or 4–8 neighbors → stays dead**  
- **Cells**: Represented as groups of pixels.
- **Initial State**:  
  - Seeded with University of Waterloo pixel art.  
  - Optionally display a University of Waterloo watermark in the corner.
- **Output**:  
  - VGA for visuals.  
  - PWM audio (optional) for sound generation.  
- **Testing**: Tiny Tapeout provides an emulator to validate designs before fabrication.

---

## Input/Output Mapping

| Pin # | Direction | Function      |
|-------|-----------|---------------|
| 0     | Input     | Run (start/stop) |
| 1     | Input     | First_state (seed image) |
| 2     | Output    | B1 |
| 3     | Output    | VS (Vertical Sync) |
| 4     | Output    | R0 |
| 5     | Output    | G0 |
| 6     | Output    | B0 |
| 7     | Output    | HS (Horizontal Sync) |
| –     | Output    | Audio (PWM) |

### VGA Pinout
- **R0, R1**: Red output (MSB/LSB)  
- **G0, G1**: Green output (MSB/LSB)  
- **B0, B1**: Blue output (MSB/LSB)  
- **VS**: Vertical Sync  
- **HS**: Horizontal Sync  

[VGA reference](https://github.com/mole99/tiny-vga)

### Audio Pinout
- **PWM audio output**: generates square wave frequencies mapped to notes.  

[Audio reference](https://github.com/MichaelBell/tt-audio-pmod)

---

## Verilog Module Outline

### 1. Horizontal/Vertical Sync Generation Module
- Generates HS and VS signals for VGA.  
- Keeps track of active pixel position.  
- Suppresses pixel data output during sync periods.

### 2. Pixel Generation Module
- Generates RGB output for each pixel.  
- Responsibilities:
  - Seed initial University of Waterloo pixel art.  
  - Calculate next state of each cell using Conway’s Game of Life rules.

### 3. Audio Signal Generation Module
- Maps digital values to audio frequencies.  
- Outputs PWM square waves corresponding to notes.  

---

## System Diagram

![ECE 298A System Diagram Draft 1](https://github.com/user-attachments/assets/f6adea51-e030-44c0-975e-9038281023b4)


---

## Resources

- [Tiny Tapeout Docs](https://tinytapeout.com)  
- [FAQ](https://tinytapeout.com/faq/)  
- [Digital design lessons](https://tinytapeout.com/digital_design/)  
- [Siliwiz – learn semiconductors](https://tinytapeout.com/siliwiz/)  
- [Tiny Tapeout Discord](https://tinytapeout.com/discord)

---

## Next Steps

- Implement Verilog modules and add to `src/`.  
- Update [`info.yaml`](info.yaml) with correct top module and source files.  
- Run simulations with the Tiny Tapeout testbench.  
- Share results with the community under **#tinytapeout**.  

---

## Credits

- **Contributors**: University of Waterloo ECE Project Team  
- **Framework**: Built on [Tiny Tapeout](https://tinytapeout.com)  
