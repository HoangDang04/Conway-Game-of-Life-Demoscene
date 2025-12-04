# Conway's Game of Life Tests

## Viewing the Demoscene

Step 1: Go to the tiny tapeout VGA emulator (https://vga-playground.com/).

Step 2: Change the branch of this repository to VGAPlayground.

Step 3: Copy the project.v code into the website.

Step 4: Toggle ui_in[1] to reset the demoscene and begin the simulation!
        The simulation can be paused by hitting ui_in[0].

## Description of cocotb Tests

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

## How to run

To run the RTL simulation:

```sh
make -B
```

To run gatelevel simulation, first harden your project and copy `../runs/wokwi/results/final/verilog/gl/{your_module_name}.v` to `gate_level_netlist.v`.

Then run:

```sh
make -B GATES=yes
```

## How to view the VCD file

Using GTKWave
```sh
gtkwave tb.vcd tb.gtkw
```

Using Surfer
```sh
surfer tb.vcd
```
