`ifndef __SLOW_MULT_SV__
`define __SLOW_MULT_SV__

`include "../common.sv"
`include "../chapter4/counter.sv"

`timescale 1ns/100ps
`default_nettype none

module TestSlowMult;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 2, 2);
    logic [7:0] mcand = '0, mer = '0;
    logic start = '0, valid, busy;
    logic [15:0] prod;
    SlowMult #(8) theSM(clk, rst, mcand, mer, start, prod, valid, busy);
    initial begin
        repeat(10) @(posedge clk);
        repeat(1000) begin
            @(posedge clk) begin
                mcand <= $random(); 
                mer <= $random();
                start <= '1;
            end
            @(posedge clk) start <= '0;
            do @(posedge clk);
            while(busy);
        end
        @(posedge clk) $stop();
    end
    always_ff@(posedge clk) begin
        if(valid & prod != (32'(mcand) * mer))
            $display("err: %d * %d -> %d should be %d", mcand, mer, prod, (32'(mcand) * mer));
    end
endmodule

module SlowMult #( parameter W = 16 )(
    input wire clk, rst,
    input wire [W - 1 : 0] multiplicand, multiplier,
    input wire start,
    output logic [W * 2 - 1 : 0] product,
    output logic valid, busy
);
    logic [W - 1 : 0] mer;
    logic [W * 2 - 2 : 0] sum, mcand;
    logic [$clog2(W) - 1 : 0] bit_cnt;
    logic bit_co;
    Counter #(W) bitCnt(
        clk, rst | start & ~busy, busy, bit_cnt, bit_co);
    always_ff@(posedge clk) begin
        if(rst) busy <= '0;
        else if(start) busy <= '1;
        else if(bit_co) busy <= '0;
    end
    always_ff@(posedge clk) begin
        if(busy) begin
            mcand <= mcand << 1;
            mer <= mer >> 1;
        end
        if(start) begin
            mcand <= multiplicand;
            mer <= multiplier;
        end
    end
    always_ff@(posedge clk) begin
        if(busy) begin
            sum <= sum + (mer[0] ? mcand : '0);
        end
        else if(start) sum <= '0;
    end
    always_ff@(posedge clk) begin
        if(bit_co) product <= sum + (mer[0] ? mcand : '0);
    end
    always_ff@(posedge clk) valid <= bit_co;
endmodule



//module SlowMult #( parameter W = 16 )(
//    input wire clk, rst,
//    input wire [W - 1 : 0] multiplicand, multiplier,
//    input wire start,
//    output logic [W * 2 - 1 : 0] product,
//    output logic valid,
//    output logic busy
//);
//    logic [W - 1 : 0] mcand, mer;
//    logic [W * 2 - 2 : 0] sum;
//    logic [$clog2(W) - 1 : 0] bit_cnt;
//    logic bit_co;
//    Counter #(W) bitCnt(
//        clk, rst | start & ~busy, busy, bit_cnt, bit_co);
//    always_ff@(posedge clk) begin
//        if(rst) busy <= '0;
//        else if(start) busy <= '1;
//        else if(bit_co) busy <= '0;
//    end
//    always_ff@(posedge clk) begin
//        if(busy) mer <= mer << 1;
//        if(start) begin
//            mcand <= multiplicand;
//            mer <= multiplier;
//        end
//    end
//    always_ff@(posedge clk) begin
//        if(busy) begin
//            sum <= (sum << 1) + (mer[W-1] ? mcand : '0);
//        end
//        else if(start) sum <= '0;
//    end
//    always_ff@(posedge clk) begin
//        if(bit_co) product <= (sum << 1) + (mer[W-1] ? mcand : '0);
//    end
//    always_ff@(posedge clk) valid <= bit_co;
//endmodule

`endif