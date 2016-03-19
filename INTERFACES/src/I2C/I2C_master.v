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
    (* mark_debug = "true" *) input clk,
    (* mark_debug = "true" *) input reset,
    (* mark_debug = "true" *) input start,
    input [6:0] addr,
    input [7:0] sub,
    input [7:0] data,
    (* mark_debug = "true" *) output wire ready,
    (* mark_debug = "true" *) inout wire i2c_sda,
    (* mark_debug = "true" *) inout wire i2c_scl,
    output wire dbg_scl_out,
    output wire dbg_sda_out
    );

localparam IDLE = 0;
localparam START = 1;
localparam TR_ADDR = 2;
localparam TR_RW = 3;
localparam WSAK = 4;
localparam TR_SUB = 5;
localparam WSAK2 = 6;
localparam TR_DATA = 7;
localparam WSAK3 = 8;
localparam STOP = 9;
    
(* mark_debug = "true" *) reg [7:0] state = IDLE;
reg [6:0] saved_addr = 0;//7'b1101000;
reg [7:0] saved_sub = 0;//8'h20;
reg [7:0] saved_data = 0;//8'h0F;

(* mark_debug = "true" *) reg [7:0] count = 0;
(* mark_debug = "true" *) reg i2c_scl_enable = 0;
(* mark_debug = "true" *) wire dbg_scl = (i2c_scl_enable == 1'b0) ? 1'b1 : ~clk;
(* mark_debug = "true" *) wire dbg_sda = sda_tr_reg ? i2c_sda_reg : 1'b1;
assign i2c_scl = dbg_scl ? 1'bZ : 0;
assign ready = (reset == 0) && (state == IDLE);

(* mark_debug = "true" *) reg i2c_sda_reg = 1;
(* mark_debug = "true" *) reg sda_tr_reg = 1;
assign i2c_sda = dbg_sda ? 1'bZ : 0;
(* mark_debug = "true" *) reg valid = 0;

always @(negedge clk)
begin
    if (reset) begin
        i2c_scl_enable <= 0;
    end
    else begin
        if ((state == IDLE) || (state == START) || (state == STOP)) begin
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
        sda_tr_reg <= 1;
        state <= IDLE;
        count <= 0;
        saved_addr <= 0;
        saved_sub <= 0;
        saved_data <= 0;
        valid <= 0;
    end
    else begin
        case (state)

            IDLE : begin
                i2c_sda_reg <= 1;
                sda_tr_reg <= 1;
                state <= start ? START : IDLE; //start ? TODO: DEBUG!!!
                saved_addr <= start ? addr : saved_addr;
                saved_sub <= start ? sub : saved_sub;
                saved_data <= start ? data : saved_data;
            end
            
            START : begin
                i2c_sda_reg <= 0;
                sda_tr_reg <= 1;
                state <= TR_ADDR;
                count <= 7'd6;
            end
            
            TR_ADDR : begin
                i2c_sda_reg <= saved_addr [count];
                sda_tr_reg <= 1;
                if (count == 0) 
                    state <= TR_RW;
                else
                    count <= count - 1;
            end
            
            TR_RW : begin
                i2c_sda_reg <= 0; //TODO: Should be 1;
                sda_tr_reg <= 1;
                state <= WSAK;
            end
            
            WSAK : begin
                state <= TR_SUB;
                sda_tr_reg <= 0;
                valid <= ~i2c_sda;
                count <= 7'd7;
            end
            
            TR_SUB : begin
                valid <= 0;
                i2c_sda_reg <= saved_sub [count];
                sda_tr_reg <= 1;
                if (count == 0) 
                    state <= WSAK2;
                else
                    count <= count - 1;
            end
            
            WSAK2 : begin
                state <= TR_DATA;
                sda_tr_reg <= 0;
                valid <= ~i2c_sda;
                count <= 7'd7;
            end
            
            TR_DATA : begin
                valid <= 0;
                i2c_sda_reg <= saved_data [count];
                sda_tr_reg <= 1;
                if (count == 0) 
                    state <= WSAK3;
                else
                    count <= count - 1;
            end

            WSAK3 : begin
                state <= STOP;
                valid <= ~i2c_sda;
                sda_tr_reg <= 0;
            end
            
            STOP : begin
                i2c_sda_reg <= 1;
                sda_tr_reg <= 1;
                state <= STOP;//STOP;//TODO: DEBUG!!!
            end
            
            default : state <= IDLE;
        endcase
    end
end
endmodule
