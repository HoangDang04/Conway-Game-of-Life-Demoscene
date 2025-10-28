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

    // Start/ Stop simulations
    wire run;
    assign run = ui_in[0];

    
    
    // =============REGISTER SIZE OF THE BOARD=================//
    localparam CLOCK_FREQ = 24000000;
    localparam WIDTH = 4, HEIGHT = 4;
    localparam interval = CLOCK_FREQ / 10;
    localparam WIDTH_BIT = 2 ** 4;
    localparam HEIGHT_BIT = 2 ** 4;
    localparam SIZE = WIDTH_BIT * HEIGHT_BIT;

    reg curr_board [0:SIZE-1];
    reg next_board [0:SIZE-1];
    //===================CONTROL LOGIC===========================//
    localparam IDLE = 0, UPDATE = 1, COPY = 2;
    reg [2:0] curr_action, next_action;
    reg action_done, action_update, action_copy;
    reg [31:0] timer, next_timer;

    always @(posedge clk) begin
        action <= next_action;
        timer <= next_timer
    end

    always @* begin
        next_action = curr_action;
        next_timer = curr_timer;

        case (curr_action)
            IDLE: begin
                // when run still turns on then it works as normally
                if (run) begin
                    if (timer < interval) begin
                        next_timer = timer + 1:
                    // when it is finished then move to update
                    end else if (vsync) begin
                        next_timer = 0;
                        next_action = UPDATE;
                    end
                end else begin
                    next_timer = timer
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
                next_action = IDLE
                timer = 0;
            end
        endcase
    end
                
                    
    //===================CELL FUNCTION UPDATE====================//
    localparam HEIGHT_MASK = {HEIGHT{1'b1}};
    localparam WIDTH_MASK = {WIDTH{1'b1}};

    reg [WIDTH + HEIGHT - 1:0] three_by_three;
    wire [WIDTH - 1:0] x_cell = three_by_three[WIDTH - 1:0];
    wire [HEIGHT -1:0] y_cell = three_by_three[WIDTH + HEIGHT -1: WIDTH];

    reg [3:0] neigh_index;
    reg [3:0] num_neighbours;

    localparam CELL_IDLE = 0, CELL_COUNT = 1, CELL_UPDATE = 2, CELL_DONE = 3;

    reg[1:0] update_state;

    always @(posedge clk) begin
        case (update_state)
            CELL_IDLE: begin
                if (action == UPDATE) begin
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

                case (neight_index)
                    0: begin neigh_x = cell_x - 1; neigh_y = neigh_y + 1; end
                    1: begin neigh_x = cell_x + 0; neigh_y = neigh_y + 1; end
                    2: begin neigh_x = cell_x + 1; neigh_y = neigh_y + 1; end
                    3: begin neigh_x = cell_x - 1; neigh_y = neigh_y + 0; end
                    4: begin neigh_x = cell_x + 1; neigh_y = neigh_y + 0; end
                    5: begin neigh_x = cell_x - 1; neigh_y = neigh_y - 1; end
                    6: begin neigh_x = cell_x + 0; neigh_y = neigh_y + 1; end
                    7: begin neigh_x = cell_x + 1; neigh_y = neigh_y + 1; end
                endcase
                // Check the state of the neighbour cell and add to count how many value of neighbours alive
                num_neighbours <= num_neighbours + curr_board[{(neigh_x & HEIGHT_MASK), (neigh_y & WIDTH_MASK)}];
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
                next_board[three_by_three] <= (next_board[three_by_three] && (num_neighbours == 2)) || (num_neighbours == 3);
                num_neighbours <+ 0;
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
                if(action != UPDATE) begin
                    action_update <= 0;
                    update_state <= IDLE;
                end
            end
        endcase
    end
    
      // List all unused inputs to prevent warnings
    wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
