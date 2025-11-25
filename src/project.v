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

  // VGA signals
  wire hsync, vsync;
  wire [1:0] R, G, B;
  wire [9:0] hpos, vpos;
  
  // Start/ Stop simulations
  wire run = ~ui_in[0];    // This only works when you hit ui_in
  wire reset = ~ui_in[1];

  // assign output
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0
  assign uio_out = 0;
  assign uio_oe = 0;

  wire _unused = &{ena, clk, 1'b0, ui_in[7:2], uio_in};

  vga_sync vga_synchronize(
      .hsync(hsync),
      .vsync(vsync),
      .vpos(vpos),
      .hpos(hpos),
      .clk(clk),
      .reset(~rst_n)
  );


  // =============REGISTER SIZE OF THE BOARD=================//
  localparam BIT_WIDTH = 3, BIT_HEIGHT = 3;
  localparam BOARD_WIDTH = 2 ** BIT_WIDTH;
  localparam BOARD_HEIGHT = 2 ** BIT_HEIGHT;
  localparam SIZE = BOARD_WIDTH * BOARD_HEIGHT;
  
  localparam CELL_SIZE = 50;
  localparam BACKGROUND_HEIGHT = 480 - (CELL_SIZE * BOARD_HEIGHT);     // how much left of BIT_HEIGHT in the background
  localparam BACKGROUND_WIDTH = 640 - (CELL_SIZE * BOARD_WIDTH);    // how much left of BIT_WIDTH in the background

  reg curr_board [0:SIZE-1];
  reg prev_board [0:SIZE-1];
  
  //==================OTHER WIRE REGISTERS=====================//                                        
  //Checking the region belongs to 640 x 480 board or not, boundary works as a boolean
  wire boundary = (hpos < 640 - BACKGROUND_WIDTH/2) &&
                  (hpos >= BACKGROUND_WIDTH/2) &&
                  (vpos < 480 - BACKGROUND_HEIGHT/2) &&
                  (vpos >= BACKGROUND_HEIGHT/2);
  wire visible = (hpos < 640) && (vpos < 480);
  // Assign which cell this pixel belongs to
  wire [9 : 0] row_index = (hpos - BACKGROUND_WIDTH/2) / CELL_SIZE;
  wire [9 : 0] column_index = (vpos - BACKGROUND_HEIGHT/2) / CELL_SIZE;

  reg vga_source;
  wire vga_value = vga_source ? prev_board[location[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] :
                                curr_board[location[BIT_WIDTH + BIT_HEIGHT - 1 : 0]];
  // Compute location of the cell on the board
  wire [9 : 0] location = (column_index * BOARD_WIDTH) + row_index;
  wire _unused_location = &location[9:6];

  // Generate RGB signals for the board
	assign R =	(boundary && vga_value)  ? 	2'b00 :
				      (boundary && !vga_value) ? 	2'b10 :
        	   	visible                  ? 	2'b01 :
														              2'b00;
	assign G =	(boundary && vga_value)  ? 	2'b00 :
				      (boundary && !vga_value) ? 	2'b10 :
        		  visible                  ? 	2'b10 :
														              2'b00;
	assign B =	(boundary && vga_value)  ?  2'b00 :
				      (boundary && !vga_value) ? 	2'b10 :
        		  visible                  ? 	2'b10 :
														              2'b00;

//======================= LOGIC ================================//
	reg [BIT_WIDTH + BIT_HEIGHT : 0] i;
  reg [3:0] neighbours;

  wire [BIT_WIDTH + BIT_HEIGHT - 1 : 0] iter = (vga_source == 1 && i < 63) ? i[BIT_WIDTH + BIT_HEIGHT - 1 : 0] + 1 : 6'b0;

  wire not_top    = (iter > BOARD_WIDTH - 1);
  wire not_bottom = (iter < BOARD_WIDTH * (BOARD_HEIGHT - 1));
  wire not_left   = (iter % BOARD_WIDTH != 0);
  wire not_right  = ((iter + 1) % BOARD_WIDTH != 0);

	always @(posedge vsync) begin
		if(reset == 0) begin
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
    end else if (run == 1) begin
      if (vga_source == 0) begin
          prev_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] <= curr_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]];
      end else begin
        if (prev_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] == 1) begin
          if (neighbours == 2 || neighbours == 3)
            curr_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] <= 1;
          else
            curr_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] <= 0;
        end else begin
          if (neighbours == 3)
            curr_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] <= 1;
          else
            curr_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] <= 0;
        end
      end

      neighbours <= ((not_top && not_left && prev_board[iter - BOARD_WIDTH - 1])     ? 4'b0001 : 4'b0000)
                  + ((not_top && prev_board[iter - BOARD_WIDTH])                     ? 4'b0001 : 4'b0000)
                  + ((not_top && not_right && prev_board[iter - BOARD_WIDTH + 1])    ? 4'b0001 : 4'b0000)
                  + ((not_left && prev_board[iter - 1])                              ? 4'b0001 : 4'b0000)
                  + ((not_right && prev_board[iter + 1])                             ? 4'b0001 : 4'b0000)
                  + ((not_bottom && not_left && prev_board[iter + BOARD_WIDTH - 1])  ? 4'b0001 : 4'b0000)
                  + ((not_bottom && prev_board[iter + BOARD_WIDTH])                  ? 4'b0001 : 4'b0000)
                  + ((not_bottom && not_right && prev_board[iter + BOARD_WIDTH + 1]) ? 4'b0001 : 4'b0000);

      if (i == 63) begin
        i <= 0;
        vga_source <= ~vga_source;
      end else
        i <= i + 1;
    end
	end

endmodule
