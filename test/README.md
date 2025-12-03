# Conway's Game of Life Tests

## Viewing the demoscene
Step 1: Go to the tiny tapeout VGA emulator (https://vga-playground.com/).

Step 2: Change the branch of this repository to VGAPlayground.

Step 3: Copy the project.v code into the website.

Step 4: Toggle ui_in[1] to reset the demoscene and begin the simulation!
        The simulation can be paused by hitting ui_in[0].

## Description of tests
Testing the actual pixel output was done visually using VGA Playground.

The tests are to verify that the synchronization module is sending HSync and VSync pulses at the appropriate time.
We have one test to verify that the horizontal sync pulse occurs at the correct time, and that there is no pixel output during blanking periods.
We have one test to verify that the vertical sync pulse occurs at the correct time, and that there is no pixel output during blanking periods.

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
