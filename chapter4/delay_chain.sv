`ifndef __DELAY_CHAIN_SV__
`define __DELAY_CHAIN_SV__

`timescale 1ns/1ps
`default_nettype none
`include "../Common.sv"

module TestDelayChain;
	import SimSrcGen::*;
	logic [7:0] a, y;
	logic clk;
	logic rst;
	initial GenClk(clk, 2, 10);
	initial GenRst(clk, rst, 1, 2);
	always #10 a = $random();
	DelayChain #(8,0) dc(clk, rst, 1'b1, a, y);
endmodule

module DelayChain #(
	parameter DW = 8,
	parameter LEN = 4
)(
    input wire clk, rst, en,
    input wire [DW - 1 : 0] in,
    output logic [DW - 1 : 0] out
);
    generate
        if(LEN == 0) begin
            assign out = in;
        end
        else if(LEN == 1) begin
            logic [DW - 1 : 0] dly;
            always_ff@(posedge clk) begin
                if(rst) dly = '0;
                else if(en) dly <= in;
            end
            assign out = dly;
        end
        else begin
            logic [DW - 1 : 0] dly[0 : LEN - 1];
            always_ff@(posedge clk) begin
                if(rst) dly = '{LEN{'0}};
                else if(en) dly[0 : LEN - 1] <= {in, dly[0 : LEN - 2]};
            end
            assign out = dly[LEN - 1];
        end
    endgenerate
endmodule

`endif
