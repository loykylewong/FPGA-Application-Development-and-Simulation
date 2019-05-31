`ifndef __SLOW_SQRT_SV__
`define __SLOW_SQRT_SV__

`include "../common.sv"

`timescale 1ns/100ps
`default_nettype none

module TestSlowSqrt;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 2, 2);
    logic [15:0] sq = '0;
    logic [7:0] rt, rem;
    logic start = '0, valid;
    SlowSqrt #(8) theSqrt(clk, rst, sq, start, rt, rem, valid);
    initial begin
        repeat(10) @(posedge clk);
        repeat(1000) begin
            @(posedge clk) begin
                sq <= $random();
                start <= '1;
            end
            @(posedge clk) start <= '0;
            do @(posedge clk);
            while(~valid);
        end
        @(posedge clk) $stop();
    end
    logic [7:0] crt, crem;
    always_ff@(posedge clk) begin
        if(valid) begin
            crt = $floor($sqrt(sq));
            crem = sq - 16'(crt) * crt;
            if(crt != rt || crem != rem) begin
                $display("err: sqrt(%d) -> %d ... %d", sq, rt, rem);
                $display("\tshould be %d ... %d", crt, crem);
            end
        end
    end
endmodule

module SlowSqrt #( parameter RTW = 8 )( // root witdh
    input wire clk, rst,
    input wire [RTW * 2 - 1 : 0] in,
    input wire start,
    output logic [RTW - 1 : 0] sqrt,
    output logic [RTW - 1 : 0] rem,
    output logic valid
);
    localparam DW = RTW * 2;
    logic [DW - 1 : 0] res;
    logic [DW - 1 : 0] bm;             // the \Delta r
    logic [DW - 1 : 0] num;
    wire [DW - 1 : 0] sub = res + bm;  // the res'
    wire [DW -1 : 0] bmm = {2'b01, {(DW - 2){1'b0}}}; // highest segment
    always_ff@(posedge clk) begin
        if(rst) valid <= 1'b0;
        else valid <= (bm == 1'd1);
    end
    always_ff@(posedge clk) begin
        if(rst) bm <= '0;
        else if(bm > '0) bm <= bm >> 2;
        else if(start) bm <= bmm >> 2;
    end
    always_ff@(posedge clk) begin
        if(rst) begin res <= 1'b0; num <= 1'b0; end
        else if(bm > '0) begin
            if(num >= sub) begin
                num <= num - sub;
                res <= (res >> 1) + bm;
            end
            else res <= (res >> 1);
        end
        else if(start) begin
            if(in >= bmm) begin
                num <= in - bmm;
                res <= bmm;
            end
            else begin
                num <= in;
                res <= 0;
            end
        end
    end
    always_ff@(posedge clk) begin
        if(rst) begin sqrt <= '0; rem <= '0; end
        else if(bm == 1'd1) begin
            if(num >= sub) begin
                sqrt <= {1'b0, res[DW - 1 : 1]} + bm;
                rem <= num - sub;
            end
            else begin
                sqrt <= {1'b0, res[DW - 1 : 1]};
                rem <= num;
            end
        end
    end
endmodule

`endif
