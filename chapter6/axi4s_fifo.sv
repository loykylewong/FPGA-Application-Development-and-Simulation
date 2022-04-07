`ifndef __AXI4S_FIFO_SV__
`define __AXI4S_FIFO_SV__

`include "../common.sv"
`include "../chapter4/scfifo.sv"

`timescale 1ns/100ps
`default_nettype none

module TestAxi4StreamFifo;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 2, 2);
    Axi4StreamIf us(clk, ~rst), ds(clk, ~rst);
    Axi4sFifo theAxi4sFifo(us.sink, ds.source);
    int seed0 = 123, seed1 = 432;
    logic [31:0] updata = '0;
    initial begin
        us.tvalid = '0;
        repeat(10) @(posedge clk);
        repeat(1000) begin
            repeat($dist_poisson(seed0, 2)) @(posedge clk);
            us.Put(updata++, 1'b0);
        end
        repeat(10) @(posedge clk);
        $stop();
    end
    logic [31:0] downdata;
    initial begin
        ds.tready = '0;
        repeat(10) @(posedge clk);
        repeat(1000) begin
            repeat($dist_poisson(seed1, 2)) @(posedge clk);
            ds.Get();
			downdata <= ds.tdata;
        end
    end
    always_ff@(posedge clk) begin
        if(ds.tready & ds.tvalid & ds.tdata != downdata + 1)
            $display("data error.");
    end
endmodule

interface Axi4StreamIf #(
    parameter DW_BYTES = 4, IDW = 8, DESTW = 4, USERW = 8
)(
    input wire clk, reset_n
);
    localparam DW = DW_BYTES * 8;
    logic [DW - 1 : 0] tdata;
    logic tvalid = '0, tready, tlast;
    logic [DW_BYTES - 1 : 0] tstrb, tkeep;
    logic [IDW - 1 : 0] tid;
    logic [DESTW - 1 : 0] tdest;
    logic [USERW - 1 : 0] tuser;
    modport source(
        input   clk, reset_n, tready,
        output  tdata, tvalid, tlast, tstrb, tkeep,
                tid, tdest, tuser
    );
    modport sink(
        input   clk, reset_n, tdata, tvalid, tlast,
                tstrb, tkeep, tid, tdest, tuser,
        output  tready
    );
    task static Put(logic [DW - 1 : 0] data, logic last);
    begin
        tdata <= data; tlast <= last;
        tvalid <= '1;
        do @(posedge clk);
        while(~tready);
        tvalid <= '0;
    end
    endtask
    task static Get();
    begin
        tready <= '1;
        do @(posedge clk);
        while(~tvalid);
        tready <= '0;
    end
    endtask
endinterface

module Axi4sFifo (
    Axi4StreamIf.sink snk,
    Axi4StreamIf.source src
);
    logic full, empty;
    always_comb snk.tready = ~full;
    wire wr = snk.tready & snk.tvalid;
    wire rd = ~empty & (~src.tvalid | src.tvalid & src.tready);
    ScFifo2 #(33, 3) theFifo(
        snk.clk, ~snk.reset_n, {snk.tdata, snk.tlast}, wr, {src.tdata, src.tlast}, rd,
        , , , full, empty);
    always_ff@(posedge src.clk) begin
        if(~src.reset_n) src.tvalid <= '0;
        else if(rd) src.tvalid <= '1;
        else if(src.tready) src.tvalid <= 0;
    end
endmodule

module Axi4sFifo2 ( // use show-ahead fifo, simple but maybe lower fmax
    Axi4StreamIf.sink snk,
    Axi4StreamIf.source src
);
    logic full, empty;
    always_comb snk.tready = ~full;
    always_comb src.tvalid = ~empty;
    wire wr = snk.tready & snk.tvalid;
    wire rd = src.tvalid & src.tready;
    ScFifoSA #(33, 3) theFifo(
        snk.clk, ~snk.reset_n, {snk.tdata, snk.tlast}, wr, {src.tdata, src.tlast}, rd,
        , , , full, empty);
endmodule

`endif
