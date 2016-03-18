`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2016 12:40:52
// Design Name: 
// Module Name: I2C_testbench
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


module I2C_testbench();
    // Input
    reg clk;
    reg reset;
    //Output
    wire i2c_sda;
    wire i2c_scl;
    wire i2c_clk;
    
    initial begin
        clk = 0;
        forever begin
            clk = #1 ~clk;
        end
    end

    initial begin
        reset <= 1;
        #10
        reset <= 0;
        #1000;
        //$finish;
    end

    I2C_clk_div #(.DELAY(5000)) clk_div (
        .ref_clk(clk),
        .i2c_clk(i2c_clk)
        );

    I2C_master uut (
        .clk(i2c_clk),
        .reset(reset),
        .i2c_sda(i2c_sda),
        .i2c_scl(i2c_scl)
    );

endmodule
