`default_nettype none
`include "../../book2015.sv"

module TestCounter;
	import SimSrcGen::*;
	logic clk;
	logic rst;
	logic en;
	initial GenClk(clk, 2, 10);
	initial GenRst(clk, rst, 10, 1);
	initial begin
		en = 1'b1;
		#100 en = 1'b0;
		#100 en = 1'b1;
	end
	logic [6:0] cnt;
	logic co;
	Counter #(128) theCnt(clk, rst, en, cnt, co);
endmodule

module TestCntSecMinHr;
	import SimSrcGen::*;
	logic clk;
	logic rst;
	initial GenClk(clk, 0, 100ms);
	initial GenRst(clk, rst, 0, 1);
	logic [5:0] sec, min;
	logic [4:0] hr;
	CntSecMinHr theCntSMH(clk, rst, sec, min, hr);
endmodule

module CntSecMinHr(
	input wire clk, rst,
	output logic [5:0] sec,
	output logic [5:0] min,
	output logic [4:0] hr
);
	logic en1sec, en1min, en1hr;
	Counter #(10) cnt1sec (.clk(clk), .rst(rst), .en(  1'b1), .cnt(),    .co(en1sec));
	Counter #(60) cnt60sec(.clk(clk), .rst(rst), .en(en1sec), .cnt(sec), .co(en1min));
	Counter #(60) cnt60min(.clk(clk), .rst(rst), .en(en1min), .cnt(min), .co(en1hr ));
	Counter #(24) cnt24hr (.clk(clk), .rst(rst), .en(en1hr ), .cnt(hr ), .co());
endmodule

module Counter #(
	parameter M = 100
)(
	input wire clk, rst, en,
	output logic [$clog2(M) - 1 : 0] cnt,
	output logic co
);
	assign co = en & (cnt == M - 1);
	always_ff@(posedge clk) begin
		if(rst) cnt <= '0;
		else if(en) begin
			if(cnt < M - 1) cnt <= cnt + 1'b1;
			else cnt <= '0;
		end
	end
endmodule
