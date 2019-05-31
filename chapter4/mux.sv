`default_nettype none
`include "../Common.sv"
module TestMux;
	logic [7:0] a[4] = '{4{'0}}, y;
	logic [1:0] sel = '0;
	always #10 a[0]++;
	always #20 a[1]++;
	always #40 a[2]++;
	always #80 a[3]++;
	always #160 sel++;
	Mux #(8, 4) theMux(a, sel, y);
endmodule

module Mux #(
	parameter DW = 8,
	parameter CH = 4
)(
	input wire [DW - 1 : 0] in[CH],
	input wire [$clog2(CH) - 1 : 0] sel,
	output logic [DW - 1 : 0] out
);
	assign out = in[sel];
endmodule
