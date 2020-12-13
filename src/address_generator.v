`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Engineering Lab - CSE - HCMUT
// Engineer: Nguyen Xuan Quang
// 
// Create Date: 11/24/2020 10:56:06 AM
// Design Name: pynq-z2-hdmi-out-nomem
// Module Name: address_generator
// Project Name: pynq-z2-hdmi-out-nomem
// Target Devices: pynq-z2
// Tool Versions: 2018.2
// Description: Generate address from video timing output
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module address_generator
#(
    parameter COL_ADDR_WIDTH = 11,
    parameter ROW_ADDR_WIDTH = 10,
    parameter MAX_COL = 11'd1280,
    parameter MAX_ROW = 11'd1024
)
(
    input clk,
    input valid,
    input ready,
    input sof,
    input eol,
    output [ROW_ADDR_WIDTH-1:0] row,
    output [COL_ADDR_WIDTH-1:0] col,
    output next_pixel
);
    
    reg [ROW_ADDR_WIDTH-1:0] row_reg = 0;
    reg [COL_ADDR_WIDTH-1:0] col_reg = 0;
    
    assign col = col_reg;
    assign row = sof ? 0 : row_reg;
    
    wire enb = valid & ready;
    assign next_pixel = enb;
    
    always@(posedge clk) begin
        if (enb) begin
            if (eol)
                col_reg <= 0;
            else
                col_reg <= col + 1'b1;
        end
    end
    
    always@(posedge clk) begin
        if (enb) begin
            if (sof)
                row_reg <= 0;
            else if (eol)
                row_reg <= row + 1'b1;
        end
    end
    
endmodule
