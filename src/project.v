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
// 	//=================GOOSE BACKGROUND =========================//
//     localparam GOOSE_X_START = 10;
//     localparam GOOSE_Y_START = 470;
//     localparam GOOSE_CELL_SIZE = 5;
//     localparam GOOSE_WIDTH = 32 * GOOSE_CELL_SIZE;
//     localparam GOOSE_HEIGHT = 32 * GOOSE_CELL_SIZE;

//     wire goose_region = (hpos >= GOOSE_X_START) &&
//                         (hpos < GOOSE_X_START + GOOSE_WIDTH) &&
//                         (vpos < GOOSE_Y_START) &&
//                         (vpos >= GOOSE_Y_START - GOOSE_HEIGHT);
//     reg [1:0] R_goose;
//     reg [1:0] B_goose;
//     reg [1:0] G_goose;
//     wire [2:0] white_goose, black_goose, orange_goose, red_goose;
//     // Frame 0 goose
//     assign white_goose[0] =  (((hpos >= GOOSE_X_START + 13 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 19 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 5 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 6 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 10 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 6 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 7 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 8 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 7 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 9 * GOOSE_CELL_SIZE)))  ||
//                         (((hpos >= GOOSE_X_START + 9 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 9 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 10 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 10 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 10 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 11 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 11 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 11 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 12 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 12 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 14 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 20 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 14 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 16 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 16 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 17 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 20 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 17 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 18 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 18 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 20 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 18 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 20 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 18 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 20 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 20 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE)));
//     assign black_goose[0] =  (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 15 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 1 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 2 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 1 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 2 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 13 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 14 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 16 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 4 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 18 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 19 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 10 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 14 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 5 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 6 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 19 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 5 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 6 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 8 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 10 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 6 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 7 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 6 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 7 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 7 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 8 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 7 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 10 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 22 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 23 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 7 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 11 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 8 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 9 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 9 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 10 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 9 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 10 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 10 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 11 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 10 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 11 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 11 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 12 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 11 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 14 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 11 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 12 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 13 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 13 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 14 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 16 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 14 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 20 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 20 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 14 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 16 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 23 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 16 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 17 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 23 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 24 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 17 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 18 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 22 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 23 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 18 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 19 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 20 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 21 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 22 * GOOSE_CELL_SIZE))) ||
//                         (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 18 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 20 * GOOSE_CELL_SIZE)));
//     assign orange_goose[0] =  (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 15 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 16 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 4 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 20 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 23 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 17 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 18 * GOOSE_CELL_SIZE)));
//     assign red_goose[0] =     (((hpos >= GOOSE_X_START + 20 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 18 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 19 * GOOSE_CELL_SIZE)));
//     // Frame 1 goose
//     assign white_goose[1] =   (((hpos >= GOOSE_X_START + 12 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 5 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 6 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 9 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 20 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 6 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 7 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 7 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 7 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 9 * GOOSE_CELL_SIZE)))  ||
//                               (((hpos >= GOOSE_X_START + 8 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 9 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 10 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 9 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 10 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 11 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 11 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 11 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 12 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 20 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 12 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 14 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 14 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 16 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 19 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 16 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 17 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 17 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 19 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 20 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 15 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 22 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 19 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 23 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 21 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 23 * GOOSE_CELL_SIZE)));
//     assign black_goose[1] =   (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 15 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 1 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 2 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 1 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 2 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 13 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 14 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 4 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 16 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 3 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 18 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 19 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 4 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 4 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 12 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 13 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 4 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 9 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 12 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 5 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 6 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 18 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 20 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 5 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 6 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 7 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 9 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 6 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 7 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 20 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 6 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 7 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 6 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 7 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 7 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 10 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 7 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 12 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 7 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 8 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 9 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 10 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 8 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 9 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 10 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 11 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 9 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 11 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 11 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 12 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 11 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 16 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 12 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 13 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 20 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 12 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 16 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 16 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 13 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 14 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 15 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 14 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 16 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 13 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 14 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 16 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 22 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 19 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 20 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 16 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 17 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 18 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 17 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 18 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 20 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 18 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 20 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 19 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 21 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 22 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 15 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 22 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 23 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 19 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 20 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 22 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 23 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 20 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 19 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 23 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 24 * GOOSE_CELL_SIZE)));
//     assign orange_goose[1] =  (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 15 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 13 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 14 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 4 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 4 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 3 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 18 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 20 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 18 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 19 * GOOSE_CELL_SIZE)));
//     assign red_goose[1]    =  (((hpos >= GOOSE_X_START + 19 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 20 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE)))||
//                               (((hpos >= GOOSE_X_START + 20 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 20 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE)));
//     // Frame 2 goose
//     assign white_goose[2] =   (((hpos >= GOOSE_X_START + 13 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 19 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 5 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 6 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 10 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 6 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 7 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 8 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 7 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 9 * GOOSE_CELL_SIZE)))  ||
//                               (((hpos >= GOOSE_X_START + 9 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 9 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 10 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 10 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 10 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 11 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 11 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 11 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 12 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 13 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 12 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 13 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 13 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 19 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 17 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 18 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 19 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 22 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 20 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 22 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 18 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 19 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 21 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 22 * GOOSE_CELL_SIZE)));
//     assign black_goose[2] =   (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 15 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 1 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 2 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 1 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 2 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 13 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 14 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 16 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 4 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 18 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 19 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 10 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 13 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 5 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 6 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 19 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 21 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 5 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 6 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 8 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 10 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 6 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 7 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 6 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 7 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 7 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 8 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 7 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 10 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 22 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 23 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 7 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 12 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 8 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 9 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 9 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 10 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 9 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 10 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 10 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 11 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 10 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 11 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 11 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 12 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 11 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 13 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 12 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 13 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 12 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 17 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 13 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 16 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 13 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 14 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 16 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 17 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 13 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 22 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 24 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 17 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 18 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 24 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 25 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 18 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 19 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 23 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 24 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 20 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 22 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 23 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 20 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 22 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 21 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 22 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 18 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 22 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 22 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 23 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 18 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 19 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 21 * GOOSE_CELL_SIZE)));
//     assign orange_goose[2] =  (((hpos >= GOOSE_X_START + 14 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 15 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 15 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 16 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 4 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 17 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 18 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 2 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 5 * GOOSE_CELL_SIZE))) ||
//                               (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 24 * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 18 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 19 * GOOSE_CELL_SIZE)));
//     assign red_goose[2] =     (((hpos >= GOOSE_X_START + 21 * GOOSE_CELL_SIZE) && (hpos < GOOSE_X_START + 23   * GOOSE_CELL_SIZE)) && ((vpos < GOOSE_Y_START - 19 * GOOSE_CELL_SIZE) && (vpos >= GOOSE_Y_START - 20 * GOOSE_CELL_SIZE)));



