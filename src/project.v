/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // VGA Connections
  wire hsync;
  wire vsync;
  wire [1:0] red;
  wire [1:0] green;
  wire [1:0] blue;
  wire [9:0] vpos;
  wire [9:0] hpos;

  // Assign output based on tiny-vga pinout: https://github.com/mole99/tiny-vga
  assign uo_out = {hsync, blue[0], green[0], red[0], vsync, blue[1], green[1], red[1]};

  localparam BitWidthTotal = 640;
  localparam BitHeightTotal = 480;

  localparam CellWidth = 16;
  localparam CellHeight = 16;
  localparam CellSize = 16*16 - 1;
  localparam BitWidth = 24;
  localparam BitHeight = 24;

  localparam StartWidth = (BitWidthTotal - (BitWidth * CellWidth))/2;
  localparam EndWidth = BitWidthTotal - StartWidth - 1;

  localparam StartHeight = (BitHeightTotal - (BitHeight * CellHeight))/2;
  localparam EndHeight = BitHeightTotal - StartHeight - 1;

  vga_synchronization vga_sync (
    .hsync(hsync),
    .vsync(vsync),
    .vpos(vpos),
    .hpos(hpos),
    .clk(clk),
    .reset(rst_n),
  );

  reg current_state [0:CellSize];
  reg previous_state [0:CellSize];

  wire is_border = (hpos < StartWidth || hpos > EndWidth || vpos < StartHeight || vpos > EndHeight) ? 1 : 0;

  wire not_visible = (hpos >= BitWidthTotal || vpos >= BitHeightTotal) ? 1 : 0;

  wire [3:0] cell_x = (hpos - StartWidth) / BitHeight;
  wire [3:0] cell_y = (vpos - StartHeight) / BitWidth;

  wire [7:0] cell_index = (cell_y * CellWidth) + cell_x;

  wire current_cell = current_state[cell_index];

  assign red   = not_visible  ? 2'b00 :
                 is_border    ? 2'b10 :
                 current_cell ? 2'b00 :
                                2'b11;
  assign green = not_visible  ? 2'b00 :
                 is_border    ? 2'b01 :
                 current_cell ? 2'b00 :
                                2'b11;
  assign blue  = not_visible  ? 2'b00 :
                 is_border    ? 2'b01 :
                 current_cell ? 2'b00 :
                                2'b11;

  reg [5:0] frame_count;
  reg [8:0] i;

  reg [3:0] neighbours;

  reg [1:0] test;

  always @(posedge vsync) begin
    // set initial state
    if (frame_count == 0 && test == 0) begin
      // U
      current_state[3] <= 1;
      current_state[6] <= 1;
      current_state[19] <= 1;
      current_state[22] <= 1;
      current_state[35] <= 1;
      current_state[38] <= 1;
      current_state[52] <= 1;
      current_state[53] <= 1;

      // W
      current_state[8] <= 1;
      current_state[12] <= 1;
      current_state[24] <= 1;
      current_state[28] <= 1;
      current_state[40] <= 1;
      current_state[42] <= 1;
      current_state[44] <= 1;
      current_state[57] <= 1;
      current_state[59] <= 1;

      // E(1)
      current_state[82] <= 1;
      current_state[83] <= 1;
      current_state[84] <= 1;
      current_state[98] <= 1;
      current_state[114] <= 1;
      current_state[115] <= 1;
      current_state[130] <= 1;
      current_state[146] <= 1;
      current_state[147] <= 1;
      current_state[148] <= 1;

      // C
      current_state[87] <= 1;
      current_state[88] <= 1;
      current_state[103] <= 1;
      current_state[119] <= 1;
      current_state[135] <= 1;
      current_state[151] <= 1;
      current_state[152] <= 1;

      // E(2)
      current_state[91] <= 1;
      current_state[92] <= 1;
      current_state[93] <= 1;
      current_state[107] <= 1;
      current_state[123] <= 1;
      current_state[124] <= 1;
      current_state[139] <= 1;
      current_state[155] <= 1;
      current_state[156] <= 1;
      current_state[157] <= 1;

      // 2
      current_state[176] <= 1;
      current_state[177] <= 1;
      current_state[178] <= 1;
      current_state[194] <= 1;
      current_state[208] <= 1;
      current_state[209] <= 1;
      current_state[210] <= 1;
      current_state[224] <= 1;
      current_state[240] <= 1;
      current_state[241] <= 1;
      current_state[242] <= 1;

      // 9
      current_state[180] <= 1;
      current_state[181] <= 1;
      current_state[182] <= 1;
      current_state[196] <= 1;
      current_state[198] <= 1;
      current_state[212] <= 1;
      current_state[213] <= 1;
      current_state[214] <= 1;
      current_state[230] <= 1;
      current_state[246] <= 1;

      // 8
      current_state[184] <= 1;
      current_state[185] <= 1;
      current_state[186] <= 1;
      current_state[200] <= 1;
      current_state[202] <= 1;
      current_state[216] <= 1;
      current_state[217] <= 1;
      current_state[218] <= 1;
      current_state[232] <= 1;
      current_state[234] <= 1;
      current_state[248] <= 1;
      current_state[249] <= 1;
      current_state[250] <= 1;

      // A
      current_state[189] <= 1;
      current_state[190] <= 1;
      current_state[191] <= 1;
      current_state[205] <= 1;
      current_state[207] <= 1;
      current_state[221] <= 1;
      current_state[222] <= 1;
      current_state[223] <= 1;
      current_state[237] <= 1;
      current_state[239] <= 1;
      current_state[253] <= 1;
      current_state[255] <= 1;

      test <= 1;
    end

    if (frame_count == 60) begin
      for (i = 0; i <= 255; i++) 
        previous_state[i] = current_state[i];
      for (i = 0; i <= 255; i++) begin
        neighbours = 0;
        if (i == 0) begin
          if (previous_state[i + 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16 + 1] == 1)
            neighbours = neighbours + 1;
        end else if (i == 15) begin
          if (previous_state[i - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16 - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16] == 1)
            neighbours = neighbours + 1;
        end else if (i == 240) begin
          if (previous_state[i - 16] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 16 + 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 1] == 1)
            neighbours = neighbours + 1;
        end else if (i == 255) begin
          if (previous_state[i - 16 - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 16] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 1] == 1)
            neighbours = neighbours + 1;
        end else if (i < 15) begin
          if (previous_state[i - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16 - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16 + 1] == 1)
            neighbours = neighbours + 1;
        end else if (i > 240) begin
          if (previous_state[i - 16 - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 16] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 16 + 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 1] == 1)
            neighbours = neighbours + 1;
        end else if (i % 16 == 0) begin
          if (previous_state[i - 16] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 16 + 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16 + 1] == 1)
            neighbours = neighbours + 1;
        end else if ((i + 1) % 16 == 0) begin
          if (previous_state[i - 16 - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 16] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16 - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16] == 1)
            neighbours = neighbours + 1;
        end else begin
          if (previous_state[i - 16 - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 16] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 16 + 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16 - 1] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16] == 1)
            neighbours = neighbours + 1;
          if (previous_state[i + 16 + 1] == 1)
            neighbours = neighbours + 1;
        end
        if (neighbours == 2 || neighbours == 3)
          current_state[i] = 1;
        else 
         current_state[i] = 0;
      end
      frame_count <= 0;
    end else
      frame_count <= frame_count + 1;
  end

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
