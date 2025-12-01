/*
 * Copyright (c) 2024 Hoang Dang, Adam Spyridakis
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_game_of_life (
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
  wire hsync, vsync;
  wire [1:0] R, G, B;
  wire [9:0] hpos, vpos;
  
  // Start/ Stop simulations
  wire run = ui_in[0];    // Stops when you hit ui_in[0]
  wire reset = ui_in[1];  // Reset when you hit ui_in[1]

  // assign output
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0
  assign uio_out = vpos[7:0];
  assign uio_oe = 8'b11111111;

  wire _unused = &{ena, clk, 1'b0, ui_in[7:2], uio_in, location[9:6]};

  vga_sync vga_synchronize(
      .hsync(hsync),
      .vsync(vsync),
      .vpos(vpos),
      .hpos(hpos),
      .clk(clk),
      .reset(~rst_n)
  );

  //=============REGISTER SIZE OF THE BOARD=================//
  // Bits needed to represent board height and width
  localparam BIT_WIDTH = 3, BIT_HEIGHT = 3;
  // Actual board width and height
  localparam BOARD_WIDTH = 2 ** BIT_WIDTH;
  localparam BOARD_HEIGHT = 2 ** BIT_HEIGHT;
  // Total number of cells
  localparam SIZE = BOARD_WIDTH * BOARD_HEIGHT;
  
  // Pixel width/height of an individual cell.
  localparam CELL_SIZE = 50;
  // Area not present in the "board", background area.
  localparam BACKGROUND_HEIGHT = 480 - (CELL_SIZE * BOARD_HEIGHT);
  localparam BACKGROUND_WIDTH = 640 - (CELL_SIZE * BOARD_WIDTH);
  
  //==================OTHER WIRE REGISTERS=====================//
  // Registers representing the current and previous state of the board.
  reg curr_board [0:SIZE-1];
  reg prev_board [0:SIZE-1];

  // Check whether the region belongs to board of cells or not.
  wire boundary = (hpos < 640 - BACKGROUND_WIDTH/2) &&
                  (hpos >= BACKGROUND_WIDTH/2) &&
                  (vpos < 480 - BACKGROUND_HEIGHT/2) &&
                  (vpos >= BACKGROUND_HEIGHT/2);
  // Wire to verify we are not in a VGA blanking period.
  wire visible = (hpos < 640) && (vpos < 480);
  // Determine which cell this pixel belongs to.
  wire [9:0] row_index = (hpos - BACKGROUND_WIDTH/2) / CELL_SIZE;
  wire [9:0] column_index = (vpos - BACKGROUND_HEIGHT/2) / CELL_SIZE;

  // Register representing whether we are currently displaying curr_board or prev_board.
  reg vga_source;
  wire vga_value = vga_source ? prev_board[location[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] :
                                curr_board[location[BIT_WIDTH + BIT_HEIGHT - 1 : 0]];
  // Compute location of the cell on the board - need extra bits to appease linter.
  wire [9:0] location = (column_index * BOARD_WIDTH) + row_index;

  // Generate background colours based on horizontal and vertical position.
  wire [1:0] h_slice = hpos[6:5];
  wire [1:0] v_slice = vpos[6:5];
  reg [1:0] bg_tracker;
  wire [1:0] background = h_slice + v_slice + bg_tracker;

  // Generate RGB signals for the board.
  assign R =  (boundary && vga_value)  ?  2'b10 :
              (boundary && !vga_value) ?  2'b11 :
               visible                 ?  background :
                                          2'b00;
  assign G =  (boundary && vga_value)  ?  2'b00 :
              (boundary && !vga_value) ?  2'b10 :
              visible                  ?  background :
                                          2'b00;
  assign B =  (boundary && vga_value)  ?  2'b10 :
              (boundary && !vga_value) ?  2'b11 :
              visible                  ?  2'b01 :
                                          2'b00;

//======================= LOGIC ================================//
  // Iterator responsible for updating curr_board and prev_board.
  reg [BIT_WIDTH + BIT_HEIGHT - 1:0] i;
  // Register keeping track of alive neighbours for each cell.
  reg [3:0] neighbours;

  // Iterator which is 1 ahead of i to compute neighbours one clock cycle in advance.
  wire [BIT_WIDTH + BIT_HEIGHT - 1:0] iter = (vga_source == 1 && i < 63) ? i + 1 : 6'b0;

  // Whether a cell is a neighbour depends on where it is in the grid.
  wire not_top    = (iter > BOARD_WIDTH - 1);
  wire not_bottom = (iter < BOARD_WIDTH * (BOARD_HEIGHT - 1));
  wire not_left   = (iter % BOARD_WIDTH != 0);
  wire not_right  = ((iter + 1) % BOARD_WIDTH != 0);

  // Updates occur on vsync edge.
  always @(posedge vsync) begin
    // Synchronous rest. Resets UW pattern.
    if(reset == 1) begin
      curr_board[1] <= 0;
      curr_board[2] <= 0;
      curr_board[4] <= 0;
      curr_board[5] <= 0;
      curr_board[6] <= 0;
      curr_board[7] <= 0;
      curr_board[9] <= 0;
      curr_board[10] <= 0;
      curr_board[12] <= 0;
      curr_board[13] <= 0;
      curr_board[14] <= 0;
      curr_board[15] <= 0;
      curr_board[17] <= 0;
      curr_board[18] <= 0;
      curr_board[20] <= 0;
      curr_board[21] <= 0;
      curr_board[22] <= 0;
      curr_board[23] <= 0;
      curr_board[24] <= 0;
      curr_board[27] <= 0;
      curr_board[28] <= 0;
      curr_board[29] <= 0;
      curr_board[30] <= 0;
      curr_board[31] <= 0;
      curr_board[32] <= 0;
      curr_board[33] <= 0;
      curr_board[34] <= 0;
      curr_board[36] <= 0;
      curr_board[37] <= 0;
      curr_board[38] <= 0;
      curr_board[40] <= 0;
      curr_board[41] <= 0;
      curr_board[42] <= 0;
      curr_board[44] <= 0;
      curr_board[45] <= 0;
      curr_board[46] <= 0;
      curr_board[48] <= 0;
      curr_board[49] <= 0;
      curr_board[50] <= 0;
      curr_board[52] <= 0;
      curr_board[54] <= 0;
      curr_board[56] <= 0;
      curr_board[57] <= 0;
      curr_board[58] <= 0;
      curr_board[59] <= 0;
      curr_board[61] <= 0;
      curr_board[63] <= 0;

      // U
      curr_board[0] <= 1;
      curr_board[3] <= 1;
      curr_board[8] <= 1;
      curr_board[11] <= 1;
      curr_board[16] <= 1;
      curr_board[19] <= 1;
      curr_board[25] <= 1;
      curr_board[26] <= 1;

      // W
      curr_board[35] <= 1;
      curr_board[39] <= 1;
      curr_board[43] <= 1;
      curr_board[47] <= 1;
      curr_board[51] <= 1;
      curr_board[53] <= 1;
      curr_board[55] <= 1;
      curr_board[60] <= 1;
      curr_board[62] <= 1;

      vga_source <= 0;
      i <= 0;
    end else if (run == 0) begin
      // Stage 1: output curr_board while updating prev_board. Copy curr_board into prev_board.
      if (vga_source == 0) begin
          prev_board[i] <= curr_board[i];
      // Stage 2: output prev_board while using prev_board to compute and update curr_board.
      end else begin
        if (prev_board[i] == 1) begin
          if (neighbours == 2 || neighbours == 3)
            curr_board[i] <= 1;
          else
            curr_board[i] <= 0;
        end else begin
          if (neighbours == 3)
            curr_board[i] <= 1;
          else
            curr_board[i] <= 0;
        end
      end

      // Compute alive neighbours.
      neighbours <= ((not_top && not_left && prev_board[iter - BOARD_WIDTH - 1])     ? 4'b0001 : 4'b0000)
                  + ((not_top && prev_board[iter - BOARD_WIDTH])                     ? 4'b0001 : 4'b0000)
                  + ((not_top && not_right && prev_board[iter - BOARD_WIDTH + 1])    ? 4'b0001 : 4'b0000)
                  + ((not_left && prev_board[iter - 1])                              ? 4'b0001 : 4'b0000)
                  + ((not_right && prev_board[iter + 1])                             ? 4'b0001 : 4'b0000)
                  + ((not_bottom && not_left && prev_board[iter + BOARD_WIDTH - 1])  ? 4'b0001 : 4'b0000)
                  + ((not_bottom && prev_board[iter + BOARD_WIDTH])                  ? 4'b0001 : 4'b0000)
                  + ((not_bottom && not_right && prev_board[iter + BOARD_WIDTH + 1]) ? 4'b0001 : 4'b0000);

      i <= i + 1;
      if (i == 63) begin
        bg_tracker <= bg_tracker + 1;
        vga_source <= ~vga_source;
      end
    end
  end

endmodule
