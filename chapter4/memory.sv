`ifndef __MEMORY_SV__
`define __MEMORY_SV__

`timescale 1ns/1ps
`default_nettype none
`include "../common.sv"

module TestMem;
    import SimSrcGen::*;
    logic clk;
    initial GenClk(clk, 2, 10);
    logic [7:0] a = 0, d = 0, q;
    logic we = 0;
    initial begin
        #10 {we, a, d} = {1'b1, 8'h01, 8'h10};
        #10 {we, a, d} = {1'b1, 8'h03, 8'h30};
        #10 {we, a, d} = {1'b1, 8'h06, 8'h60};
        #10 {we, a, d} = {1'b1, 8'h0a, 8'ha0};
        #10 {we, a, d} = {1'b1, 8'h0f, 8'hf0};
        #10 {we, a, d} = {1'b0, 8'h00, 8'h00};
        forever #10 a++;
    end
    SpRamRfSine theMem(clk, a, we, d, q);
endmodule

module SpRamRf #(
    parameter DW = 8, WORDS = 256
)(
    input wire clk,
    input wire [$clog2(WORDS) - 1 : 0] addr,
    input wire we,
    input wire [DW - 1 : 0] din,
    output logic [DW - 1 : 0] qout
);
    logic [DW - 1 : 0] ram[WORDS] = '{WORDS{DW'(0)}};
    always_ff@(posedge clk) begin
        if(we) ram[addr] <= din;
        qout <= ram[addr];
    end
endmodule

module SpRamRa #(   // asynchronous read
    parameter DW = 8, WORDS = 256
)(
    input wire clk,
    input wire [$clog2(WORDS) - 1 : 0] addr,
    input wire we,
    input wire [DW - 1 : 0] din,
    output logic [DW - 1 : 0] qout
);
    logic [DW - 1 : 0] ram[WORDS];
    always_ff@(posedge clk) begin
        if(we) ram[addr] <= din;
    end
    assign qout = ram[addr];
endmodule

module SpRamWf #(
    parameter DW = 8, WORDS = 256
)(
    input wire clk,
    input wire [$clog2(WORDS) - 1 : 0] addr,
    input wire we,
    input wire [DW - 1 : 0] din,
    output logic [DW - 1 : 0] qout
);
    logic [DW - 1 : 0] ram[WORDS];
    always_ff@(posedge clk) begin
        if(we) begin
            ram[addr] <= din;
            qout <= din;
        end
        else qout <= ram[addr];
    end
endmodule

module SdpRamRf #(
    parameter DW = 8, WORDS = 256
)(
    input wire clk,
    input wire [$clog2(WORDS) - 1 : 0] addr_a,
    input wire wr_a,
    input wire [DW - 1 : 0] din_a,
    input wire [$clog2(WORDS) - 1 : 0] addr_b,
    output logic [DW - 1 : 0] qout_b
);
    logic [DW - 1 : 0] ram[WORDS];
    always_ff@(posedge clk) begin
        if(wr_a) begin
            ram[addr_a] <= din_a;
        end
    end
    always_ff@(posedge clk) begin
        qout_b <= ram[addr_b];
    end
endmodule

module SdpRamRa #(
    parameter DW = 8, WORDS = 256
)(
    input wire clk,
    input wire [$clog2(WORDS) - 1 : 0] addr_a,
    input wire wr_a,
    input wire [DW - 1 : 0] din_a,
    input wire [$clog2(WORDS) - 1 : 0] addr_b,
    output logic [DW - 1 : 0] qout_b
);
    logic [DW - 1 : 0] ram[WORDS];
    always_ff@(posedge clk) begin
        if(wr_a) begin
            ram[addr_a] <= din_a;
        end
    end
    assign qout_b = ram[addr_b];
endmodule

module DpRam #(
    parameter DW = 8, WORDS = 256
)(
    input wire clk,
    input wire [$clog2(WORDS) - 1 : 0] addr_a,
    input wire wr_a,
    input wire [DW - 1 : 0] din_a,
    output logic [DW - 1 : 0] qout_a,
    input wire [$clog2(WORDS) - 1 : 0] addr_b,
    input wire wr_b,
    input wire [DW - 1 : 0] din_b,
    output logic [DW - 1 : 0] qout_b
);
    logic [DW - 1 : 0] ram[WORDS];
    always_ff@(posedge clk) begin
        if(wr_a) begin
            ram[addr_a] <= din_a;
            qout_a <= din_a;
        end
        else qout_a <= ram[addr_a];
    end
    always_ff@(posedge clk) begin
        if(wr_b) begin
            ram[addr_b] <= din_b;
            qout_b <= din_b;
        end
        else qout_b <= ram[addr_b];
    end
endmodule

module SdcRam #(
    parameter DW = 8, WORDS = 256
)(
    input wire clk_a,
    input wire [$clog2(WORDS) - 1 : 0] addr_a,
    input wire wr_a,
    input wire [DW - 1 : 0] din_a,
    input wire clk_b,
    input wire [$clog2(WORDS) - 1 : 0] addr_b,
    output logic [DW - 1 : 0] qout_b
);
    logic [DW - 1 : 0] ram[WORDS];
    always_ff@(posedge clk_a) begin
        if(wr_a) ram[addr_a] <= din_a;
    end
    always_ff@(posedge clk_b) begin
        qout_b <= ram[addr_b];
    end
endmodule

module DcRam #(
    parameter DW = 8, WORDS = 256
)(
    input wire clk_a,
    input wire [$clog2(WORDS) - 1 : 0] addr_a,
    input wire wr_a,
    input wire [DW - 1 : 0] din_a,
    output logic [DW - 1 : 0] qout_a,
    input wire clk_b,
    input wire [$clog2(WORDS) - 1 : 0] addr_b,
    input wire wr_b,
    input wire [DW - 1 : 0] din_b,
    output logic [DW - 1 : 0] qout_b
);
    logic [DW - 1 : 0] ram[WORDS];
    always_ff@(posedge clk_a) begin
        if(wr_a) ram[addr_a] <= din_a;
        qout_a <= ram[addr_a];
    end
    always_ff@(posedge clk_b) begin
        if(wr_b) ram[addr_b] <= din_b;
        qout_b <= ram[addr_b];
    end
endmodule

module SpRamRfSine #(
    parameter DW = 8, WORDS = 256
//    parameter string INIT_FILE = "sindata8b256.dat"
)(
    input wire clk,
    input wire [$clog2(WORDS) - 1 : 0] addr,
    input wire we,
    input wire signed [DW - 1 : 0] din,
    output logic signed [DW - 1 : 0] qout
);
    logic signed [DW - 1 : 0] ram[WORDS];

    localparam real PI = 3.1415926535897932;
    initial begin
        for(int i = 0; i < WORDS; i++) begin
            ram[i] = $sin(2.0 * PI * i / WORDS) * (2**(DW - 1) - 1);
        end
//        $readmemh(INIT_FILE, ram);
    end
    always@(posedge clk) begin
        if(we) ram[addr] <= din;
        qout <= ram[addr];
    end
endmodule

`default_nettype wire
`endif
