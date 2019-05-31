`default_nettype none
`timescale 1ns/1ps
`include "../../simSrcGen.sv"
module test_ch3;
    code3_11 dut();
endmodule

module code3_3;
    logic clk = 1'b1;
    initial forever #5 clk = ~clk;
    logic [7:0] a = 8'b0, b, c;
    always #10 a++;
    always_ff@(posedge clk) b <= a;
    always_ff@(posedge clk) c <= b;
endmodule

module code3_4;
    logic clk = 1'b0;
    initial begin
        #2.5;
        forever #5 clk = ~clk;
    end
    logic [7:0] a = 8'b0, b, c;
    always #10 a++;
    always_ff@(posedge clk) b <= a;
    always_ff@(posedge clk) c <= b;
endmodule

module code3_5;
	task automatic genClk(
	    ref logic clk, input realtime delay, realtime period
	);
	    clk = 1'b0;
	    #delay;
	    forever #(period/2) clk = ~clk;
	endtask
	logic clk;
	initial genClk(clk, 2.5, 10);
endmodule

module code3_6_7;

    logic clk = 1'b0;
    initial begin
        #2.5;
        forever #5 clk = ~clk;
    end

    logic arst = 1'b0;
    initial begin
        #10 arst = 1'b1;
        #10 arst = 1'b0;
    end

    logic rst = 1'b0;
    initial begin
        @(posedge clk) rst = 1'b1;
        @(posedge clk) rst = 1'b0;
    end

endmodule

module code3_8;
    task automatic genArst(ref logic arst, input realtime start, input realtime duration);
        arst = 1'b0;
        #start arst = 1'b1;
        #duration arst = 1'b0;
    endtask
    logic arst;
    initial genArst(arst, 10, 20);
endmodule

//package simSrcGen;
//	task automatic genClk(
//	    ref logic clk, input realtime delay, realtime period
//	);
//	    clk = 1'b0;
//	    #delay;
//	    forever #(period/2) clk = ~clk;
//	endtask
//	task automatic genRst(
//		ref logic clk,
//		ref logic rst,
//		input int start,
//		input int duration
//	);
//		rst = 1'b0;
//		repeat(start) @(posedge clk);
//		rst = 1'b1;
//		repeat(duration) @(posedge clk);
//		rst = 1'b0;
//	endtask
//endpackage

module code3_9;
	import simSrcGen::genClk;
	task automatic genRst(
		ref logic clk,
		ref logic rst,
		input int start,
		input int duration
	);
		rst = 1'b0;
		repeat(start) @(posedge clk);
		rst = 1'b1;
		repeat(duration) @(posedge clk);
		rst = 1'b0;
	endtask
	logic clk = 1'b0;
	initial genClk(clk, 2.5, 10);
	logic rst;
	initial genRst(clk, rst, 2, 3);
endmodule

// ====== code 3-10 ======
module code3_10;
	import simSrcGen::genClk;
	logic clk;
	initial genClk(clk, 2.5, 10);
	logic [5:0] bin = '0;
	always #10 bin++;
	logic [5:0] gray;
	bin2gray #(6) the_b2g(clk, bin, gray);
endmodule
module bin2gray #(
    parameter DW = 8
)(
	input wire clk,
    input wire [DW - 1 : 0] bin,
    output logic [DW - 1 : 0] gray
);
    always_ff@(posedge clk) begin
		gray <= bin ^ (bin >> 1);
	end
endmodule
// ====== end of code 3-10 ======

// ====== code 3-11 ======
package Q15Types;
	typedef logic signed [15:0] Q15;
	typedef struct packed { Q15 re, im; } CplxQ15;
	function CplxQ15 add(CplxQ15 a, CplxQ15 b);
		add.re = a.re + b.re;
		add.im = a.im + b.im;
	endfunction
	function CplxQ15 mulCplxQ15(CplxQ15 a, CplxQ15 b);
		mulCplxQ15.re = (32'(a.re) * b.re - 32'(a.im) * b.im) >>> 15;
		mulCplxQ15.im = (32'(a.re) * b.im + 32'(a.im) * b.re) >>> 15;
	endfunction
endpackage

module code3_11;
	import Q15Types::*;
	CplxQ15 a = '{'0, '0}, b = '{'0, '0};
	integer seed = 0;
	always begin
		#10 a.re = $dist_uniform(seed, -32767, 32767);
		a.im = $dist_uniform(seed, -32767, 32767);
		b.re = $dist_uniform(seed, -32767, 32767);
		b.im = $dist_uniform(seed, -32767, 32767);
	end
	CplxQ15 c;
	always_comb c = mulCplxQ15(a, b);
	real ar, ai, br, bi, cr, ci, dr, di;
	always@(c) begin
		ar = real'(a.re) / 32768;
		ai = real'(a.im) / 32768;
		br = real'(b.re) / 32768;
		bi = real'(b.im) / 32768;
		cr = real'(c.re) / 32768;
		ci = real'(c.im) / 32768;
		dr = ar * br - ai * bi;
		di = ar * bi + ai * br;
		if(dr < 1.0 && dr > -1.0 && di < 1.0 && di > -1.0) begin
			if(cr - dr > 1.0 / 32768.0 || cr - dr < -1.0 / 32768.0)
				$display("err:\t", cr, "\t", dr);
			if(ci - di > 1.0 / 32768.0 || ci - di < -1.0 / 32768.0)
				$display("err:\t", ci, "\t", di);
		end
	end
endmodule
// ====== end code 3-11
