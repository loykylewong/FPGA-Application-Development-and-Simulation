`ifndef __FIR_SV__
`define __FIR_SV__

`include "../common.sv"
`include "../chapter4/counter.sv"
`include "./dds.sv"

`timescale 1ns/100ps
`default_nettype none

module TestFir;
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
    logic signed [9:0] filtered, harm3;
    logic square = '0, en15;
    Counter #(15) cnt15(clk, rst, 1'b1, , en15);
    always_ff@(posedge clk) if(en15) square <= ~square; 
    FIR #(10, 27, '{ -0.005646,  0.006428,  0.019960,  0.033857,  0.036123,
                      0.016998, -0.022918, -0.068988, -0.097428, -0.087782,
                     -0.036153,  0.039431,  0.106063,  0.132519,  0.106063,
                      0.039431, -0.036153, -0.087782, -0.097428, -0.068988,
                     -0.022918,  0.016998,  0.036123,  0.033857,  0.019960,
                      0.006428, -0.005646
    })  theFir1(clk, rst, 1'b1, 10'(integer'(swave * 0.9)), filtered),
        theFir2(clk, rst, 1'b1, square ? 10'sd500 : -10'sd500, harm3);
endmodule

module FIR #(
    parameter DW = 10,
    parameter TAPS = 8,
    parameter real COEF[TAPS] = '{TAPS{0.124}}
)(
    input wire clk, rst, en,
    input wire signed [DW-1 : 0] in,    // Q1.9
    output logic signed [DW-1 : 0] out  // Q1.9
);
    localparam N = TAPS - 1;
    logic signed [DW-1 : 0] coef[TAPS];
    logic signed [DW-1 : 0] prod[TAPS];
    logic signed [DW-1 : 0] delay[TAPS];
    //`DEF_FP_MUL(mul, 1, DW-1, 1, DW-1, DW-1); //Q1.9 * Q1.9 -> Q1.9
    generate
        for(genvar t = 0; t < TAPS; t++) begin
            assign coef[t] = COEF[t] * 2.0**(DW-1.0);
            assign prod[t] = //mul(in, coef[t]);
                ( (2*DW)'(in) * (2*DW)'(coef[t]) ) >>> (DW-1);
                
        end
    endgenerate
    generate
        for(genvar t = 0; t < TAPS; t++) begin
            always_ff@(posedge clk) begin
                if(rst) delay[t] <= '0;
                else if(en) begin
                    if(t == 0) delay[0] <= prod[N - t];
                    else delay[t] <= prod[N - t] + delay[t - 1];
                end
            end
        end
    endgenerate
    assign out = delay[N];
endmodule

`endif
