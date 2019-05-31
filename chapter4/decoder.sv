`default_nettype none
`include "../Common.sv"
module TestDecoder;
	import CombFunctions::*;
	logic [2:0] a = 5'b0;
	logic [7:0] y;
	always #10 a++;
	Decoder #(3) theDec(a, y);
endmodule

module Decoder #(
	parameter INW = 4
)(
	input wire [INW - 1 : 0] in,
	output logic [2**INW - 1 : 0] out
);
	assign out = (2**INW)'(1) << in;
endmodule
