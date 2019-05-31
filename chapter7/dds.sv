`ifndef __DDS_SV__
`define __DDS_SV__

`include "../common.sv"

`timescale 1ns/100ps
`default_nettype none

module TestDDS;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 80, 100);
    initial GenRst(clk, rst, 2, 2);
    real freqr = 1e6, fstepr = 49e6/(1e-3*100e6); // from 1MHz to 50MHz in 1ms
    always@(posedge clk) begin
        if(rst) freqr = 1e6;
        else freqr += fstepr;
    end
    logic signed [31:0] freq;
    always@(posedge clk) begin
        freq <= 2.0**32 * freqr / 100e6; // frequency to freq control word
    end
    logic signed [31:0] phase = '0;
    logic signed [9:0] swave;
    DDS #(32, 10, 13) theDDS(clk, rst, 1'b1, freq, phase, swave);
endmodule

module DDS #(
    parameter PW = 32, DW = 10, AW = 13
)(
    input wire clk, rst, en,
    input wire signed [PW - 1 : 0] freq, phase,
    output logic signed [DW - 1 : 0] out
);
    localparam LEN = 2**AW;
    localparam real PI = 3.1415926535897932;
    logic signed [DW-1 : 0] sine[LEN];
    initial begin
        for(int i = 0; i < LEN; i++) begin
            sine[i] = $sin(2.0 * PI * i / LEN) * (2.0**(DW-1) - 1.0);
        end
    end
    logic [PW-1 : 0] phaseAcc;
    always_ff@(posedge clk) begin
        if(rst) phaseAcc <= '0;
        else if(en) phaseAcc <= phaseAcc + freq;
    end
    wire [PW-1 : 0] phaseSum = phaseAcc + phase;
    always_ff@(posedge clk) begin
        if(rst) out <= '0;
        else if(en) out <= sine[phaseSum[PW-1 -: AW]];
    end
endmodule

module OrthDDS #(
    parameter PW = 32, DW = 10, AW = 13
)(
    input wire clk, rst, en,
    input wire signed [PW - 1 : 0] freq, phase,
    output logic signed [DW - 1 : 0] sin, cos
);
    localparam LEN = 2**AW;
    localparam real PI = 3.1415926535897932;
    logic signed [DW-1 : 0] sine[LEN];
    initial begin
        for(int i = 0; i < LEN; i++) begin
            sine[i] = $sin(2.0 * PI * i / LEN) * (2.0**(DW-1) - 1.0);
        end
    end
    logic [PW-1 : 0] phaseAcc, phSum0, phSum1;
    always_ff@(posedge clk) begin
        if(rst) phaseAcc <= '0;
        else if(en) phaseAcc <= phaseAcc + freq;
    end
    always_ff@(posedge clk) begin
        if(rst) begin
            phSum0 <= '0;
            phSum1 <= PW'(1) <<< (PW-2); // 90deg
        end
        else if(en) begin
            phSum0 <= phaseAcc + phase;
            phSum1 <= phaseAcc + phase + (PW'(1) <<< (PW-2));
        end
    end
    always_ff@(posedge clk) begin
        if(rst) sin <= '0;
        else if(en) sin <= sine[phSum0[PW-1 -: AW]];
    end
    always_ff@(posedge clk) begin
        if(rst) cos <= '0;
        else if(en) cos <= sine[phSum1[PW-1 -: AW]];
    end
endmodule

`endif
