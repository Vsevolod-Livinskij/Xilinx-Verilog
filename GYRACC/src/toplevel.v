`timescale 1ns / 1ps

module toplevel
    (
    GCLK,
    DC,
    RES,
    SCLK,
    SDIN,
    VBAT,
    VDD,
    JA1,
    JA2,
    JA3,
    JA4,
    JA7,
    JA8,
    JA9,
    JA10,
    JB1,
    JB2,
    JB3,
    JB4,
    JB7,
    JB8,
    JB9,
    JB10,
    SW0,
    SW1,
    SW2,
    SW3,
    SW4,
    SW5,
    SW6,
    SW7,
    BTNC,
    BTND,
    BTNL,
    BTNR,
    BTNU,
    LD0,
    LD1,
    LD2,
    LD3,
    LD4,
    LD5,
    LD6,
    LD7
    );

    input wire GCLK;

    inout wire JA1;
    inout wire JA2;
    inout wire JA3;
    inout wire JA4;
    inout wire JA7;
    inout wire JA8;
    inout wire JA9;
    inout wire JA10;    
    
    output wire JB1;
    output wire JB2;
    output wire JB3;
    output wire JB4;
    output wire JB7;
    output wire JB8;
    output wire JB9;
    output wire JB10;

    input wire BTNC;
    input wire BTND;
    input wire BTNL;
    input wire BTNR;
    input wire BTNU;

    output wire DC;
    output wire RES;
    output wire SCLK;
    output wire SDIN;
    output wire VBAT;
    output wire VDD;

    input wire SW0;
    input wire SW1;
    input wire SW2;
    input wire SW3;
    input wire SW4;
    input wire SW5;
    input wire SW6;
    input wire SW7;
    
    output wire LD0;
    output wire LD1;
    output wire LD2;
    output wire LD3;
    output wire LD4;
    output wire LD5;
    output wire LD6;
    output wire LD7;

    reg [127:0] str0 = "----------------";
    reg [127:0] str1 = "----------------";
    reg [127:0] str2 = "----------------";
    reg [127:0] str3 = "----------------";

    reg oled_ready = 1'b0;
    assign LD7 = oled_ready;
    ZedboardOLED OLED
        (
        .clear(BTND),
        .refresh(oled_ready),
        .s1(str0),
        .s2(str1),
        .s3(str2),
        .s4(str3),
        .DC(DC),
        .RES(RES),
        .SCLK(SCLK),
        .SDIN(SDIN),
        .VBAT(VBAT),
        .VDD(VDD),
        .CLK(GCLK)
        );
  
    wire [15:0]  temp_data;
    wire [15:0]  x_axis_data;
    wire [15:0]  y_axis_data;
    wire [15:0]  z_axis_data;
    wire [15:0]  ang_x;

    PmodGYRO GYRO_0
        (
        .clk(GCLK),
        .RST(BTND),
        .JA({JA4, JA3, JA2, JA1}),      
        .temp_data_out(temp_data),
        .x_axis_out(x_axis_data),
        .y_axis_out(y_axis_data),
        .z_axis_out(z_axis_data),
        .ang_x(ang_x)
        );
  
    (* mark_debug = "true" *) wire txIdleOUT;
    (* mark_debug = "true" *) wire txReadyOUT;
    (* mark_debug = "true" *) wire txOUT;
  
    (* mark_debug = "true" *) reg [3:0] tr_count = 0;
    (* mark_debug = "true" *) reg [7:0] tr_data = 0;
    (* mark_debug = "true" *) reg prev_ready = 0;
    
    UART_TX uart_tx 
        (
        .clockIN(GCLK),
        .txDataIN(tr_data),
        .txOUT(JB1),
        .txLoadIN(1'b1),
        .nTxResetIN(~BTNU),
        .txIdleOUT(txIdleOUT),
        .txReadyOUT(txReadyOUT)
        );
  
    always @(posedge GCLK) begin
        tr_count <= txReadyOUT && ~prev_ready ? tr_count + 8'd1 : tr_count;
        prev_ready <= txReadyOUT;
        case (tr_count)
            8'd0: begin
                tr_data <= x_axis_data [7:0];
            end
            8'd1: begin
                tr_data <= x_axis_data [15:8];
            end
            8'd2: begin
                tr_data <= y_axis_data [7:0];
            end
            8'd3: begin
                tr_data <= y_axis_data [15:8];
            end
            8'd4: begin
                tr_data <= z_axis_data [7:0];
            end
            8'd5: begin
                tr_data <= z_axis_data [15:8];
            end
            8'd6: begin
                tr_data <= 8'b01010101;
            end
            8'd7: begin
                tr_data <= 8'b01010101;
            end
        endcase
    end
  
    wire [127:0] w_str_x;
    wire [127:0] w_str_y;
    wire [127:0] w_str_z;
    wire [127:0] w_str_t;
    wire [127:0] w_str_ax;


    D2STR_D#(.len(4)) d2str_gyro_x
        (
            .GCLK(GCLK),
            .str(w_str_x),
            .d(x_axis_data)
        );
    D2STR_D#(.len(4)) d2str_gyro_y
        (
            .GCLK(GCLK),
            .str(w_str_y),
            .d(y_axis_data)
        );  
    D2STR_D#(.len(4)) d2str_gyro_z
        (
            .GCLK(GCLK),
            .str(w_str_z),
            .d(z_axis_data)
        );  
    D2STR_D#(.len(4)) d2str_gyro_t
        (
            .GCLK(GCLK),
            .str(w_str_t),
            .d(temp_data)
        );

    D2STR_D#(.len(4)) d2str_gyro_ax
        (
            .GCLK(GCLK),
            .str(w_str_ax),
            .d(ang_x)
        );

    // =============================================
    // OLED infrastructure
    // =============================================    
    wire oled_refresh_clk;
    CLK_DIV oled_refresh_clk 
        (
        .GCLK(GCLK),
        .out(oled_refresh_clk),
        .T(64'd3333333)
        );
        
    always @(posedge GCLK) begin
        if (BTNC) begin
            oled_ready <= 1'b1;
        end
    end
    
    always @(posedge oled_refresh_clk) begin
        str0 <= w_str_x;
        str1 <= w_str_y;
        str2 <= w_str_z;
        str3 <= w_str_t;
    end
endmodule