// reg [5:0] geese_frame_count = 0;
// integer geese_frame = 0;
// // Frame counter (sequential)
//     always @(posedge vsync) begin
//       if(geese_frame_count == 60) begin
//         geese_frame_count <= 0;
//         if (geese_frame == 2)
//           geese_frame <= 0;
//         else
//           geese_frame <= geese_frame + 1;
//       end else begin
//         geese_frame_count <= geese_frame_count + 1;
//       end
//     end

//     always @(*) begin
//       R_goose = 2'b01;
//       G_goose = 2'b10; 
//       B_goose = 2'b10;
//       if (white_goose[geese_frame]) begin
//         R_goose = 2'b11; 
//         G_goose = 2'b11; 
//         B_goose = 2'b11;
//       end
//       if (black_goose[geese_frame]) begin
//       R_goose = 2'b00; 
//       G_goose = 2'b00; 
//       B_goose = 2'b00;
//       end
//       if (orange_goose[geese_frame]) begin
//         R_goose = 2'b11; 
//         G_goose = 2'b01; 
//         B_goose = 2'b10;
//       end
//       if (red_goose[geese_frame]) begin
//         R_goose = 2'b11; 
//         G_goose = 2'b00; 
//         B_goose = 2'b00;
//       end
//   end

    //==================OTHER WIRE REGISTERS=====================//                                        
    //Checking the region belongs to 640 x 480 board or not, boundary works as a boolean
    wire boundary = (hpos < 640 - BACKGROUND_WIDTH/2) &&
                    (hpos >= BACKGROUND_WIDTH/2) &&
                    (vpos < 480 - BACKGROUND_HEIGHT/2) &&
                    (vpos >= BACKGROUND_HEIGHT/2);
    wire visible = (hpos < 640) && (vpos < 480);
    // Assign which cell this pixel belongs to
    wire [BIT_WIDTH - 1: 0] row_index;
    wire [BIT_HEIGHT - 1: 0] column_index;
    assign row_index = (hpos - BACKGROUND_WIDTH/2) / CELL_SIZE;
    assign column_index = (vpos - BACKGROUND_HEIGHT/2) / CELL_SIZE;
    // Compute wheres the location of the cell in the board
    wire [BIT_WIDTH + BIT_HEIGHT - 1: 0] location = (column_index * BOARD_WIDTH) + row_index;
    //Genrate RGB signals for the board
	assign R =	(boundary && curr_board[location]) 	? 	2'b00 :
				(boundary && !curr_board[location]) ? 	2'b10 :
        		visible                           	? 	2'b01 :
														2'b00;
	assign G =	(boundary && curr_board[location]) 	? 	2'b00 :
				(boundary && !curr_board[location]) ? 	2'b10 :
        		visible                           	? 	2'b10 :
														2'b00;
	assign B =	(boundary && curr_board[location]) 	? 	2'b00 :
				(boundary && !curr_board[location]) ? 	2'b10 :
        		visible                           	? 	2'b10 :
														2'b00;
	// assign R =	goose_region                        ?   R_goose :
 //              	(boundary && curr_board[location]) 	? 	2'b00 :
	// 			(boundary && !curr_board[location]) ? 	2'b10 :
 //        		visible                           	? 	2'b01 :
	// 													2'b00;
	// assign G =	goose_region                        ?   B_goose :
 //              	(boundary && curr_board[location]) 	? 	2'b00 :
	// 			(boundary && !curr_board[location]) ? 	2'b10 :
 //        		visible                           	? 	2'b10 :
	// 													2'b00;
	// assign B =	goose_region                        ?   G_goose :
 //              	(boundary && curr_board[location]) 	? 	2'b00 :
	// 			(boundary && !curr_board[location]) ? 	2'b10 :
 //        		visible                           	? 	2'b10 :
	// 													2'b00;

