`default_nettype none
`include "../Common.sv"

module TestCCEvent;
    import SimSrcGen::*;
    logic clk_a, clk_b;
    initial GenClk(clk_a, 2, 10);
	initial GenClk(clk_b, 1, 12);
    logic in = 0;
	initial begin
		#100 in = 1;
		#10 in = 0;
		#80 in = 1;
		#10 in = 0;
	end
	logic busy, out;
    CrossClkEvent theCCEvent(clk_a, clk_b, in, busy, out);
endmodule

module CrossClkEvent (
	input wire clk_a, clk_b,
	input wire in,     // domain a
	output logic busy, // domain a
	output logic out   // domain b
);
	logic ra0 = '0, ra1 = '0, ra2 = '0;
	logic rb0 = '0, rb1 = '0, rb2 = '0;
	// === clk_a domain ===
	always_ff@(posedge clk_a) begin
		if(in) ra0 <= 1'b1;
		else if(ra2) ra0 <= 1'b0;
	end
	always_ff@(posedge clk_a) begin
		{ra2, ra1} <= {ra1, rb1};
	end
	assign busy = ra0 | ra2;
	// === clk_b domain ===
	always_ff@(posedge clk_b) begin
		{rb2, rb1, rb0} <= {rb1, rb0, ra0};
	end
	assign out = rb1 & ~rb2;
endmodule
