`ifndef __TEST_FP_LETS_SV__
`define __TEST_FP_LETS_SV__

`include "../common.sv"
`include "./fixedpoint_pkg.sv"

`timescale 1ns/100ps
`default_nettype none

module TestFpLets;
    import SimSrcGen::*;
    import Fixedpoint::*;
    logic clk, rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 2, 2);
    logic signed [15:0] q1_15a, q1_15b;
    logic signed [31:0] q9_23;
    int seed = 67349;
    always_ff@(posedge clk) begin
        q1_15a = $dist_uniform(seed, -32767, 32767);
        q1_15b = $dist_uniform(seed, -32767, 32767);
        q9_23 = $dist_uniform(seed, -8388607, 8388607);
    end
    `DEF_FP_ADD(add_1q15_1q15,     1, 15, 1, 15, 15);
    `DEF_FP_ADD(add_1q15_9q23_q15, 1, 15, 9, 23, 15);
    `DEF_FP_ADD(add_1q15_9q23_q23, 1, 15, 9, 23, 23);
    `DEF_FP_MUL(mul_1q15_1q15,     1, 15, 1, 15, 15);
    `DEF_FP_MUL(mul_1q15_1q15_q30, 1, 15, 1, 15, 30);
    `DEF_FP_MUL(mul_1q15_9q23_q23, 1, 15, 9, 23, 23);
    int s0, s1, s2, p0, p1, p2;
    assign s0 = add_1q15_1q15    (q1_15a, q1_15b);
    assign s1 = add_1q15_9q23_q15(q1_15a, q9_23);
    assign s2 = add_1q15_9q23_q23(q1_15a, q9_23);
    assign p0 = mul_1q15_1q15    (q1_15a, q1_15b);
    assign p1 = mul_1q15_1q15_q30(q1_15a, q1_15b);
    assign p2 = mul_1q15_9q23_q23(q1_15a, q9_23);
    real q1_15a_r, q1_15b_r, q9_23r;
    real s0r, s1r, s2r, p0r, p1r, p2r;
    real s0rc, s1rc, s2rc, p0rc, p1rc, p2rc;
    let abs(x) = x >= 0? x : -x;
    always@* begin
        q1_15a_r = real'(q1_15a) / (2.0**15);
        q1_15b_r = real'(q1_15b) / (2.0**15);
        q9_23r   = real'(q9_23)  / (2.0**23);
        s0r      = real'(s0) / (2.0**15);
        s1r      = real'(s1) / (2.0**15);
        s2r      = real'(s2) / (2.0**23);
        p0r      = real'(p0) / (2.0**15);
        p1r      = real'(p1) / (2.0**30);
        p2r      = real'(p2) / (2.0**23);
        s0rc     = q1_15a_r + q1_15b_r;
        s1rc     = q1_15a_r + q9_23r;
        s2rc     = q1_15a_r + q9_23r;
        p0rc     = q1_15a_r * q1_15b_r;
        p1rc     = q1_15a_r * q1_15b_r;
        p2rc     = q1_15a_r * q9_23r;
        #1 begin
            if(abs(s0r - s0rc) > 0.5**15) $display("s0r: %g - s0rc: %g", s0r, s0rc);
            if(abs(s1r - s1rc) > 0.5**15) $display("s1r: %g - s1rc: %g", s1r, s1rc);
            if(abs(s2r - s2rc) > 0.5**23) $display("s2r: %g - s2rc: %g", s2r, s2rc);
            if(abs(p0r - p0rc) > 0.5**15) $display("p0r: %g - p0rc: %g", p0r, p0rc);
            if(abs(p1r - p1rc) > 0.5**30) $display("p1r: %g - p1rc: %g", p1r, p1rc);
            if(abs(p2r - p2rc) > 0.5**23) $display("p2r: %g - p2rc: %g", p2r, p2rc);
        end
    end
endmodule

`endif
