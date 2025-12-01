# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import ReadOnly
from cocotb.triggers import FallingEdge

async def setup_test(dut):
    dut._log.info("Start")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Set the clock period to 1 ns (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await FallingEdge(dut.clk)

@cocotb.test()
async def vga_horizontal_test(dut):
    await setup_test(dut)

    dut._log.info("Test horizontal sync")

    # Pixel generation region
    await ClockCycles(dut.clk, 640)

    # Front porch
    dut._log.info("front porch")
    for i in range(16) :
        dut._log.info(i)
        await ClockCycles(dut.clk, 1)
        assert dut.uo_out.value == 0

    # HSync 
    dut._log.info("hsync")
    for i in range(96) :
        await ClockCycles(dut.clk, 1)
        assert dut.uo_out.value == 128

    # Back porch
    dut._log.info("back porch")
    for i in range(48) :
        await ClockCycles(dut.clk, 1)
        assert dut.uo_out.value == 0
