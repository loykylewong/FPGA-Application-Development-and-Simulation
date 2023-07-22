`include "../common.sv"
//`include "./fixedpoint_pkg.sv"

`timescale 1ns/100ps
`default_nettype none

module TestCordic;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 80, 100);
    initial GenRst(clk, rst, 2, 2);
    logic signed [9:0] ang = '0, cos, sin, arem;
    always_ff@(posedge clk) begin
        if(rst) ang <= '0;
        else ang <= ang + 1'b1;
    end
    Cordic #(10) theCordic(clk, rst, 1'b1,
        10'sd500, 10'sd0, ang, cos, sin, arem);
endmodule

module CordicStage #( parameter DW = 10, AW = DW, STG = 0 )(
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
            if(ain >= 0) begin
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

module Cordic #( parameter DW = 10, AW = DW, ITER = DW )(  
    input wire clk, rst, en,
    input wire signed [DW - 1 : 0] xin,    //Q1.9
    input wire signed [DW - 1 : 0] yin,    //Q1.9
    input wire signed [AW - 1 : 0] ain,    //Q1.9 [-1,1)->[-pi,pi)
    output logic signed [DW - 1 : 0] xout, //Q1.9
    output logic signed [DW - 1 : 0] yout, //Q1.9
    output logic signed [AW - 1 : 0] arem  //Q1.9 [-1,1)->[-pi,pi)
);
    import Fixedpoint::*;
    logic signed [DW : 0] x [ITER+1];  //Q2.9 to against overflow
    logic signed [DW : 0] y [ITER+1];  //Q2.9 to against overflow
    logic signed [AW : 0] a [ITER+1];  //Q1.10 [-1,1)->[-pi,pi)
    assign x[0] = xin, y[0] = yin, a[0] = ain <<< 1;//Q1.9 to Q1.10
    generate
        for(genvar i = 0; i < ITER; i++)
        begin : stages
            CordicStage #(DW+1, AW+1, i) cordicStgs(clk, rst, en,
                x[i], y[i], a[i], x[i+1], y[i+1], a[i+1]);
        end    
    endgenerate
    localparam real lambda = 0.6072529350;
    wire signed [DW : 0] lam = lambda * 2**DW; // 0.607253(Q1.10)
    `DEF_FP_MUL(mul, 2, DW-1, 1, DW, DW-1);    // Q2.9*Q1.10->Q2.9
//    `DEF_FP_MUL(mul, 2, 9, 1, 10, 9);    // Q2.9*Q1.10->Q2.9
    always_ff@(posedge clk) begin
        if(rst) begin
            xout <= 1'b0; yout <= 1'b0; arem <= 1'b0;
        end
        else if(en) begin
            xout <= mul(x[ITER], lam);
            yout <= mul(y[ITER], lam);
//            xout <= (22'sd1 * x[ITER] * lam) >>> 10;
//            yout <= (22'sd1 * y[ITER] * lam) >>> 10;
//            xout <= (22'(x[ITER]) * 22'(lam)) >>> 10;
//            yout <= (22'(y[ITER]) * 22'(lam)) >>> 10;
            arem <= a[ITER] >>> 1;
        end
    end
endmodule
    
    
    
    
    
    
