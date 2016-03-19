`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2016 14:31:03
// Design Name: 
// Module Name: I2C_clk_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module I2C_clk_div(
    input wire ref_clk,
    (* mark_debug = "true" *) output reg i2c_clk
    );

parameter DELAY = 5000;
(* mark_debug = "true" *) reg [15:0] count = 0;

initial begin
    count <= 0;
    i2c_clk <= 0;
end

always @(posedge ref_clk)
begin
    if (count == (DELAY / 2) - 1) begin
        i2c_clk <= ~ i2c_clk;
        count <= 0;
    end
    else begin
        count <= count + 15'd1;
    end
end
endmodule
