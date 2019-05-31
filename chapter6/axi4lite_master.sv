`include "../chapter4/counter.sv"

`default_nettype none
`timescale 1ns/100ps

module Axi4LiteMasterEg (
    Axi4LiteIf.master m,
    input wire start
);
    localparam [31:0] START_ADDR = 0;
    localparam LEN = 8;
    logic [7:0] acnt;
    logic acnt_co;
    CounterMax #(8) addrCnt(m.clk,
        ~m.reset_n | start, m.bvalid & m.bready, 8'd7, acnt, acnt_co);
    // ==== ar channel ====
    assign m.araddr = (acnt + START_ADDR) << 2;
    assign m.arprot = 3'b0;
    always_ff@(posedge m.clk) begin
        if(~m.reset_n) m.arvalid <= '0;
        else if(start | (m.bvalid & m.bready & ~acnt_co)) m.arvalid <= '1;
        else if(m.arvalid & m.arready) m.arvalid <= '0;
    end
    // ==== r channel ====
    assign m.rready = '1;
    logic signed [31:0] data;
    always_ff@(posedge m.clk) begin
        if(~m.reset_n) data <= '0;
        else if(m.rvalid) data <= m.rdata;
    end
    // ==== aw channel ====
    assign m.awaddr = (acnt + START_ADDR) << 2;
    assign m.awprot = 3'b0;
    always_ff@(posedge m.clk) begin
        if(~m.reset_n) m.awvalid <= '0;
        else if(m.rvalid) m.awvalid <= '1;
        else if(m.awvalid & m.awready) m.awvalid <= '0;
    end
    // ==== w channel ====
    assign m.wdata = -data;
    assign m.wstrb = 4'b1111;
    always_ff@(posedge m.clk) begin
        if(~m.reset_n) m.wvalid <= '0;
        else if(m.rvalid) m.wvalid <= '1;
        else if(m.wvalid & m.wready) m.wvalid <= '0;
    end
    // ==== b channel ====
    assign m.bready = '1;
endmodule
