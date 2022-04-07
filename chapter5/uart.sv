`include "../chapter4/counter.sv"
`include "../chapter4/edge2en.sv"
`include "../chapter4/scfifo.sv"
`include "../common.sv"
`default_nettype none
`timescale 1ns/100ps
module TestUart; 
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 1, 1);
    logic [7:0] tx_fifo_din, tx_fifo_dout;
    logic [8:0] rx_fifo_din, rx_fifo_dout;
    logic tx_fifo_write = '0, tx_fifo_read, tx_fifo_empty;
    logic rx_fifo_write, rx_fifo_read = '0;
    logic [3:0] rx_fifo_dc;
    ScFifo2 #(8, 4) theTxFifo(
        clk, rst, tx_fifo_din, tx_fifo_write, tx_fifo_dout, tx_fifo_read,
         , , , , tx_fifo_empty);
    ScFifo2 #(9, 4) theRxFifo(
        clk, rst, rx_fifo_din, rx_fifo_write, rx_fifo_dout, rx_fifo_read,
         , , rx_fifo_dc, , );
    logic start, uart, tx_busy, rx_busy, par_err;
    assign tx_fifo_read = ~tx_fifo_empty & ~tx_busy & ~start;
    always_ff@(posedge clk) start <= tx_fifo_read;
    UartTx #(108, 1) theUartTx(clk, rst,
        tx_fifo_dout, start, tx_busy, uart);
    UartRx #(109, 1) theUartRx(clk, rst,
        uart, rx_fifo_din[7:0], rx_fifo_write, rx_fifo_din[8], rx_busy);
    initial begin
        repeat(100) @(posedge clk);
        @(posedge clk) {tx_fifo_write, tx_fifo_din} = {1'b1, 8'ha5};
        @(posedge clk) {tx_fifo_write, tx_fifo_din} = {1'b1, 8'hc3};
        @(posedge clk) tx_fifo_write = 1'b0;
        repeat(2500) @(posedge clk);
        @(posedge clk) {tx_fifo_write, tx_fifo_din} = {1'b1, 8'h37};
        @(posedge clk) tx_fifo_write = 1'b0;
    end
    initial begin
        wait(rx_fifo_dc >= 4'd3);
        repeat(3) begin
            @(posedge clk) rx_fifo_read = 1'b1;
        end
        @(posedge clk) rx_fifo_read = 1'b0;
        repeat(100) @(posedge clk);
        $stop();
    end
endmodule

module UartTx #(
    parameter BR_DIV = 868, // 115200 @100MHz 
    // parity: 0 - none, 1 - odd, 2 - even
    parameter PARITY = 0
)(
    input wire clk, rst,
    input wire [7:0] din,
    input wire start,
    output logic busy,
    output logic txd
);
    localparam [3:0] BC_MAX = PARITY ? 4'd10: 4'd9;
    logic br_en, bit_co;
//    logic [3:0] bit_cnt;
    Counter #(BR_DIV) theBrCnt(
        clk, rst, start | busy, , br_en);
    Counter #(BC_MAX + 1) theBitCnt(
        clk, rst, br_en, /*bit_cnt*/, bit_co);
    // busy driven
    always_ff@(posedge clk) begin
        if(rst) busy <= 1'b0;
        else if(bit_co) busy <= 1'b0;
        else if(start) busy <= 1'b1;
    end
    // shift_reg & parity
    logic [10:0] shift_reg; // {stop, par?, din[7:0], start}
    always_ff@(posedge clk) begin
        if(rst) shift_reg <= '1;
        else if(start & ~busy) begin
            case(PARITY)
            1: shift_reg <= {1'b1, ^din, din, 1'b0};
            2: shift_reg <= {1'b1, ~^din, din, 1'b0};
            default: shift_reg <= {2'b11, din, 1'b0};
            endcase
        end
        else if(br_en) shift_reg <= shift_reg >> 1;
    end
    // txd output
    always_ff@(posedge clk) begin
        if(~busy) txd <= 1'b1; // idle
        else txd <= shift_reg[0]; // data & parity
    end
endmodule

module UartRx #(
    parameter BR_DIV = 868, // 115200 @100MHz 
    // parity: 0 - none, 1 - even, 2 - odd
    parameter PARITY = 0
)(
    input wire clk, rst,
    input wire rxd,
    output logic [7:0] dout,
    output logic dout_valid, par_err, busy
);
    // input sync & falling edge detect.
    logic rxd_falling, rxd_reg;
    Falling2En #(2) theFallingDet(clk, rxd, rxd_falling, rxd_reg);
    // bitrate counter & bit counter
    localparam [3:0] BC_MAX = PARITY ? 4'd9: 4'd8;
    logic br_en, bit_co;
    logic [$clog2(BR_DIV) - 1 : 0] br_cnt;
    //logic [3:0] bit_cnt;
    Counter #(BR_DIV) theBrCnt(
        clk, rst | (rxd_falling & ~busy), busy, br_cnt, br_en);
    Counter #(BC_MAX + 1) theBitCnt(
        clk, rst, br_en, /*bit_cnt*/, bit_co);
    // busy driven
    always_ff@(posedge clk) begin
        if(rst) busy <= 1'b0;
        else if(bit_co) busy <= 1'b0;
        else if(rxd_falling) busy <= 1'b1;
    end
    // data sampling
    logic [8:0] shift_reg;
    always_ff@(posedge clk) begin
        if(rst) shift_reg <= '0;
        // sampling at middle of data bit
        else if(br_cnt == BR_DIV / 2)
            shift_reg <= {rxd_reg, shift_reg[8:1]};
    end
    // output
    always_ff@(posedge clk) begin
        if(rst) begin
            dout <= 8'd0;
            dout_valid <= 1'b0;
            par_err <= 1'b0;
        end
        else if(bit_co) begin
            dout_valid <= 1'b1;
            case(PARITY)
            1: {par_err, dout} <= {^shift_reg, shift_reg[7:0]};
            2: {par_err, dout} <= {~^shift_reg, shift_reg[7:0]};
            default: {par_err, dout} <= {1'b0, shift_reg[8:1]};
            endcase
        end
        else dout_valid <= 1'b0;
    end
endmodule
