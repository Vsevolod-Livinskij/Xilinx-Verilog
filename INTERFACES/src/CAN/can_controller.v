`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2016 17:26:53
// Design Name: 
// Module Name: can_controller
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


module can_controller
    (
    input wire GCLK,
    input wire RES,
    inout wire CAN,
    (* mark_debug = "true" *) input wire [107:0] DIN,
    (* mark_debug = "true" *) output reg [107:0] DOUT,
    (* mark_debug = "true" *) input wire tx_start,
    (* mark_debug = "true" *) output reg tx_ready = 1'b0,
    (* mark_debug = "true" *) output reg rx_ready = 1'b0
    );
    
    (* mark_debug = "true" *) wire tx;
    (* mark_debug = "true" *) wire rx;
    (* mark_debug = "true" *) wire cntmn;
    (* mark_debug = "true" *) wire cntmn_ready;
    (* mark_debug = "true" *) wire tsync;
    
    (* mark_debug = "true" *) reg [107:0] DIN_BUF = 108'd0;
    
    (* mark_debug = "true" *) reg timeslot_start  = 1'b0;         // 1 at the start of every frame
    (* mark_debug = "true" *) reg timeslot_finish = 1'b0;         // 1 at the end of every frame
    (* mark_debug = "true" *) reg have_arb = 1'b1;                // 1 if we have the arbitration
    (* mark_debug = "true" *) reg tx_requested = 1'b0;            // 1 if DIN_BUF contains untransmitted data
    reg [127:0] can_state = "RECEIVING";  // RECEIVING/TRANSMITTING
    
    
    // Capture input data
    (* mark_debug = "true" *) reg timeslot_start_block = 1'b0;
    always @(posedge GCLK) begin
        if (RES) begin
            DIN_BUF <= 108'd0;
            tx_ready <= 1'b0;
            tx_requested <= 1'b0;
        end 
        else if (timeslot_finish) begin
            timeslot_start_block <= 1'b0; // Release block
            DIN_BUF <= DIN_BUF;
            if(have_arb & cntmn_ready & !cntmn) begin
                tx_ready <= 1'b1;
                tx_requested <= 1'b0;
            end
        end
        else if (timeslot_start & !timeslot_start_block) begin
        // Do this code exactly once upon timeslot start
            timeslot_start_block <= 1'b1;
            if (tx_start) begin
                DIN_BUF <= DIN;
                tx_ready <= 1'b0;
                tx_requested <= 1'b1;
            end
            else begin
                DIN_BUF <= DIN_BUF;
                tx_ready <= tx_ready;
                tx_requested <= tx_requested;
            end
        end
        else begin
            DIN_BUF <= DIN_BUF;
            tx_ready <= tx_ready;
            tx_requested <= tx_requested;
        end
    end
    
    
    // Arbitration circuit
    always @(posedge GCLK) begin
        if (RES) begin
            have_arb <= 1'b0; // Do not mess up the bus
            can_state <= "RECEIVING"; // Passively listen during the first timeslot
        end
        else if (cntmn_ready & cntmn) begin
            have_arb <= 1'b0;
            can_state <= "RECEIVING";
        end 
        else if (timeslot_start) begin         
            have_arb <= 1'b1; // Assume bus arbitration
            can_state <= "TRANSMITTING";
        end
        else begin
            have_arb <= have_arb;
            can_state <= can_state;
        end 
    end
    
    // Frame timing circuit
    (* mark_debug = "true" *) reg [63:0] bit_cnt = 64'd0;
    (* mark_debug = "true" *) reg [107:0] rx_buf = 108'd0;
    always @(posedge tsync) begin
        // Mark timeslot start and timeslot finish
        // (Currently, based on current frame bit number)
        if (bit_cnt == 64'd106) begin
            timeslot_finish <= 1'b1;
            timeslot_start <= 1'b0;
        end 
        else if (bit_cnt == 64'd107) begin
            timeslot_finish <= 1'b0;
            timeslot_start <= 1'b1;
        end
        else begin
            timeslot_start <= 1'b0;
            timeslot_finish <= 1'b0;
        end

        // Count current bit in frame
        if (RES) begin
            bit_cnt <= 64'b0;
        end
        else if (timeslot_finish) begin
            bit_cnt <= 64'd0;
        end 
        else begin
            bit_cnt <= bit_cnt + 64'd1;
        end
        
        // Receive data
        if (RES) begin
            rx_buf <= 0;
        end
        else begin
            rx_buf <= {rx, rx_buf[107:1]}; // Receive data
        end
    end
    
    assign tx = (have_arb & tx_requested) ? DIN_BUF[bit_cnt] : 1'b1;

    // Data receive circuit
    always @(posedge GCLK) begin
        if (RES) begin
            rx_ready <= 1'b0;
            DOUT <= 0;
        end 
        else if (timeslot_finish & cntmn_ready & cntmn) begin
            rx_ready <= 1'b1;
            DOUT <= rx_buf;
        end
        else begin
            rx_ready <= rx_ready;
            DOUT <= DOUT;
        end
    end
 
    can_qsampler CQS
    (
        .GCLK(GCLK),
        .RES(RES),  
        .CAN(CAN),  
        .din(tx),  
        .dout(rx),   
        .cntmn(cntmn),
        .cntmn_ready(cntmn_ready),
        .sync(tsync) 
    );
        
    
endmodule
