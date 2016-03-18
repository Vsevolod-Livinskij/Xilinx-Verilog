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
    reg start;
    reg [6:0] addr;
    reg [7:0] sub;
    reg [7:0] data;
    //Output
    wire i2c_sda;
    //pullup(i2c_sda);
    wire i2c_scl;
    //pullup(i2c_scl);
    wire i2c_clk;
    wire ready;
    
    initial begin
        clk = 0;
        forever begin
            clk = #1 ~clk;
        end
    end

    initial begin
        addr <=  7'b1010101;//7'b1101000;
        sub <= 8'b10101010; //8'h20
        data <= 8'b10101010; //8'h0F
        reset <= 1;
        start <= 0;
        #10
        reset <= 0;
        #20
        start <= 1;
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
        .start(start),
        .addr(addr),
        .sub(sub),
        .data(data),
        .ready(ready),
        .i2c_sda(i2c_sda),
        .i2c_scl(i2c_scl)
    );

endmodule
