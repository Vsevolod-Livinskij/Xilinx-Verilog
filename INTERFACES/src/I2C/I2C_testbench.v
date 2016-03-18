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
    end

    I2C_master uut (
        .clk(clk),
        .reset(reset),
        .i2c_sda(i2c_sda),
        .i2c_scl(i2c_scl)
    );

endmodule
