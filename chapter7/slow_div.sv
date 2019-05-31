`ifndef __SLOW_DIV_SV__
`define __SLOW_DIV_SV__

`include "../common.sv"
`include "../chapter4/counter.sv"

`timescale 1ns/100ps
`default_nettype none

module TestSlowDiv;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 2, 2);
    logic [7:0] ddend = '0, dsor = '0;
    logic [7:0] quot, rem;
    logic start = '0, valid, busy;
    SlowDiv #(8) theSD(clk, rst, ddend, dsor, start, quot, rem, valid, busy);
    initial begin
        repeat(10) @(posedge clk);
        repeat(1000) begin
            @(posedge clk) begin
                ddend <= $random(); 
                dsor <= $random();
                start <= '1;
            end
            @(posedge clk) start <= '0;
            do @(posedge clk);
            while(busy);
        end
        @(posedge clk) $stop();
    end
    always_ff@(posedge clk) begin
        if(valid && (ddend != quot * dsor + rem))
            $display("err: %d * %d -> %d ... %d", ddend, dsor, quot, rem);
    end
endmodule

module SlowDiv #( parameter W = 16 )(
    input wire clk, rst,
    input wire [W - 1 : 0] dividend,
    input wire [W - 1 : 0] divisor,
    input wire start,
    output logic [W - 1 : 0] quotient,
    output logic [W - 1 : 0] remainder,
    output logic valid, busy
);
    logic [W - 1 : 0] ddend, quot;
    logic [W * 2 - 2 : 0] dsor;
    logic bit_co;
    logic [$clog2(W)-1 : 0] bit_cnt;
    Counter #(W) cntBit(clk, rst | start & ~busy, busy, bit_cnt, bit_co);
    always_ff@(posedge clk) begin
        if(rst) busy <= '0;
        else if(bit_co) busy <= '0;
        else if(start) busy <= '1;
    end
    always_ff@(posedge clk) begin
        if(busy) begin
            dsor <= dsor >> 1;
            if(ddend >= dsor) begin
                ddend <= ddend - dsor;
                quot <= (quot << 1) | 1'b1;
            end
            else quot <= quot << 1;
        end
        else if(start) begin
            ddend <= dividend;
            dsor <= {divisor, (W-1)'(0)};
            quot <= '0;
        end
    end
    always_ff@(posedge clk) begin
        if(bit_co) begin
            if(ddend >= dsor) begin
                remainder <= ddend - dsor;
                quotient <= (quot << 1) | 1'b1;
            end
            else begin
                remainder <= ddend;
                quotient <= quot << 1;
            end
        end
    end
    always_ff@(posedge clk) valid <= bit_co;
endmodule

//module Divider ( parameter W = 16 )(
//    input clk,
//    input [W - 1 : 0] dividend,
//    input [W - 1 : 0] divisor,
//    input start,
//    output [W - 1 : 0] quotient,
//    output [W - 1 : 0] remainder,
//    output valid,
//);
//    
//    logic [W - 1 : 0] shifter;
//    logic [W - 1 : 0] quot;
//    
//    logic [7 : 0] bitpos;
//    logic valided;
//
//    always@(posedge clk)
//    begin
//        if(bitpos == 0)
//        begin
//            if(shifter >= divisor)
//            begin
//                remainder <= shifter - divisor;
//                quotient <= (quot << 1) | 1'b1;
//            end
//            else
//            begin
//                remainder <= shifter;
//                quotient <= quot << 1;
//            end
//            if(!valided)
//            begin
//                valid <= 1'b1;
//                valided <= 1'b1;
//            end
//            else
//            begin
//                valid <= 1'b0;
//            end
//            if(start)
//            begin
//                valided <= 1'b0;
//                shifter <= 1'b0;
//                quot <= 1'b0;
//                bitpos <= W;
//            end
//        end
//        else
//        begin
//            valid <= 1'b0;
//            if(shifter >= divisor)
//            begin
//                shifter <= ((shifter - divisor) << 1) | dividend[bitpos - 1];
//                quot <= (quot << 1) | 1'b1;
//            end
//            else
//            begin
//                shifter <= (shifter << 1) | dividend[bitpos - 1];
//                quot <= quot << 1;
//            end
//            bitpos <= bitpos - 1'b1;
//        end
//    end
//endmodule

`endif