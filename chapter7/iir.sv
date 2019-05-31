`ifndef __IIR_SV__
`define __IIR_SV__

`include "../common.sv"
`include "../chapter4/counter.sv"
`include "./dds.sv"

`timescale 1ns/100ps
`default_nettype none

module TestIir;
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
        freq <= 2.0**32 * freqr / 100e6; // freq control word
    end
    logic signed [31:0] phase = '0;
    logic signed [9:0] swave;
    DDS #(32, 10, 13) theDDS(clk, rst, 1'b1, freq, phase, swave);
    logic signed [9:0] filtered, harm3;
    logic square = '0, en15;
    Counter #(15) cnt15(clk, rst, 1'b1, , en15);
    always_ff@(posedge clk) if(en15) square <= ~square; 
    IIR #(10, 5, 3, '{ 0.262748, 0.262748, 0.060908 }, // GAIN
        '{  '{ 1, -1.368053,  1       },               // s0:NUM
            '{ 1, -1.779618,  1       },               // s1:NUM
            '{ 1,  0       , -1       } },             // s2:NUM
        '{  '{    -1.519556,  0.969571},               // s0:DEN
            '{    -1.665517,  0.974258},               // s1:DEN
            '{    -1.569518,  0.936203} }              // s2:DEN
    )  theIir1(clk, rst, 1'b1, 10'(integer'(swave * 0.9)), filtered),
        theIir2(clk, rst, 1'b1, square?10'sd500:-10'sd500, harm3);
endmodule

module IIR #(
    parameter DW = 10, EW = 4, STG = 2,
    parameter real GAIN[STG], real NUM[STG][3], real DEN[STG][2]
)(
    input wire clk, rst, en,
    input wire signed [DW-1 : 0] in,
    output logic signed [DW-1 : 0] out
);
    localparam W = EW + DW;
    logic signed [W-1 : 0] sio[STG+1];
    assign sio[0] = in, out = sio[STG];
    generate
        for(genvar s = 0; s < STG; s++) begin
            IIR2nd #(W, DW-1, GAIN[s], NUM[s], DEN[s]) theIir(clk, rst, en, sio[s], sio[s+1]);
        end
    endgenerate
endmodule

module IIR2nd #(
    parameter DW = 14, FW = 9,
    parameter real GAIN, real NUM[3], real DEN[2]
)(
    input wire clk, rst, en,
    input wire signed [DW-1 : 0] in,    // Q(DW-FW).FW
    output logic signed [DW-1 : 0] out  // Q(DW-FW).FW
);
    import Fixedpoint::*;
    wire signed [DW-1:0] n0 = (NUM[0] * 2.0**FW);
    wire signed [DW-1:0] n1 = (NUM[1] * 2.0**FW);
    wire signed [DW-1:0] n2 = (NUM[2] * 2.0**FW);
    wire signed [DW-1:0] d1 = (DEN[0] * 2.0**FW);
    wire signed [DW-1:0] d2 = (DEN[1] * 2.0**FW);
    wire signed [DW-1:0] g  = (GAIN   * 2.0**FW);
    `DEF_FP_MUL(mul, DW-FW, FW, DW-FW, FW, FW);
    logic signed [DW-1:0] z1, z0;
    wire signed [DW-1:0] pn0 = mul(in, n0);
    wire signed [DW-1:0] pn1 = mul(in, n1);
    wire signed [DW-1:0] pn2 = mul(in, n2);
    wire signed [DW-1:0] pd1 = mul(o, d1);
    wire signed [DW-1:0] pd2 = mul(o, d2);
    wire signed [DW-1:0] o = pn0 + z0;
    always_ff@(posedge clk) begin
        if(rst) begin z0 <= '0; z1 <= '0; out <= '0; end
        else if(en) begin
            z1 <= pn2 - pd2;
            z0 <= pn1 - pd1 + z1;
            out <= mul(o, g);
        end
    end
endmodule

`endif
