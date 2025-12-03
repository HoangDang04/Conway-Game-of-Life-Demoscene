![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout Demoscene – Conway’s Game of Life

This project implements a **Conway’s Game of Life demoscene** on a Tiny Tapeout ASIC.  
The design uses VGA output to visualize evolving patterns seeded with **University of Waterloo-themed pixel art**.  

>  Thank you to [Tiny Tapeout](https://tinytapeout.com) for providing the framework to makes this project possible and professor John Long.

# Author: Hoang Dang, Adam Spyridakis
---

## Project Outline

- **Concept**: Conway's Game of Life.
- **Rules**:
  - A cellular automaton where each cell has two states: alive or dead.
  - The next state of a cell depends on the current state of its 8 neighbouring cells.
  - Alive cell with **2 or 3 alive neighbors → stays alive**  
  - Alive cell with **0–1 or 4–8 dead neighbors → dies**  
  - Dead cell with **3 alive neighbors → becomes alive**  
  - Dead cell with **0–2 or 4–8 dead neighbors → stays dead**
  - The grid is 8x8, so the border of the grid is considered dead.
- **Cells**: Represented as a square block of pixels.
- **Initial State**:  
  - Seeded with University of Waterloo pixel art.
  - Limited by the chip area, so our grid is 8x8. Managed to draw UW using cells available.
- **Output**:  
  - VGA for visuals.  
- **Testing**:
  - Tiny Tapeout provides an emulator (https://vga-playground.com/) to validate designs before fabrication.
  - Go to the VGAPlayground branch. Copy the project.v verilog code onto the website to view the demoscene.
  - To test the VGA Synchronization module we have used cocotb testing framework. Go to the test README for more information.

---

## Clock Speed

The clock speed depends on the TinyVGA specifications, which specify a **pixel request frequency of 25.175 MHz**.

This frequency can be derived from the VGA timing parameters as follows:

### Horizontal Parameters

| Parameter               | Value (pixels) |
|--------------------------|----------------|
| Horizontal visible area  | 640            |
| Horizontal front porch   | 16             |
| Horizontal sync pulse    | 96             |
| Horizontal back porch    | 48             |
| **Horizontal total**     | **800**        |

All horizontal parameters are measured in pixel values. Although not all represent actual pixels, they indicate timing intervals relative to how many pixels can be processed during each period.

### Vertical Parameters

| Parameter               | Value (lines) |
|--------------------------|---------------|
| Vertical visible area    | 480           |
| Vertical front porch     | 10            |
| Vertical sync pulse      | 2             |
| Vertical back porch      | 33            |
| **Vertical total**       | **525**       |

Vertical parameters are measured in lines, representing timing intervals for how many horizontal lines can be processed in the same duration.

### Calculation

1. **Total pixels per frame**

800 * 525 = 420000


2. **Pixel generation frequency**

800 × 525 = 420,000


3. This calculated value closely matches the specified clock frequency:

25.175 MHz
- Therefore, the VGA pixel clock frequency is approximately **25.175 MHz**.
- We have set the clock period to **40 ns** which corresponds to **25 MHz**.

---
## Input/Output Mapping

| Pin # | Direction | Function      |
|-------|-----------|---------------|
| 0     | Input     | Run (pause/play) |
| 1     | Input     | Reset |
| 2     | Output    | B1 |
| 3     | Output    | VS (Vertical Sync) |
| 4     | Output    | R0 |
| 5     | Output    | G0 |
| 6     | Output    | B0 |
| 7     | Output    | HS (Horizontal Sync) |

### VGA Pinout
- **Run**: Putting a high on this input will pause the game in its current state.
           Putting a low on this input will allow the simulation to continue.
- **Reset**: Putting a high on this input will reset the grid to its original state.
- **R0, R1**: Red output (MSB/LSB)  
- **G0, G1**: Green output (MSB/LSB)  
- **B0, B1**: Blue output (MSB/LSB)  
- **VS**: Vertical Sync  
- **HS**: Horizontal Sync

[VGA reference](https://github.com/mole99/tiny-vga)

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
  - Also responsible for creating the background.

---

## System Diagram
<img width="960" height="720" alt="ECE 298A System Diagram Draft 1" src="https://github.com/user-attachments/assets/a6e737a8-55ae-4d14-b99c-ff6a581ee727" />

![ECE 298A System Diagram Draft 1](https://github.com/user-attachments/assets/a6e737a8-55ae-4d14-b99c-ff6a581ee727)


---

## Resources

- [Tiny Tapeout Docs](https://tinytapeout.com)  
- [Digital design lessons](https://tinytapeout.com/digital_design/)  
- [Tiny Tapeout Discord](https://tinytapeout.com/discord)


- **Contributors**: Hoang Dang and Adam Spyridakis
- **Framework**: Built on [Tiny Tapeout](https://tinytapeout.com)  