//======================= LOGIC ================================//
    reg [5:0] frame_count;
	reg [BIT_WIDTH + BIT_HEIGHT : 0] i;
    reg [3:0] neighbours;
    reg [1:0] test;
	always @(posedge vsync) begin
        // set initial state
      // U
		if(frame_count == 0 && test == 0) begin
      curr_board[3] <= 1;
      // curr_board[6] <= 1;
      // curr_board[19] <= 1;
      // curr_board[22] <= 1;
      // curr_board[35] <= 1;
      // curr_board[38] <= 1;
      // curr_board[52] <= 1;
      // curr_board[53] <= 1;

      // // W
      // curr_board[8] <= 1;
      // curr_board[12] <= 1;
      // curr_board[24] <= 1;
      // curr_board[28] <= 1;
      // curr_board[40] <= 1;
      // curr_board[42] <= 1;
      // curr_board[44] <= 1;
      // curr_board[57] <= 1;
      // curr_board[59] <= 1;

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
				for (i = 0; i <= SIZE - 1; i++) 
		        	prev_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] = curr_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]];
				for (i = 0; i <= SIZE - 1; i++) begin
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
					if (prev_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] == 1) begin
						if (neighbours == 2 || neighbours == 3)
							curr_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] = 1;
						else
							curr_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] = 0;
					end else begin
						if (neighbours == 3)
							curr_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] = 1;
						else
							curr_board[i[BIT_WIDTH + BIT_HEIGHT - 1 : 0]] = 0;
					end
				end
				frame_count <= 0;
			end else
				frame_count <= frame_count + 1;
	end
endmodule
