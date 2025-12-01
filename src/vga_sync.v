`default_nettype none

module vga_sync (
    output reg hsync,
    output reg vsync,
    output reg [9:0] vpos, // vertical total = 525, log2(525) = 9.03 so we need 10 bits.
    output reg [9:0] hpos, // horizontal total = 800, log2(800) = 9.64 so we need 10 bits.
    input wire clk,
    input wire reset
    );

    // Horizontal pixel parameters (pixel counting starts at 0)
    parameter HSyncBegin = 640 + 16; // Send a sync pulse after visible + front porch pixels.
    parameter HsyncEnd = 64 + 16 + 96 - 1; // Continue sending sync pulse until after window.
    parameter HTotal = 640 + 16 + 96 + 48 - 1; // Reset hpos after total pixels has been reached.

    // Vertical line parameters (line counting starts at 0)
    parameter VSyncBegin = 480 + 10; // Send a sync pulse after visible + front porch lines.
    parameter VSyncEnd = 480 + 10 + 2 - 1; // Continue sending sync pulse until after window.
    parameter VTotal = 480 + 10 + 2 + 33 - 1; // Reset vpos after total lines has been reached.

    // Each positive clock edge represents a pixel (see clock timing calculations in design doc).
    always @(posedge clk) begin
        // If the hpos is in the sync window, pulse the hsync.
        hsync <= 1;
        // If reset was pressed or we are at the end of a line, reset the horizontal position.
        if (reset || hpos == HTotal) begin
            hpos <= 0;
        // Otherwise increment the pixel position.
        end else begin
            hpos <= hpos + 1;
        end
    end

    always @(posedge clk) begin
        // If the vpos is in the sync window, pulse the hsync.
        vsync <= 1;
        // If reset was pressed or we are at the final pixel, reset the vertical line position.
        if (reset || (vpos == VTotal && hpos == HTotal)) begin
            vpos <= 0;
        // If we are at the end of a line, increment the vertical line position
        end else if (hpos == HTotal) begin
            vpos <= vpos + 1;
        end
    end

endmodule
