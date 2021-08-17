`ifndef __IIS_SV__
`define __IIS_SV__

`include "../common.sv"
`include "../chapter4/counter.sv"
`include "../chapter4/edge2en.sv"

`default_nettype none
`timescale 1ns/10ps

module TestIis;
    import SimSrcGen::*;
    logic clk;
    initial GenClk(clk, 10ns, 40.69ns);    // 24.576M
    // ==== transmitter side ====
    logic sck, ws, sd, sck_fall, f_sync, txdata_rd;
    // sck 3.072M, ws 48k
    IisClkGen #(64, 8) iisClk(clk, sck, ws, sck_fall, f_sync);
    logic signed [31:0] txdata[2];
    IisTransmitter iisTrans(clk, sck_fall, f_sync, txdata, txdata_rd, sd);
    // ==== receiver side ====
    logic signed [31:0] rxdata[2];
    logic rxdata_valid;
    IisReceiver iisRecv(clk, sck, ws, sd, rxdata, rxdata_valid);
    // ==== transmitter side data ====
    always_ff@(posedge clk) begin
        if(txdata_rd) txdata = '{$random(), $random()};
    end
endmodule

module IisClkGen #(
    parameter SCK_TO_WS = 64,
    parameter MCK_TO_SCK = 8
)(
    input wire mck,
    output logic sck,
    output logic ws,
    output logic sck_fall,
    output logic frame_sync
);
    localparam SCKW = $clog2(MCK_TO_SCK);
    localparam WSW = $clog2(SCK_TO_WS);
    logic [SCKW - 1 : 0] cnt_sck;
    logic cnt_sck_co;
    logic [WSW - 1 : 0] cnt_ws;
    always_ff@(posedge mck) sck <= cnt_sck >= SCKW'(MCK_TO_SCK / 2);
    always_ff@(posedge mck) ws <= cnt_ws >= WSW'(SCK_TO_WS / 2);
    always_ff@(posedge mck) sck_fall <= cnt_sck_co;
    Counter #(MCK_TO_SCK) cntSck(
        mck, 1'b0, 1'b1, cnt_sck, cnt_sck_co);
    Counter #(SCK_TO_WS) cntWs(
        mck, 1'b0, cnt_sck_co, cnt_ws, );
    assign frame_sync = (cnt_ws == 0) && cnt_sck_co;
endmodule

module IisTransmitter (
    input wire mck,
    input wire sck_fall,
    input wire frame_sync,
    input wire signed [31:0] data[2], //data[0]: left; data[1]: right
    output logic data_rd,
    output logic iis_sd
);
    assign data_rd = frame_sync;
    logic data_rd_dly;
    logic [63:0] shift_reg;
    always_ff@(posedge mck) data_rd_dly <= data_rd;
    always_ff@(posedge mck) begin
        if(data_rd_dly) shift_reg <= {data[0], data[1]};
        else if(sck_fall) shift_reg <= {shift_reg[62:0], 1'b0};
    end
    assign iis_sd = shift_reg[63];
endmodule

module IisReceiver (
    input wire mck, iis_sck, iis_ws, iis_sd,
    output logic signed [31:0] data[2],
    output logic data_valid    
);
    logic sck_rising, sck_reg, ws_falling, sd_reg;
    Rising2En #(2) sckRising(mck, iis_sck, sck_rising, sck_reg);
    Falling2En #(2) wsFalling(mck, iis_ws, ws_falling, );
    Rising2En #(2) sdSync(mck, iis_sd, , sd_reg);
    logic [7:0] bit_cnt;
    Counter #(256) bitCnt(mck, ws_falling, sck_rising, bit_cnt, );
    logic frame_end;
    always_ff@(posedge mck) frame_end <= (bit_cnt == 8'd0) && sck_rising;
    always_ff@(posedge mck) data_valid <= frame_end;
    logic [63:0] shift_reg;
    always_ff@(posedge mck) begin
        if(frame_end) {data[0], data[1]} <= shift_reg;
        else if(sck_rising) shift_reg <= {shift_reg[62:0], sd_reg};
    end
endmodule

`endif
