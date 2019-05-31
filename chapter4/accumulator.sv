`timescale 1ns/1ps
`default_nettype none
`include "../Common.sv"
module TestAccu;
    import SimSrcGen::*;
    logic clk;
    initial GenClk(clk, 2, 10);
    logic rst;
    initial GenRst(clk, rst, 1, 1);
    logic [15:0] d = '0, acc;
    always #10 d++;
    Accumulator #(16) theAcc(clk, rst, 1'b1, d, acc);
    logic [5:0] dm = '0, accm;
    always #10 dm++;
    AccuM #(50) theAccM(clk, rst, 1'b1, dm, accm);
endmodule

module Accumulator #( parameter DW = 8 )(
    input wire clk, rst, en,
    input wire [DW - 1 : 0] d,
    output logic [DW - 1 : 0] acc
);
    always_ff@(posedge clk) begin
        if(rst) acc <= '0;
        else if(en) acc <= acc + d;
    end
endmodule

module AccuM #( parameter M = 100 )(
    input wire clk, rst, en,
    input wire [$clog2(M) - 1 : 0] d,
    output logic [$clog2(M) - 1 : 0] acc
);
    logic [$clog2(M) - 1 : 0] acc_next;
    always_comb begin
        acc_next = acc + d;
        if(acc_next >= M || acc_next < acc)
            acc_next -= M;
    end
    always_ff@(posedge clk) begin
        if(rst) acc <= '0;
        else if(en)    acc <= acc_next;
    end
endmodule
