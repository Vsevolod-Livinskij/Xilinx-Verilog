`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2016 18:21:15
// Design Name: 
// Module Name: toplevelv
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

module toplevel
    (
    GCLK,
    DC,
    RES,
    SCLK,
    SDIN,
    VBAT,
    VDD,
    JA1,
    JA2,
    JA3,
    JA4,
    JA7,
    JA8,
    JA9,
    JA10,
    JB1,
    JB2,
    JB3,
    JB4,
    JB7,
    JB8,
    JB9,
    JB10,
    SW0,
    SW1,
    SW2,
    SW3,
    SW4,
    SW5,
    SW6,
    SW7,
    BTNC,
    BTND,
    BTNL,
    BTNR,
    BTNU,
    LD0,
    LD1,
    LD2,
    LD3,
    LD4,
    LD5,
    LD6,
    LD7
    );

    input wire GCLK;
    output wire DC;
    output wire RES;
    output wire SCLK;
    output wire SDIN;
    output wire VBAT;
    output wire VDD;
    output wire JA1;
    output wire JA2;
    output wire JA3;
    output wire JA4;
    output wire JA7;
    output wire JA8;
    output wire JA9;
    output wire JA10;
    input wire JB1;
    input wire JB2;
    input wire JB3;
    input wire JB4;
    input wire JB7;
    input wire JB8;
    input wire JB9;
    input wire JB10;
    input wire SW0;
    input wire SW1;
    input wire SW2;
    input wire SW3;
    input wire SW4;
    input wire SW5;
    input wire SW6;
    input wire SW7;
    input wire BTNC;
    input wire BTND;
    input wire BTNL;
    input wire BTNR;
    input wire BTNU;
    output wire LD0;
    output wire LD1;
    output wire LD2;
    output wire LD3;
    output wire LD4;
    output wire LD5;
    output wire LD6;
    output wire LD7;

    wire i2c_clk;

     I2C_clk_div #(.DELAY(1000)) i2c_clk_div (
        .ref_clk(GCLK),
        .i2c_clk(i2c_clk)
    );

    wire out_clk;
    wire reset;
    wire start;
    reg [6:0] addr = 7'b1101000;
    reg [7:0] sub = 8'h20;
    reg [7:0] data = 8'h0F;
    wire ready;
    wire i2c_sda_in;
    wire i2c_sda_out;
    wire i2c_sda_out_mode;
    wire i2c_scl;
    wire done;
    wire [3:0] state_wire;
    wire i2c_scl_enable_wire;

    assign JA1 = i2c_clk;
    assign JA2 = out_clk;
    assign JA3 = i2c_sda_out;
    assign JA4 = i2c_sda_out_mode;
    assign JA7 = i2c_scl;
    assign JA8 = i2c_scl_enable_wire;
    assign JA9 = done;
    assign JA10 = ready;
    
    I2C_master uut (
        .clk(i2c_clk),
        .out_clk(out_clk),
        .reset(BTND),
        .start(BTNC),
        .addr(addr),
        .sub(sub),
        .data(data),
        .ready(ready),
        .i2c_sda_in(i2c_sda_in),
        .i2c_sda_out(i2c_sda_out),
        .i2c_sda_out_mode(i2c_sda_out_mode),
        .i2c_scl(i2c_scl),
        .done(done),
        .state_wire(state_wire),
        .i2c_scl_enable_wire(i2c_scl_enable_wire)
    );
endmodule