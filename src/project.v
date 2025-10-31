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

  // Start/ Stop simulations
  wire run = ~ui_in[0];  // This only works when you hit ui_in
  wire reset = ~ui_in[1];

  vga_sync vga_synchronization (
    .hsync(hsync),
    .vsync(vsync),
    .vpos(vpos),
    .hpos(hpos),
    .clk(clk),
    .reset(rst_n)
  );

  // Assign output based on tiny-vga pinout: https://github.com/mole99/tiny-vga
  assign uo_out = {hsync, blue[0], green[0], red[0], vsync, blue[1], green[1], red[1]};

  // =============REGISTER SIZE OF THE BOARD=================//
  localparam WIDTH = 3, HEIGHT = 3;

  localparam BOARD_WIDTH = 2 ** WIDTH;
  localparam BOARD_HEIGHT = 2 ** HEIGHT;
  localparam SIZE = BOARD_WIDTH * BOARD_HEIGHT;

  localparam CELL_SIZE = 48;
  localparam BACKGROUND_HEIGHT = 480 - (CELL_SIZE * BOARD_HEIGHT);     // how much left of height in the background
  localparam BACKGROUND_WIDTH = 640 - (CELL_SIZE * BOARD_WIDTH);    // how much left of width in the background

  reg curr_board [0:SIZE-1];
  reg prev_board [0:SIZE-1];

  //==================OTHER WIRE REGISTERS=====================//                                        
  //Checking the region belongs to 640 x 480 board or not, boundary works as a boolean
  wire boundary = (hpos >= 640 - BACKGROUND_WIDTH/2) ||
                  (hpos < BACKGROUND_WIDTH/2) ||
                  (vpos >= 480 - BACKGROUND_HEIGHT/2) ||
                  (vpos < BACKGROUND_HEIGHT/2);
  wire not_visible = (hpos >= 640) || (vpos >= 480);
  // Assign which cell this pixel belongs to
  wire [WIDTH - 1: 0] row_index;
  wire [HEIGHT - 1: 0] column_index;
  assign row_index = (hpos - BACKGROUND_WIDTH/2) / CELL_SIZE;
  assign column_index = (vpos - BACKGROUND_HEIGHT/2) / CELL_SIZE;
  // Compute wheres the location of the cell in the board
  wire [WIDTH + HEIGHT - 1: 0] location = (column_index * BOARD_WIDTH) + row_index;
  //Genrate RGB signals for the board
  wire current_cell = curr_board[location];

  assign red   = not_visible  ? 2'b00 :
                 boundary     ? 2'b11 :
                 current_cell ? 2'b00 :
                                2'b11;
  assign green = not_visible  ? 2'b00 :
                 boundary     ? 2'b01 :
                 current_cell ? 2'b00 :
                                2'b11;
  assign blue  = not_visible  ? 2'b00 :
                 boundary     ? 2'b00 :
                 current_cell ? 2'b00 :
                                2'b11;

//======================= LOGIC ================================//
  reg [5:0] frame_count;

  integer i;

  reg [3:0] neighbours;

  reg test;
