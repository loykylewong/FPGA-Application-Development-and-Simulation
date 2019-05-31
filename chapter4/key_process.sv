`timescale 1ms/1us
`default_nettype none
`include "../Common.sv"
module TestKeyProcess;
	import SimSrcGen::GenClk;
	logic clk;
	initial GenClk(clk, 0.02, 0.1);
	task automatic KeyPress(ref logic key, input realtime t);
		for(int i = 0; i < 30; i++) begin
			#0.13ms key = '0; #0.12ms key = '1;
		end
		#t; key = '0;
	endtask
	logic key = '0, key_en;
	initial begin 
		#10 KeyPress(key, 50);
		#50 KeyPress(key, 50);
	end
	KeyProcess #(100, 1) theKeyProc(clk, key, key_en);
endmodule

module KeyProcess #(
	parameter SMP_INTV = 1_000_000,
	parameter KEY_NUM = 1
)(
	input wire clk,
	input wire [KEY_NUM - 1 : 0] key,
	output logic [KEY_NUM - 1 :0] key_en
);
	logic [$clog2(SMP_INTV) - 1 : 0] smp_cnt = '0;
	wire en_intv = (smp_cnt == SMP_INTV - 1);
	always_ff@(posedge clk) begin
		if(smp_cnt < SMP_INTV - 1) smp_cnt <= smp_cnt + 1'b1;
		else smp_cnt <= '0;
	end
	logic [KEY_NUM - 1 : 0] key_reg[2] = '{2{'0}};
	always_ff@(posedge clk) begin
		if(en_intv) key_reg[0] <= key;
		key_reg[1] <= key_reg[0];
	end
	assign key_en = ~key_reg[1] & key_reg[0];
endmodule
