`default_nettype none
`include "../Common.sv"
module TestCCCnt;
    import SimSrcGen::*;
    logic clk_a, clk_b;
    initial GenClk(clk_a, 2, 10);
	initial GenClk(clk_b, 1, 9);
    logic inc = 0;
    always #10 inc = $random();
	logic [7:0] cnt_a, cnt_b;
    CrossClkCnt theCCCnt(clk_a, clk_b, inc, cnt_a, cnt_b);
endmodule

module CrossClkCnt #( parameter W = 8 )(
	input wire clk_a, clk_b,
	input wire rst_a, rst_b,
	input wire inc,
	output logic [W - 1 : 0] cnt_a = '0, cnt_b
);
	// === clk_a domain ===
	logic [W - 1 : 0] bin_next;
	logic [W - 1 : 0] gray, gray_next;
	always_comb begin
		bin_next = cnt_a + inc;
		gray_next = bin_next ^ (bin_next >> 1);
	end
	always_ff@(posedge clk_a) begin
		if(rst_a) begin
			cnt_a <= '0;
			gray <= '0;
		end
		else begin
		cnt_a <= bin_next;
		gray <= gray_next;
	end
	end
	// === clk_b domain ===
	logic [W - 1 : 0] gray_sync[2];
	always_ff@(posedge clk_b) begin
		if(rst_b) begin
			gray_sync <= {W'(0), W'(0)};
		end
		else begin
		gray_sync <= {gray, gray_sync[0]};
	end
	end
	always_comb begin
		for(int i = 0; i < W; i++)
			cnt_b[i] = ^(gray_sync[1] >> i);
	end
endmodule
