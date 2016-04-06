`timescale 1ns / 1ps

module CLK_DIV
    (
    input wire GCLK,
    output reg out = 1'b0,
    input wire [63:0] T
    );
    
    reg [63:0] cnt = 64'd0;
    always @(posedge GCLK) begin
        if (cnt == 64'd0) begin
            cnt <= T;
            out <= ~out;
        end
        else begin
            cnt <= cnt - 64'd1;
        end
    
    end
endmodule