always @(posedge vsync) begin
        // set initial state
    if (frame_count == 0 && test == 0) begin
      // 
      curr_board[3] <= 1;
      curr_board[6] <= 1;
      curr_board[19] <= 1;
      curr_board[22] <= 1;
      curr_board[35] <= 1;
      curr_board[38] <= 1;
      curr_board[52] <= 1;
      curr_board[53] <= 1;

      // W
      curr_board[8] <= 1;
      curr_board[12] <= 1;
      curr_board[24] <= 1;
      curr_board[28] <= 1;
      curr_board[40] <= 1;
      curr_board[42] <= 1;
      curr_board[44] <= 1;
      curr_board[57] <= 1;
      curr_board[59] <= 1;

      // // E(1)
      // curr_board[82] <= 1;
      // curr_board[83] <= 1;
      // curr_board[84] <= 1;
      // curr_board[98] <= 1;
      // curr_board[114] <= 1;
      // curr_board[115] <= 1;
      // curr_board[130] <= 1;
      // curr_board[146] <= 1;
      // curr_board[147] <= 1;
      // curr_board[148] <= 1;

      // // C
      // curr_board[87] <= 1;
      // curr_board[88] <= 1;
      // curr_board[103] <= 1;
      // curr_board[119] <= 1;
      // curr_board[135] <= 1;
      // curr_board[151] <= 1;
      // curr_board[152] <= 1;

      // // E(2)
      // curr_board[91] <= 1;
      // curr_board[92] <= 1;
      // curr_board[93] <= 1;
      // curr_board[107] <= 1;
      // curr_board[123] <= 1;
      // curr_board[124] <= 1;
      // curr_board[139] <= 1;
      // curr_board[155] <= 1;
      // curr_board[156] <= 1;
      // curr_board[157] <= 1;

      // // 2
      // curr_board[176] <= 1;
      // curr_board[177] <= 1;
      // curr_board[178] <= 1;
      // curr_board[194] <= 1;
      // curr_board[208] <= 1;
      // curr_board[209] <= 1;
      // curr_board[210] <= 1;
      // curr_board[224] <= 1;
      // curr_board[240] <= 1;
      // curr_board[241] <= 1;
      // curr_board[242] <= 1;

      // // 9
      // curr_board[180] <= 1;
      // curr_board[181] <= 1;
      // curr_board[182] <= 1;
      // curr_board[196] <= 1;
      // curr_board[198] <= 1;
      // curr_board[212] <= 1;
      // curr_board[213] <= 1;
      // curr_board[214] <= 1;
      // curr_board[230] <= 1;
      // curr_board[246] <= 1;

      // // 8
      // curr_board[184] <= 1;
      // curr_board[185] <= 1;
      // curr_board[186] <= 1;
      // curr_board[200] <= 1;
      // curr_board[202] <= 1;
      // curr_board[216] <= 1;
      // curr_board[217] <= 1;
      // curr_board[218] <= 1;
      // curr_board[232] <= 1;
      // curr_board[234] <= 1;
      // curr_board[248] <= 1;
      // curr_board[249] <= 1;
      // curr_board[250] <= 1;

      // // A
      // curr_board[189] <= 1;
      // curr_board[190] <= 1;
      // curr_board[191] <= 1;
      // curr_board[205] <= 1;
      // curr_board[207] <= 1;
      // curr_board[221] <= 1;
      // curr_board[222] <= 1;
      // curr_board[223] <= 1;
      // curr_board[237] <= 1;
      // curr_board[239] <= 1;
      // curr_board[253] <= 1;
      // curr_board[255] <= 1;

      test <= 1;
    end

    if (frame_count == 60) begin
      for (i = 0; i <= 63; i++) 
        prev_board[i] = curr_board[i];
      for (i = 0; i <= 63; i++) begin
        neighbours = 0;
        if (i > 7 && i % 8 != 0 && prev_board[i - 8 - 1] == 1)
          neighbours = neighbours + 1;
        if (i > 7 && prev_board[i - 8] == 1)
          neighbours = neighbours + 1;
        if (i > 7 && (i + 1) % 8 != 0 && prev_board[i - 8 + 1] == 1)
          neighbours = neighbours + 1;
        if (i % 8 != 0 && prev_board[i - 1] == 1)
          neighbours = neighbours + 1;
        if ((i + 1) % 8 != 0 && prev_board[i + 1] == 1)
          neighbours = neighbours + 1;
        if (i < 56 && i % 8 != 0 && prev_board[i + 8 - 1] == 1)
          neighbours = neighbours + 1;
        if (i < 56 && prev_board[i + 8] == 1)
          neighbours = neighbours + 1;
        if (i < 56 && (i + 1) % 8 != 0 && prev_board[i + 8 + 1] == 1)
          neighbours = neighbours + 1;
        if (prev_board[i] == 1) begin
          if(neighbours == 2 || neighbours == 3)
            curr_board[i] = 1;
          else
            curr_board[i] = 0;
        end else begin
          if(neighbours == 3)
            curr_board[i] = 1;
          else
            curr_board[i] = 0;
        end
      end
      frame_count <= 0;
    end else
      frame_count <= frame_count + 1;
  end



reg dummy_ff;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dummy_ff <= 0;
    else
        dummy_ff <= 1'b0; 
end

assign uo_out[0] = dummy_ff; 


endmodule
