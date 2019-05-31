`default_nettype none
`include "../Common.sv"
module TestEncoder;
	import CombFunctions::*;
	logic [7:0] a = 5'b0;
	logic [2:0] y;
	always #10 a++;
//	Encoder #(3) theEnc(a, y);
	`DEF_PRIO_ENC(PrioEnc8to3, 3)
	always_comb y = PrioEnc8to3(a);
endmodule

module Encoder #(
	parameter OUTW = 4
)(
	input wire [2**OUTW - 1 : 0] in,
	output logic [OUTW - 1 : 0] out
);
	always_comb begin
		out = '0;
		for(integer i = 2**OUTW - 1; i >= 0; i--) begin
			if(in[i]) out = OUTW'(i);
		end
	end
endmodule

