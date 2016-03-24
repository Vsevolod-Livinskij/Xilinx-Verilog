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
    (* mark_debug = "true" *) inout wire [7:0] JA,
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
    
    wire i2c_clk_dbg;
    assign JA [0] = i2c_clk_dbg;
    assign JA [1] = i2c_clk;
    //assign JA[0] = i2c_clk;
    wire ready;
    //assign JA[7] = ready;
    wire done;
    assign JA[7] = done;
    
    wire i2c_scl_out_wire;
    wire i2c_scl_enable_wire;
    //assign JA [4] = i2c_scl_out_wire ? 1'bZ : 0;
    assign JA [4] = i2c_scl_out_wire;
    assign JA [3] = i2c_scl_enable_wire;
    
    (* mark_debug = "true" *) wire i2c_sda_in_wire;
    assign i2c_sda_in_wire = JA[5];
    (* mark_debug = "true" *) wire i2c_sda_out_wire;
    (* mark_debug = "true" *) wire i2c_sda_out_mode_wire;
    //assign JA[5] = i2c_sda_out_mode_wire ? (i2c_sda_out_wire ? 1'bZ : 0) : 1'bZ;
    assign JA[5] = i2c_sda_out_wire;
    
    wire [3:0] state_wire;
    //assign JA [0] = state_wire [0];
    //assign JA [1] = state_wire [1];
    //assign JA [2] = state_wire [2];
    //assign JA [3] = state_wire [3];
    //assign JA [1] = i2c_sda_out_wire;
    assign JA [6] = i2c_sda_out_mode_wire;
    //assign JA [3] = i2c_scl_out_wire;
    
    I2C_master uut (
        .clk(i2c_clk),
        .reset(BTNC),
        .start(BTND),
        .addr(addr),
        .sub(sub),
        .data(data),
        .ready(ready),
        .i2c_sda_in(i2c_sda_in_wire),
        .i2c_sda_out(i2c_sda_out_wire),
        .i2c_sda_out_mode(i2c_sda_out_mode_wire),
        .i2c_scl(i2c_scl_out_wire),
        .done(done),
        .out_clk(i2c_clk_dbg),
        .state_wire(state_wire),
        .i2c_scl_enable_wire(i2c_scl_enable_wire)
    );

endmodule
