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
    wire run;
    assign run = ui_in[0];    // This only works when you hit ui_in

    // assign output
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    // Unused outputs assigned to 0
    assign uio_out = 0;
    assign uio_oe = 0;

    wire _unused = &{ena, clk, rst_n, 1'b0};

    vga_sync vga_synchronize(
        .hsync(hsync),
        .vsync(vsync),
        .vpos(vpos),
        .hpos(hpos),
        .clk(clk),
        .reset(~rst_n)
    );
    // =============REGISTER SIZE OF THE BOARD=================//
    localparam WIDTH = 3, HEIGHT = 3;
    
    localparam BOARD_WIDTH = 2 ** WIDTH;
    localparam BOARD_HEIGHT = 2 ** HEIGHT;
    localparam SIZE = BOARD_WIDTH * BOARD_HEIGHT;
    
    localparam CELL_SIZE = 24;
    localparam BACKGROUND_HEIGHT = 480 - (CELL_SIZE * BOARD_HEIGHT);     // how much left of height in the background
    localparam BACKGROUND_WIDTH = 640 - (CELL_SIZE * BOARD_WIDTH);    // how much left of width in the background

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
    wire [WIDTH - 1: 0] row_index;
    wire [HEIGHT - 1: 0] column_index;
    assign row_index = (hpos - BACKGROUND_WIDTH/2) / CELL_SIZE;
    assign column_index = (vpos - BACKGROUND_HEIGHT/2) / CELL_SIZE;
    // Compute wheres the location of the cell in the board
    wire [WIDTH + HEIGHT - 1: 0] location = (column_index * BOARD_WIDTH) + row_index;
    //Genrate RGB signals for the board
    reg [1:0] R_reg, G_reg, B_reg;
    always @* begin
        // Default color
        R_reg = 2'b00;
        G_reg = 2'b00; 
        B_reg = 2'b00;
        if (boundary) begin
            if (curr_board[location] == 1'b1) begin
                R_reg = 2'b00;
                G_reg = 2'b00;
                B_reg = 2'b00;
            end
            else begin
              R_reg = 2'b10;
              G_reg = 2'b10;
              B_reg= 2'b10;
            end
        end
        else if (visible) begin
          R_reg = 2'b01;
          G_reg = 2'b10;
          B_reg = 2'b10;
        end
    end
    assign R = R_reg;
    assign G = G_reg;
    assign B = B_reg;
    
    reg [5:0] frame_count;
    integer i;

    reg [3:0] neighbours;

    reg [1:0] test;
//======================= LOGIC ================================//
always @(posedge vsync) begin
    // set initial state
    if (frame_count == 0 && test == 0) begin
      curr_board[3] <= 1;

      test <= 1;
    end

    if (frame_count == 60) begin
      for (i = 0; i <= 255; i++) 
        prev_board[i] = curr_board[i];
      for (i = 0; i <= 255; i++) begin
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
        if (prev_board == 1) begin
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
      frame_count <= 0;
    end else
      frame_count <= frame_count + 1;
  end
end
endmodule
