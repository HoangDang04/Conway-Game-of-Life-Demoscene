/*
 * Copyright (c) 2024 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] red;
  wire [1:0] green;
  wire [1:0] blue;
  wire video_active;
  wire [9:0] vpos;
  wire [9:0] hpos;
  wire sound;

    vga_sync vga_synchronize(
        .hsync(hsync),
        .vsync(vsync),
        .vpos(vpos),
        .hpos(hpos),
        .clk(clk),
        .reset(~rst_n)
    );
        
  // TinyVGA PMOD
  assign uo_out = {hsync, blue[0], green[0], red[0], vsync, blue[1], green[1], red[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};


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

  reg current_state [0:CellSize];

  wire is_border = (hpos < StartWidth || hpos > EndWidth || vpos < StartHeight || vpos > EndHeight) ? 1 : 0;

  wire not_visible = (hpos >= BitWidthTotal || vpos >= BitHeightTotal) ? 1 : 0;

  wire [3:0] cell_x = (hpos - StartWidth) / BitHeight;
  wire [3:0] cell_y = (vpos - StartHeight) / BitWidth;

  wire [7:0] cell_index = (cell_y * CellWidth) + cell_x;

  wire current_cell = current_state[cell_index];

  assign red   = not_visible  ? 2'b00 :
                 is_border    ? 2'b11 :
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

reg [9:0] frame_count;

always @(posedge vsync) begin
  if (frame_count == 60) begin
    current_state[1] <= ~current_state[1];
    frame_count <= 0;
  end else begin
    frame_count <= frame_count + 1;
  end
end

  
endmodule
