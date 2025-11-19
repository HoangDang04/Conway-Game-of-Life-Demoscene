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
  
  localparam CELL_SIZE = 24;
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
  wire [BIT_WIDTH - 1: 0] row_index = (hpos - BACKGROUND_WIDTH/2) / CELL_SIZE;
  wire [BIT_HEIGHT - 1: 0] column_index = (vpos - BACKGROUND_HEIGHT/2) / CELL_SIZE;

  reg vga_source;
  wire vga_value = vga_source ? curr_board[location] :
                                  prev_board[location];
  // Compute wheres the location of the cell in the board
  wire [BIT_WIDTH + BIT_HEIGHT - 1: 0] location = (column_index * BOARD_WIDTH) + row_index;
  //Genrate RGB signals for the board
	assign R =	(boundary && vga_value) 	? 	2'b00 :
				      (boundary && !vga_value) ? 	2'b10 :
        	   	visible                           	? 	2'b01 :
														                          2'b00;
	assign G =	(boundary && vga_value) 	? 	2'b00 :
				      (boundary && !vga_value) ? 	2'b10 :
        		  visible                           	? 	2'b10 :
														                          2'b00;
	assign B =	(boundary && vga_value) 	? 	2'b00 :
				      (boundary && !vga_value) ? 	2'b10 :
        		  visible                           	? 	2'b10 :
														                          2'b00;

//======================= LOGIC ================================//
	reg [BIT_WIDTH + BIT_HEIGHT : 0] i;
  reg [3:0] neighbours;
  reg test;
	always @(posedge vsync) begin
		if(test == 0) begin
      // create desin
      curr_board[3] <= 1;
      curr_board[4] <= 1;
      curr_board[5] <= 1;
      vga_source <= 1;
	
      test <= 1;
    end
    if (vga_source == 1) begin
      prev_board[i] <= curr_board[i];
    end else begin
        neighbours = 0;
        if (i > BOARD_WIDTH - 1 && i % BOARD_WIDTH != 0 && prev_board[i - BOARD_WIDTH - 1] == 1)
                neighbours = neighbours + 1;
        if (i > BOARD_WIDTH - 1 && prev_board[i - BOARD_WIDTH] == 1)
                neighbours = neighbours + 1;
        if (i > BOARD_WIDTH - 1 && (i + 1) % BOARD_WIDTH != 0 && prev_board[i - BOARD_WIDTH + 1] == 1)
                neighbours = neighbours + 1;
        if (i % BOARD_WIDTH != 0 && prev_board[i - 1] == 1)
                neighbours = neighbours + 1;
        if ((i + 1) % BOARD_WIDTH != 0 && prev_board[i + 1] == 1)
                neighbours = neighbours + 1;
        if (i < BOARD_WIDTH * (BOARD_HEIGHT - 1) && i % BOARD_WIDTH != 0 && prev_board[i + BOARD_WIDTH - 1] == 1)
                neighbours = neighbours + 1;
        if (i < BOARD_WIDTH * (BOARD_HEIGHT - 1) && prev_board[i + BOARD_WIDTH] == 1)
                neighbours = neighbours + 1;
        if (i < BOARD_WIDTH * (BOARD_HEIGHT - 1) && (i + 1) % BOARD_WIDTH != 0 && prev_board[i + BOARD_WIDTH + 1] == 1)
                neighbours = neighbours + 1;
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

      if (i == (BOARD_HEIGHT * BOARD_WIDTH) - 1) begin
        i <= 0;
        vga_source <= ~vga_source;
      end else
        i <= i + 1;
	end
endmodule
