`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2016 16:25:28
// Design Name: 
// Module Name: SPI_MASTER
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


module SPI_MASTER#    
    (
    parameter integer m = 15 // Data packet size
    )
    (
    input clk, 
    output reg EN_TX=0,
    input ce, 
    output wire LOAD,
    input st, 
    output wire SCLK,
    input MISO, 
    output wire MOSI,
    input [m-1:0] TX_MD,
    output reg [m-1:0] RX_SD=0,
    input LEFT,
    output wire CEfront,
    input R,
    output wire CEspad
    );
    reg [m-1:0] MQ=0 ; //������� ������ �������� ������ MASTER-�
    reg [m-1:0] MRX=0 ; //������� ������ ������� ������ MASTER-�

    reg [3:0] cb_bit=0; //������� ���
    assign MOSI = LEFT? MQ[m-1] : MQ[0] ; // �������� ������ MASTER-�
    assign LOAD = !EN_TX ; // �������� ��������/������
    
    assign SCLK = EN_TX & ce;
    
    always @(negedge ce) begin
        MQ <= st? TX_MD : LEFT ? MQ<<1 : MQ>>1;
        EN_TX <= (cb_bit == (m-1))? 0 : st? 4'd1 : EN_TX;
        cb_bit <= st? 0 : cb_bit + 4'd1 ;
    end
    
    always @(posedge ce) begin
        MRX <= EN_TX ? MRX<<1 | MISO : 0;
    end
    
    always @(posedge LOAD) begin
        RX_SD <= MRX;
    end
    
endmodule