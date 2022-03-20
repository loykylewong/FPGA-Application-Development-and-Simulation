`ifndef __SCFIFO_SV__
`define __SCFIFO_SV__

`include "../common.sv"
`include "../chapter4/memory.sv"

`timescale 1ns/100ps
`default_nettype none

module TestScFifo;
    import SimSrcGen::*;
	logic clk;
	initial GenClk(clk, 8, 10);
	logic [7:0] din = '0, dout;
	logic wr = '0, rd = '0;
	logic [2:0] wc, rc, dc;
	logic fu, em;
	initial begin
		for(int i = 0; i < 10; i++) begin
			@(posedge clk) {wr, din} = {1'b1, 8'($random())};
		end
		@(posedge clk) wr = 1'b0;
		for(int i = 0; i < 10; i++) begin
			@(posedge clk) rd = 1'b1;
		end
		@(posedge clk) rd = 1'b0;
		for(int i = 0; i < 5; i++) begin
			@(posedge clk) {wr, din} = {1'b1, 8'($random())};
		end
		@(posedge clk) wr = 1'b0;
		for(int i = 0; i < 5; i++) begin
			@(posedge clk) rd = 1'b1;
		end
		@(posedge clk) rd = 1'b0;
		for(int i = 0; i < 5; i++) begin
			@(posedge clk) {wr, din} = {1'b1, 8'($random())};
		end
		@(posedge clk) wr = 1'b0;
		for(int i = 0; i < 5; i++) begin
			@(posedge clk) rd = 1'b1;
		end
		@(posedge clk) rd = 1'b0;
		#10 $stop();
	end
	ScFifo2 #(8, 3) theFifo(clk, 1'b0, din, wr & ~fu, dout, rd & ~em, wc, rc, dc, fu, em);
endmodule

module ScFifo1 #(		// add rst in 20220315
	parameter DW = 8,
	parameter AW = 10
)(
	input wire clk, rst,
	input wire [DW - 1 : 0] din,
	input wire write,
	output logic [DW - 1 : 0] dout,
	input wire read,
	output logic [AW - 1 : 0] wr_cnt = '0, rd_cnt = '0,
    output logic [AW - 1 : 0] data_cnt,
	output logic full, empty
);
	localparam CAPACITY = 2**AW - 1;
	always_ff@(posedge clk) begin
		if(rst)        wr_cnt <= '0;
		else if(write) wr_cnt <= wr_cnt + 1'b1;
	end
	always_ff@(posedge clk) begin
		if(rst)       rd_cnt <= '0;
		else if(read) rd_cnt <= rd_cnt + 1'b1;
	end
	assign data_cnt = wr_cnt - rd_cnt;
	assign full = data_cnt == CAPACITY;
	assign empty = data_cnt == 0;
	SdpRamRf #(.DW(DW), .WORDS(2**AW)) theRam(
        .clk(clk), .addr_a(wr_cnt), .wr_a(write),
        .din_a(din), .addr_b(rd_cnt), .qout_b(dout)
	);
endmodule

module ScFifo2 #(		// add rst in 20220315
	parameter DW = 8,
	parameter AW = 10
)(
	input wire clk, rst,
	input wire [DW - 1 : 0] din,
	input wire write,
	output logic [DW - 1 : 0] dout,
	input wire read,
	output logic [AW - 1 : 0] wr_cnt = '0, rd_cnt = '0,
    output logic [AW - 1 : 0] data_cnt,
	output logic full, empty
);
	localparam CAPACITY = 2**AW - 1;
	always_ff@(posedge clk) begin
		if(rst)        wr_cnt <= 1'b0;
		else if(write) wr_cnt <= wr_cnt + 1'b1;
	end
	always_ff@(posedge clk) begin
		if(rst)       rd_cnt <= 1'b0;
		else if(read) rd_cnt <= rd_cnt + 1'b1;
	end
	assign data_cnt = wr_cnt - rd_cnt;
	assign full = data_cnt == CAPACITY;
	assign empty = data_cnt == 0;
	logic rd_dly;
	always_ff@(posedge clk) begin
		if(rst) rd_dly <= 1'b0;
		else    rd_dly <= read;
	end
	logic [DW - 1 : 0] qout_b, qout_b_reg = '0;
	always_ff@(posedge clk) begin
		if(rst)         qout_b_reg <= '0;
		else if(rd_dly) qout_b_reg <= qout_b;
	end
	SdpRamRf #(.DW(DW), .WORDS(2**AW)) theRam(
        .clk(clk), .addr_a(wr_cnt), .wr_a(write),
        .din_a(din), .addr_b(rd_cnt), .qout_b(qout_b)
	);
	assign dout = (rd_dly)? qout_b : qout_b_reg;
endmodule

module ScFifoSA #(	// output show-ahead(altera's term) or FWFT(xilinx's term)  // add rst in 20220315
	parameter DW = 8,
	parameter AW = 10
)(
	input wire clk, rst,
	input wire [DW - 1 : 0] din,
	input wire write,
	output logic [DW - 1 : 0] dout,
	input wire read,
	output logic [AW - 1 : 0] wr_cnt = '0, rd_cnt = '0,
    output logic [AW - 1 : 0] data_cnt,
	output logic full, empty
);
	localparam CAPACITY = 2**AW - 1;
	always_ff@(posedge clk) begin
		if(rst)        wr_cnt <= '0;
		else if(write) wr_cnt <= wr_cnt + 1'b1;
	end
	always_ff@(posedge clk) begin
		if(rst)       rd_cnt <= '0;
		else if(read) rd_cnt <= rd_cnt + 1'b1;
	end
	assign data_cnt = wr_cnt - rd_cnt;
	assign full = data_cnt == CAPACITY;
	assign empty = data_cnt == 0;
	SdpRamRa #(.DW(DW), .WORDS(2**AW)) theRam(
        .clk(clk), .addr_a(wr_cnt), .wr_a(write),
        .din_a(din), .addr_b(rd_cnt), .qout_b(dout)
	);
endmodule

`endif
