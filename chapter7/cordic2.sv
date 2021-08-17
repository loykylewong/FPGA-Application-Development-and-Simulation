`include "../common.sv"
//`include "./fixedpoint_pkg.sv"

`timescale 1ns/1ps
`default_nettype none

module TestCordic2;
    import SimSrcGen::*;
    localparam integer DW = 16;
    logic clk, rst;
    initial GenClk(clk, 8000, 10000);
    initial GenRst(clk, rst, 2, 2);
    logic signed [DW-1:0] ang = -1<<<(DW-1), cos, sin, arem;
    logic signed [DW-1:0] xrem, yrem, aout;
    always_ff@(posedge clk) begin
        if(rst) ang <= -1<<<(DW-1);
        else ang <= ang + 1'b1;
    end
    Cordic2 #("ROT", DW) theRotCordic(clk, rst, 1'b1,
        16'sd30000, 16'sd0, ang, cos, sin, arem);
    Cordic2 #("VEC", DW) theVecCordic(clk, rst, 1'b1,
        cos, sin, 'b0, xrem, yrem, aout);
    real angle_out, angle_ref;
    always_comb begin
        angle_ref = $atan2(real'(sin), real'(cos)) * 180.0 / 3.1415926536;
        angle_out = real'(aout) / 32768.0 * 180.0;
    end
endmodule

// Rotation Mode Stage
module CordicRotStage #(
    parameter integer DW = 10,
    parameter integer AW = DW,
    parameter integer STG = 0
)(
    input wire clk, rst, en,
    input wire signed [DW-1 : 0] xin,      // x_i
    input wire signed [DW-1 : 0] yin,      // y_i
    input wire signed [AW-1 : 0] ain,      // theta_i
    output logic signed [DW-1 : 0] xout,   // x_i+1
    output logic signed [DW-1 : 0] yout,   // y_i+1
    output logic signed [AW-1 : 0] aout    // theta_i+1
);
    // atan:real:[-pi, pi) <=> theta:(Q1.(AW-1)):[-1.0, 1.0) 
    localparam real atan = $atan(2.0**(-STG));
    wire [AW-1 : 0] theta = atan / 3.1415926536 * 2.0**(AW-1);
    wire signed [DW-1 : 0] x_shifted = (xin >>> STG);                                    
    wire signed [DW-1 : 0] y_shifted = (yin >>> STG);
    always_ff@(posedge clk) begin
        if(rst) begin
            aout <= 1'b0; xout <= 1'b0; yout <= 1'b0;
        end
        else if(en) begin
            if(ain > 0) begin
                aout <= ain - theta;
                xout <= xin - y_shifted;
                yout <= yin + x_shifted;
            end
            else begin
                aout <= ain + theta;
                xout <= xin + y_shifted;
                yout <= yin - x_shifted;
            end
        end
    end
endmodule

// Vectoring Mode Stage
module CordicVecStage #(
    parameter integer DW = 10,
    parameter integer AW = DW,
    parameter integer STG = 0
)(
    input wire clk, rst, en,
    input wire        [DW-1 : 0] xin,      // x_i, must be positive
    input wire signed [DW-1 : 0] yin,      // y_i
    input wire signed [AW-1 : 0] ain,      // theta_i
    output logic signed [DW-1 : 0] xout,   // x_i+1
    output logic signed [DW-1 : 0] yout,   // y_i+1
    output logic signed [AW-1 : 0] aout    // theta_i+1
);
    // atan:real:[-pi, pi) <=> theta:(Q1.(AW-1)):[-1.0, 1.0) 
    localparam real atan = $atan(2.0**(-STG));
    wire [AW-1 : 0] theta = atan / 3.1415926536 * 2.0**(AW-1);
    wire        [DW-1 : 0] x_shifted = (xin >>> STG);    
    wire signed [DW-1 : 0] y_shifted = (yin >>> STG);
    always_ff@(posedge clk) begin
        if(rst) begin
            aout <= 1'b0; xout <= 1'b0; yout <= 1'b0;
        end
        else if(en) begin
            if(yin < 0) begin
                aout <= ain - theta;
                xout <= xin - y_shifted;
                yout <= yin + x_shifted;
            end
            else begin
                aout <= ain + theta;
                xout <= xin + y_shifted;
                yout <= yin - x_shifted;
            end
        end
    end
endmodule

// Dual mode Cordic: Rotation mode and Vectoring mode
module Cordic2 #(
    parameter string MODE = "ROT",      // "ROT" or "VEC"
    parameter integer DW = 10, AW = DW, ITER = DW
)(  
    input wire clk, rst, en,
    input wire signed [DW - 1 : 0] xin,    //Q1.9 , in Vectoring mode, xin must NOT be negative
    input wire signed [DW - 1 : 0] yin,    //Q1.9
    input wire signed [AW - 1 : 0] ain,    //Q1.9 [-1,1)->[-pi,pi)
    output logic signed [DW - 1 : 0] xout, //Q1.9
    output logic signed [DW - 1 : 0] yout, //Q1.9
    output logic signed [AW - 1 : 0] aout  //Q1.9 [-1,1)->[-pi,pi)
);
    import Fixedpoint::*;
    logic signed [DW : 0] x [ITER+1];  //Q2.9 to against overflow
    logic signed [DW : 0] y [ITER+1];  //Q2.9 to against overflow
    logic signed [AW : 0] a [ITER+1];  //Q1.10 [-1,1)->[-pi,pi)
    assign x[0] = xin, y[0] = yin, a[0] = ain <<< 1;//Q1.9 to Q1.10
    generate
        for(genvar i = 0; i < ITER; i++)
        begin : stages
            if(MODE == "ROT")
            begin : rot_stages
                CordicRotStage #(DW+1, AW+1, i) cordicStgs(clk, rst, en,
                    x[i], y[i], a[i], x[i+1], y[i+1], a[i+1]);
            end
            else if(MODE == "VEC")
            begin : vec_stages
                CordicVecStage #(DW+1, AW+1, i) cordicStgs(clk, rst, en,
                    x[i], y[i], a[i], x[i+1], y[i+1], a[i+1]);
            end
            else
            begin
                $fatal("Parameter \"MODE\" in module \"CordicDM\" must be \"ROT\" or \"VEC\"");
            end
        end    
    endgenerate
    localparam real lambda = 0.6072529350;
    wire signed [DW : 0] lam = lambda * 2**DW; // 0.607253(Q1.10)
    `DEF_FP_MUL(mul, 2, DW-1, 1, DW, DW-1);    // Q2.9*Q1.10->Q2.9
//    `DEF_FP_MUL(mul, 2, 9, 1, 10, 9);    // Q2.9*Q1.10->Q2.9
    always_ff@(posedge clk) begin
        if(rst) begin
            xout <= 1'b0; yout <= 1'b0; aout <= 1'b0;
        end
        else if(en) begin
            xout <= mul(x[ITER], lam);
            yout <= mul(y[ITER], lam);
//            xout <= (22'sd1 * x[ITER] * lam) >>> 10;
//            yout <= (22'sd1 * y[ITER] * lam) >>> 10;
//            xout <= (22'(x[ITER]) * 22'(lam)) >>> 10;
//            yout <= (22'(y[ITER]) * 22'(lam)) >>> 10;
            aout <= a[ITER] >>> 1;
        end
    end
endmodule
    
    
    
    
    
    
