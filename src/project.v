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
    wire show_on_vga;
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

    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(show_on_vga),
        .hpos(hpos),
        .vpos(vpos)
    );
    // =============REGISTER SIZE OF THE BOARD=================//
    localparam CLOCK_FREQ = 24000000;
    localparam WIDTH = 4, HEIGHT = 4;
    localparam interval = CLOCK_FREQ / 10;
    
    localparam BOARD_WIDTH = 2 ** WIDTH;
    localparam BOARD_HEIGHT = 2 ** HEIGHT;
    localparam SIZE = BOARD_WIDTH * BOARD_HEIGHT;
    
    localparam CELL_SIZE = 24;
    localparam BACKGROUND_HEIGHT = 480 - (CELL_SIZE * BOARD_HEIGHT);     // how much left of height in the background
    localparam BACKGROUND_WIDTH = 640 - (CELL_SIZE * BOARD_WIDTH);    // how much left of width in the background

    reg curr_board [0:SIZE-1];
    reg next_board [0:SIZE-1];

    //==================OTHER WIRE REGISTERS=====================//                                        
    //Checking the region belongs to 640 x 480 board or not, boundary works as a boolean
    wire boundary = (hpos < 640 - BACKGROUND_WIDTH/2) &&
                    (hpos >= BACKGROUND_WIDTH/2) &&
                    (vpos < 480 - BACKGROUND_HEIGHT/2) &&
                    (vpos >= BACKGROUND_HEIGHT/2);

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
        R_reg = 2'b10;
        G_reg = 2'b01; 
        B_reg = 2'b01;
        if (show_on_vga && boundary) begin
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
    end
    assign R = R_reg;
    assign G = G_reg;
    assign B = B_reg;
    
//===================CONTROL LOGIC===========================//
    localparam IDLE = 0, UPDATE = 1, COPY = 2;
    reg [2:0] curr_action, next_action;
    reg action_done, action_update, action_copy;
    reg [31:0] timer, next_timer;

    always @(posedge clk) begin
        curr_action <= next_action;
        timer <= next_timer;
    end

    always @* begin
        next_action = curr_action;
        next_timer = timer;

        case (curr_action)
            IDLE: begin
                // when run still turns on then it works as normally
                if (run) begin
                    if (timer < interval) begin
                        next_timer = timer + 1;
                    // when it is finished then move to update
                    end else if (vsync) begin
                        next_timer = 0;
                        next_action = UPDATE;
                    end
                end else begin
                    next_timer = timer;
                end
            end
            UPDATE: begin
                if(action_update)
                    next_action = COPY;
            end
            COPY: begin
                if(action_copy)
                    next_action = IDLE;
            end
            default: begin
                next_action = IDLE;
                timer = 0;
            end
        endcase
    end
                
                    
    //===================CELL FUNCTION UPDATE====================//
    localparam HEIGHT_MASK = {HEIGHT{1'b1}};
    localparam WIDTH_MASK = {WIDTH{1'b1}};

    reg [WIDTH + HEIGHT - 1:0] three_by_three;
    wire [WIDTH - 1:0] cell_x = three_by_three[WIDTH - 1:0];
    wire [HEIGHT -1:0] cell_y = three_by_three[WIDTH + HEIGHT -1: WIDTH];

    reg [3:0] neigh_index;
    reg [3:0] num_neighbours;

    localparam CELL_IDLE = 0, CELL_COUNT = 1, CELL_UPDATE = 2, CELL_DONE = 3;

    reg[1:0] update_state;

    always @(posedge clk) begin
        case (update_state)
            CELL_IDLE: begin
                if (curr_action == UPDATE) begin
                    three_by_three <= 0;
                    neigh_index <= 0;
                    num_neighbours <= 0;
                    action_update <= 0;
                    update_state <= CELL_COUNT;
                end
            end
            // Count neghbours (one per clock)
            CELL_COUNT: begin
                reg [WIDTH - 1:0] neigh_x;
                reg [HEIGHT - 1:0] neigh_y;

                case (neigh_index)
                    0: begin neigh_x = cell_x - 1; neigh_y = cell_y + 1; end
                    1: begin neigh_x = cell_x + 0; neigh_y = cell_y + 1; end
                    2: begin neigh_x = cell_x + 1; neigh_y = cell_y + 1; end
                    3: begin neigh_x = cell_x - 1; neigh_y = cell_y + 0; end
                    4: begin neigh_x = cell_x + 1; neigh_y = cell_y + 0; end
                    5: begin neigh_x = cell_x - 1; neigh_y = cell_y - 1; end
                    6: begin neigh_x = cell_x + 0; neigh_y = cell_y - 1; end
                    7: begin neigh_x = cell_x + 1; neigh_y = cell_y - 1; end
                endcase
                // Check the state of the neighbour cell and add to count how many value of neighbours alive
                num_neighbours <= num_neighbours + curr_board[{(neigh_x & WIDTH_MASK), (neigh_y & HEIGHT_MASK)}];
                // When checking all neighbour cells, move into CELL_UPDATE
                if(neigh_index == 7) begin
                    neigh_index <= 0;
                    update_state <= CELL_UPDATE;
                end else begin
                    neigh_index <= neigh_index + 1;
                end
            end
            // Update current cell after counting all neighbours
            CELL_UPDATE: begin
                // The rule of this one is any live cell with two live cells with cell alives live, any 3 cells surrounding lives even it is alive or not
                next_board[three_by_three] <= (curr_board[three_by_three] && (num_neighbours == 2)) || (num_neighbours == 3);
                num_neighbours <= 0;
                // Advance to next cell or finish all
                if (three_by_three == SIZE - 1) begin
                    action_update <= 1;
                    update_state <= CELL_DONE;
                end else begin
                    three_by_three <= three_by_three + 1;
                    update_state <= CELL_COUNT;
                end
            end
            // Wait until control FSM changes action
            CELL_DONE: begin
                if(curr_action != UPDATE) begin
                    action_update <= 0;
                    update_state <= CELL_IDLE;
                end
            end
        endcase
    end
  
endmodule
