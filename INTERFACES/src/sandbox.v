`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2016 14:56:48
// Design Name: 
// Module Name: sandbox
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


module sandbox
    (
    output wire [127:0] OLED_S0,
    output wire [127:0] OLED_S1,
    output wire [127:0] OLED_S2,
    output wire [127:0] OLED_S3,
    input wire GCLK,
    output wire [7:0] LD,
    input wire [7:0] SW,
    output wire [7:0] JA,
    input wire [7:0] JB,
    input wire BTNC,
    input wire BTND,
    input wire BTNL,
    input wire BTNR,
    input wire BTNU
    );
    
    reg [6:0] addr = 7'b1101000;
    reg [7:0] sub = 8'h20;
    reg [7:0] data = 8'h0F;
    
    wire i2c_clk;
    
    I2C_clk_div #(.DELAY(50)) clk_div (
    .ref_clk(GCLK),
    .i2c_clk(i2c_clk)
    );
    
    assign JA[0] = i2c_clk;
    wire ready;
    assign LD[0] = ready;
    assign JA[6] = ready;
    
    I2C_master uut (
        .clk(i2c_clk),
        .reset(BTNC),
        .start(BTND),
        .addr(addr),
        .sub(sub),
        .data(data),
        .ready(ready),
        .i2c_sda(JA[5]),
        .i2c_scl(JA[4])
    );
endmodule
