`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Engineering Lab - CSE - HCMUT
// Engineer: Nguyen Xuan Quang
// 
// Create Date: 11/24/2020 11:19:48 AM
// Design Name: pynq-z2-hdmi-out-nomem
// Module Name: video_pattern_generator
// Project Name: pynq-z2-hdmi-out-nomem
// Target Devices: pynq-z2
// Tool Versions: 2018.2
// Description: Video pattern generator to test board design of pynq-z2-hdmi-out-nomem
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module video_pattern_generator
#(
    parameter DATA_WIDTH     = 24,
    parameter ROW_ADDR_WIDTH = 10,
    parameter COL_ADDR_WIDTH = 11,
    parameter PATTERN_MODE   = 1,
    parameter MAX_COL        = 11'd1280,
    parameter MAX_ROW        = 11'd1024
)
(
    input clk,
    input next_pixel,
    input [ROW_ADDR_WIDTH-1:0] row_address,
    input [COL_ADDR_WIDTH-1:0] col_address,
    output [DATA_WIDTH-1:0] data_out
);
    reg [DATA_WIDTH-1:0] data_reg = 0;
    assign data_out = data_reg;

    // User mode
    // `define USER_MODE
    `ifdef USER_MODE
    
    // TODO
    // Implement logics that allow user to choose type of pattern by input (switch)

    // PATTERN = 1
    // Blank screen
    `else

        // Define statement
        // Uncomment 1 of following statements to use its pattern
        // `define PATTERN_MODE_BLANK
        // `define PATTERN_MODE_WHITE
        // `define PATTERN_MODE_COLOR_BARS
        `define PATTERN_MODE_COLOR_CHANGE

        // Implementation
        `ifdef PATTERN_MODE_BLANK
        always @(posedge clk) begin
            data_reg <= 24'h000000;
        end
        
        `elsif PATTERN_MODE_WHITE
        always @(posedge clk) begin
            data_reg <= 24'hffffff;
        end

        `elsif PATTERN_MODE_COLOR_BARS
        wire [DATA_WIDTH-1:0] color_bar;
        assign color_bar = (col_address < MAX_COL/9 * 1) ? 24'hebebeb : 
                           (col_address < MAX_COL/9 * 2) ? 24'hb4b4b4 : 
                           (col_address < MAX_COL/9 * 3) ? 24'hebeb10 : 
                           (col_address < MAX_COL/9 * 4) ? 24'h10ebeb : 
                           (col_address < MAX_COL/9 * 5) ? 24'h10eb10 : 
                           (col_address < MAX_COL/9 * 6) ? 24'heb10eb : 
                           (col_address < MAX_COL/9 * 7) ? 24'heb1010 : 
                           (col_address < MAX_COL/9 * 8) ? 24'h1010eb : 24'h101010;
        always @(posedge clk) begin
            data_reg <= color_bar;
        end

        `elsif PATTERN_MODE_COLOR_CHANGE
        reg [2:0] state = 0, next_state;
        reg [7:0] counter = 0;
        
        wire next_frame;
        assign next_frame = (row_address == MAX_ROW - 1) && (col_address == MAX_COL - 1);

        // State machine
        always @(posedge clk) begin
            state <= next_state;
        end

        always @(state, data_reg) begin
            case (state)
                3'b000: begin
                    if (data_reg[7:0] == 8'hfe) next_state = 3'b001;
                    else next_state = 3'b000;
                end
                3'b001: begin
                    if (data_reg[15:8] == 8'hfe) next_state = 3'b010;
                    else next_state = 3'b001;
                end
                3'b010: begin
                    if (data_reg[7:0] == 8'h01) next_state = 3'b011;
                    else next_state = 3'b010;
                end
                3'b011: begin
                    if (data_reg[23:16] == 8'hfe) next_state = 3'b100;
                    else next_state = 3'b011;
                end
                3'b100: begin
                    if (data_reg[15:8] == 8'h01) next_state = 3'b101;
                    else next_state = 3'b100;
                end
                3'b101: begin
                    if (data_reg[23:16] == 8'h01) next_state = 3'b000;
                    else next_state = 3'b101;
                end
                default: next_state = state;
            endcase
        end

        // Data
        always @(posedge clk) begin
            if (next_frame) begin
                if (state == 3'b000) begin
                    data_reg[07:00] <= data_reg[07:00] + 1'b1;
                end else if (state == 3'b001) begin
                    data_reg[15:08] <= data_reg[15:08] + 1'b1;
                end else if (state == 3'b010) begin
                    data_reg[07:00] <= data_reg[07:00] - 1'b1;
                end else if (state == 3'b011) begin
                    data_reg[23:16] <= data_reg[23:16] + 1'b1;
                end else if (state == 3'b100) begin
                    data_reg[15:08] <= data_reg[15:08] - 1'b1;
                end else if (state == 3'b101) begin
                    data_reg[23:16] <= data_reg[23:16] - 1'b1;
                end
            end
        end

        `endif
    `endif


endmodule
