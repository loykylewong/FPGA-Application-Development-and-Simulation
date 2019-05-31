`default_nettype none
`include "../Common.sv"
module TestShiftReg;

endmodule

module ShiftReg #(
	parameter DW = 8
)(
	input wire clk, rst, shift, load,
	input wire [DW - 1 : 0] d,
	input wire serial_in,
	output logic [DW - 1 : 0] q
);
	always_ff@(posedge clk) begin
		if(rst) q <= '0;
		else if(load) q <= d;
		else if(shift) q <= {q, serial_in};
	end
endmodule
