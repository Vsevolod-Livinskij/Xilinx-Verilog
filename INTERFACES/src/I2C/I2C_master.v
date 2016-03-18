`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2016 01:01:26
// Design Name: 
// Module Name: I2C_master
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


module I2C_master(
    input clk,
    input reset,
    input start,
    input [6:0] addr,
    input [7:0] sub,
    input [7:0] data,
    output wire ready,
    inout wire i2c_sda,
    inout wire i2c_scl
    );
    
reg [127:0] state = "Idle";
reg [6:0] saved_addr = 0;//7'b1101000;
reg [7:0] saved_sub = 0;//8'h20;
reg [7:0] saved_data = 0;//8'h0F;
reg [7:0] count = 0;
reg i2c_scl_enable = 0;
assign i2c_scl = ((i2c_scl_enable == 0) ? 1 : ~clk);// ? 1'bZ : 0;
assign ready = (reset == 0) && (state == "Idle");

reg i2c_sda_reg = 1;
assign i2c_sda = (i2c_sda_reg ? 1'bZ : 0);

always @(negedge clk)
begin
    if (reset) begin
        i2c_scl_enable <= 0;
    end
    else begin
        if ((state == "Idle") || (state == "Start") || (state == "Stop")) begin
            i2c_scl_enable <= 0;
        end
        else begin
            i2c_scl_enable <= 1;
        end
    end
end


always @(posedge clk)
begin
    if (reset) begin
        i2c_sda_reg <= 1;
        state <= "Idle";
        count <= 0;
        saved_addr <= 0;
        saved_sub <= 0;
        saved_data <= 0;
    end
    else begin
        case (state)

            "Idle" : begin
                i2c_sda_reg <= 1;
                state <= start ? "Start" : "Idle";
                saved_addr <= start ? addr : saved_addr;
                saved_sub <= start ? sub : saved_sub;
                saved_data <= start ? data : saved_data;
            end
            
            "Start" : begin
                i2c_sda_reg <= 0;
                state <= "TR_Addr";
                count <= 7'd6;
            end
            
            "TR_Addr" : begin
                i2c_sda_reg <= saved_addr [count];
                if (count == 0) 
                    state <= "TR_RW";
                else
                    count <= count - 1;
            end
            
            "TR_RW" : begin
                i2c_sda_reg <= 0; //TODO: Should be 1;
                state <= "WSAK";
            end
            
            "WSAK" : begin
                state <= "TR_Sub";
                count <= 7'd7;
            end
            
            "TR_Sub" : begin
                i2c_sda_reg <= saved_sub [count];
                if (count == 0) 
                    state <= "WSAK2";
                else
                    count <= count - 1;
            end
            
            "WSAK2" : begin
                state <= "TR_Data";
                count <= 7'd7;
            end
            
            "TR_Data" : begin
                i2c_sda_reg <= saved_data [count];
                if (count == 0) 
                    state <= "WSAK3";
                else
                    count <= count - 1;
            end

            "WSAK3" : begin
                state <= "Stop";
            end
            
            "Stop" : begin
                i2c_sda_reg <= 1;
                state <= "Stop";
            end
            
            default : state <= "Idle";
        endcase
    end
end
endmodule
