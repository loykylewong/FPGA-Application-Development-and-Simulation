`timescale 1ns/1ps
`default_nettype none
`include "../Common.sv"
module TestPulseWiden;
	import SimSrcGen::*;
	logic clk;
	initial GenClk(clk, 2, 10);
	logic in;
	initial begin
		in = 0;
		#44 in = 1;
		#56 in = 0;
		#100 in = 1;
		#10 in = 0;
	end
	logic out, out2, out3;
	PulseWiden #(4) pw1(clk, in, out);
	PulseWiden #(2) pw2(clk, in, out2);
	PulseWiden #(3) pw3(clk, in, out3);
endmodule

module PulseWiden #( parameter RATIO = 1 )(
	input wire clk, in, 
	output logic out
);
	logic [$clog2(RATIO + 1) - 1 : 0] cnt = '0;
	always_ff@(posedge clk) begin
		if(in) cnt <= RATIO;
		else if(cnt > 0) cnt <= cnt - 1'b1;
	end
	assign out = cnt > 0;
endmodule
