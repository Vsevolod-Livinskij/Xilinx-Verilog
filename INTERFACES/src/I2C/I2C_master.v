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
    (* mark_debug = "true" *) input wire i2c_sda_in,
    (* mark_debug = "true" *) output wire i2c_sda_out,
    (* mark_debug = "true" *) output wire i2c_sda_out_mode,
    (* mark_debug = "true" *) output wire i2c_scl,
    (* mark_debug = "true" *) output wire done
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
(* mark_debug = "true" *) reg [1:0] st_count_enable = 0;
(* mark_debug = "true" *) reg [1:0] st_count = 0;
(* mark_debug = "true" *) reg done_reg = 0;
assign done = done_reg;

reg [6:0] saved_addr = 0;//7'b1101000;
reg [7:0] saved_sub = 0;//8'h20;
reg [7:0] saved_data = 0;//8'h0F;

(* mark_debug = "true" *) reg [7:0] tr_count = 0;
(* mark_debug = "true" *) reg i2c_scl_enable = 0;
(* mark_debug = "true" *) reg i2c_scl_reg = 1;
assign i2c_scl = (i2c_scl_enable == 1'b0) ? 1'b1 : (((st_count == 2) || (st_count == 3)) ? 1 : 0);

assign ready = (reset == 0) && (state == IDLE);

(* mark_debug = "true" *) reg i2c_sda_reg = 1;
(* mark_debug = "true" *) reg valid = 0;
(* mark_debug = "true" *) reg i2c_sda_out_mode_reg = 1;
assign i2c_sda_out_mode = i2c_sda_out_mode_reg;
assign i2c_sda_out = i2c_sda_out_mode_reg ? i2c_sda_reg : 1'b1;

always @(posedge clk)
begin
    if (reset) begin
        i2c_scl_enable <= 0;
        i2c_scl_reg <= 1;
    end
    else begin
        if ((state == IDLE) || ((state == START) && (st_count != 2) && (st_count != 3)) || (state == STOP)) begin
            i2c_scl_enable <= 0;
            i2c_scl_reg <= 1;
        end
        else begin
            i2c_scl_enable <= 1;
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin
        st_count_enable <= 0;
        st_count <= 0;
        done_reg <= 0;
    end
    else begin
        if ((state == IDLE) || ((state == STOP) && (done_reg != 0))) begin
            st_count_enable <= 0;
            st_count <= 0;
        end
        else begin
            st_count_enable <= 1;
            st_count <= st_count + 1;
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin
        i2c_sda_reg <= 1;
        i2c_sda_out_mode_reg <= 1;
        state <= IDLE;
        tr_count <= 0;
        saved_addr <= 0;
        saved_sub <= 0;
        saved_data <= 0;
        valid <= 0;
    end
    else begin
        case (state)

            IDLE : begin
                i2c_sda_reg <= 1;
                i2c_sda_out_mode_reg <= 1;
                state <= start ? START : IDLE; //start ? TODO: DEBUG!!!
                saved_addr <= start ? addr : saved_addr;
                saved_sub <= start ? sub : saved_sub;
                saved_data <= start ? data : saved_data;
            end
            
            START : begin
                i2c_sda_reg <= 0;
                i2c_sda_out_mode_reg <= 1;
                state <= (st_count == 3) ? TR_ADDR : START;
                tr_count <= 7'd7;
            end
            
            TR_ADDR : begin
                i2c_sda_out_mode_reg <= 1;
                state <= ((tr_count == 0) && (st_count == 3)) ? TR_RW : TR_ADDR;
                i2c_sda_reg <= (st_count == 0) ? saved_addr [tr_count  - 1] : i2c_sda_reg;
                tr_count <= (st_count == 0) ? (tr_count - 1) : tr_count;
            end
            
            TR_RW : begin
                i2c_sda_out_mode_reg <= 1'b1;
                state <= (st_count == 3) ? WSAK : TR_RW;
                i2c_sda_reg <= (st_count == 0) ? 1 : i2c_sda_reg;
            end
            
            WSAK : begin
                state <= (st_count == 3) ? TR_SUB : WSAK;
                i2c_sda_out_mode_reg <= 0;
                i2c_sda_reg <= 0;
                tr_count <= (st_count == 3) ? 7'd8 : tr_count;
                valid <= (st_count == 2) ? ~i2c_sda_in : valid;
            end
            
            TR_SUB : begin
                i2c_sda_out_mode_reg <= 1;
                valid <= 0;
                state <= ((tr_count == 0) && (st_count == 3)) ? WSAK2 : TR_SUB;
                i2c_sda_reg <= (st_count == 0) ? saved_sub [tr_count - 1] : i2c_sda_reg;
                tr_count <= (st_count == 0) ? (tr_count - 1) : tr_count;
            end
            
            WSAK2 : begin
                state <= (st_count == 3) ? TR_DATA : WSAK2;
                i2c_sda_out_mode_reg <= 0;
                i2c_sda_reg <= 0;
                tr_count <= (st_count == 3) ? 7'd8 : tr_count;
                valid <= (st_count == 2) ? ~i2c_sda_in : valid;
            end
            
            TR_DATA : begin
                i2c_sda_out_mode_reg <= 1;
                valid <= 0;
                state <= ((tr_count == 0) && (st_count == 3)) ? WSAK3 : TR_DATA;
                i2c_sda_reg <= (st_count == 0) ? saved_data [tr_count - 1] : i2c_sda_reg;
                tr_count <= (st_count == 0) ? (tr_count - 1) : tr_count;
            end

            WSAK3 : begin
                state <= (st_count == 3) ? STOP : WSAK3;
                i2c_sda_out_mode_reg <= 0;
                i2c_sda_reg <= 0;
                valid <= (st_count == 2) ? ~i2c_sda_in : valid;
            end
            
            STOP : begin
                i2c_sda_out_mode_reg <= 1;
                state <= STOP;//STOP;//TODO: DEBUG!!!
                valid <= 0;
                i2c_sda_reg <= (st_count == 1) ? 1 : i2c_sda_reg;
                done_reg <= (st_count == 1) ? 1 : done_reg;
            end
            
            default : state <= IDLE;
        endcase
    end
end
endmodule
