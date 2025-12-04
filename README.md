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
  - Hardcoded with University of Waterloo pixel art.
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
| 0     | Output    | R1 |
| 1     | Output    | G1 |
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

## System Diagram and Design Details
![ECE 298A System Diagram](https://github.com/user-attachments/assets/96e3d10f-fcb1-48af-8f0e-a66ec1475911)

**VSync and HSync Module**
The VSync and HSync module monitors the current pixel that is being output based on the clock. It provides an hpos and vpos signal to let the pixel generation module know what it should be outputting.
It also generates the necessary VGA signals to signal to the VGA peripheral that it has hit the end of the horizontal/vertical line.

**Determining Cell Location**
We used the hpos and vpos signal generated by the synchronization module to index the board. Each cell is a square block of 50x50 pixels. We determine which row/column it is in then use that to determine the
overall cell number. Cells are numbered from left to right with the top left cell being cell 0 and the bottom right cell being cell 63. If the pixel is not within the grid, the background is output. The 
background is a grid of its own, and its colour is based on the hpos and vpos as well as a separate background counter. This counter is used to create the shifting diagonal effect.

**Game of Life Logic**
The logic works in two states (see the diagram above). In the first state the values of the new cell array are copied into the old cell array. During this state the old cell array is changing so we output the
new cell array. In the second state the old cell array is used to compute the new cell array according to the rules specified above. In this state the new cell array is changing so we output the new cell array.

Each cell update is done on one VSync pulse, generated by the synchronization module, to regulate the speed at which it is being output. This means that at 60 frames per second, the output will change every ~2
seconds. For the new cell array updates the neighbouring cell count is computed one VSync pulse before it is used to determine whether a cell's next state is alive or dead. The algorithm to compute the number
of neighbours is fairly straightforward. It uses the cell's indices to check the value of all neighbouring cells. If a cell is on one of the borders, it considers any cell that would be in the border as dead, so
in that case it doesn't use that cell in the neighbour count. 

The comments are fairly detailed, so refer to them for more specific implementation information.

---
## Design Challenges
1. Issues with chip space and memory.
   Our project is very memory demanding in nature. To have a stable output and correct computation according to the rules of Conway's Game of Life we need two bit arrays.
   Initially we were hoping to have a very large grid with a very detailed starting image, but even having registers to store the bits necessary for a 16x16 grid resulted in ~300% chip area usage.
   When we initially designed the logic for the grid and determining what cell is currently being output to the VGA we used localparams to make the implementation general, so it was fairly quick to test
   different grid sizes. We determined that if our implementation of the logic for the game itself was efficient enough, an 8x8 grid was feasible.

   Designing an efficient method of implementing the game was a challenge as well. We learned that for loops in verilog are quite expensive when we attempted to copy over the new cell state to the old
   cell state in one clock cycle. To resolve this we made each cell update in separate cycles.

   Unfortunately this meant that we could not afford to be too creative with the background/extra space not being occupied by the grid. We had an animated goose (see Goose branch),
   but determined that it was too space demanding to be left in.

2. Learning Verilog structure and style.
   As a team we did not have extensive experience in using hardware description languages in general. It took some time to get adjusted to the general structure and design practices.
   Originally we tried to use a blocking update of the neighbours register. The goal was to determine the amount of live neighbours and then immediately update that cell.
   This caused linter problems and likely synthesis concerns as blocking assignments are not supposed to be used in always blocks.
   We had to completely rethink our approach and update the neighbours in the cycle before updating the new cell state.

---

## Testing
**Viewing the Demoscene**
Step 1: Go to the tiny tapeout VGA emulator (https://vga-playground.com/).
Step 2: Change the branch of this repository to VGAPlayground.
Step 3: Copy the project.v code into the website.
Step 4: Toggle ui_in[1] to reset the demoscene and begin the simulation!
        The simulation can be paused by hitting ui_in[0].

**Description of cocotb Tests**
Test 1: Verification of HSync pulse
We expect to see the horizontal front proch when hpos has a value of 640, such that it output 640 visible pixels prior (0-639 inclusive).
Looking at the waveform below, the front porch occurs at a hex value of 280, lasts for 16 cycles and then puts a one on uo_out[7] (80 in hex). This value is expected during a HSync pulse.
The HSync pulse lasts for 96 cycles, and then we see a value of 00 for 48 cycles.
![HSync Test](https://github.com/user-attachments/assets/36f091c4-b080-4bab-955a-b4896bb6c7cf)

Test 2: Verification of VSync pulse
We expect to see the vertical front proch when vpos has a value of 480, such that it output 480 visible lines prior (0-479 inclusive).
Looking at the waveform below, the front porch occurs at a hex value of 1e0, lasts for 10 lines and then puts a one on uo_out[3] (08 in hex). This value is expected during a VSync pulse.
The VSync pulse lasts for 2 lines, and then we see a value of 00 for 34 lines.
The values are interrupted with 80/88 for the HSync pulse that occurs each line. In the tests this value is masked out since we already tested it in test 1.
![VSync Test](https://github.com/user-attachments/assets/bbe0446c-3636-499e-96b7-59db2ea81965)

---

## Resources

- [Tiny Tapeout Docs](https://tinytapeout.com)  
- [Digital design lessons](https://tinytapeout.com/digital_design/)  
- [Tiny Tapeout Discord](https://tinytapeout.com/discord)


- **Contributors**: Hoang Dang and Adam Spyridakis
- **Framework**: Built on [Tiny Tapeout](https://tinytapeout.com)  
