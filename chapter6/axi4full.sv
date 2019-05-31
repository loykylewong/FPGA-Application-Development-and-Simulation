`include "../common.sv"
`default_nettype none
`timescale 1ns/100ps

module TestBurstAddrGen;
    import SimSrcGen::*;
    localparam [1:0] B_FIXED = 0, B_INCR = 1, B_WRAP = 2;
    logic clk, rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 2, 2);
    logic start, inc;
    logic [31:0] addr;
    logic [7:0] xlen;
    logic [2:0] size;
    logic [1:0] burst;
    logic [31:0] a;
    logic [3:0] be;
    logic last;
    Axi4BurstAddrGen bg(clk, rst, start, inc, addr, xlen, size, burst, a, be, last);
    initial begin
        repeat(10) @(posedge clk);
        @(posedge clk) begin
            addr = 7; xlen = 127; size = 0; burst = B_FIXED;
            start = '1; inc = '1;
        end
        @(posedge clk) start = '0;
        repeat(200) @(posedge clk);
        
        @(posedge clk) begin
            addr = 7; xlen = 127; size = 1; burst = B_FIXED;
            start = '1; inc = '1;
        end
        @(posedge clk) start = '0;
        repeat(200) @(posedge clk);
        
        @(posedge clk) begin
            addr = 7; xlen = 127; size = 2; burst = B_FIXED;
            start = '1; inc = '1;
        end
        @(posedge clk) start = '0;
        repeat(200) @(posedge clk);
        
        ///////////////////////////////
        repeat(10) @(posedge clk);
        @(posedge clk) begin
            addr = 4003; xlen = 127; size = 0; burst = B_INCR;
            start = '1; inc = '1;
        end
        @(posedge clk) start = '0;
        repeat(200) @(posedge clk);
        
        @(posedge clk) begin
            addr = 4003; xlen = 127; size = 1; burst = B_INCR;
            start = '1; inc = '1;
        end
        @(posedge clk) start = '0;
        repeat(200) @(posedge clk);
        
        @(posedge clk) begin
            addr = 4003; xlen = 127; size = 2; burst = B_INCR;
            start = '1; inc = '1;
        end
        @(posedge clk) start = '0;
        repeat(200) @(posedge clk);
        
        ///////////////////////////////
        repeat(10) @(posedge clk);
        @(posedge clk) begin
            addr = 4007; xlen = 15; size = 0; burst = B_WRAP;
            start = '1; inc = '1;
        end
        @(posedge clk) start = '0;
        repeat(200) @(posedge clk);
        
        @(posedge clk) begin
            addr = 4007; xlen = 15; size = 1; burst = B_WRAP;
            start = '1; inc = '1;
        end
        @(posedge clk) start = '0;
        repeat(200) @(posedge clk);
        
        @(posedge clk) begin
            addr = 4007; xlen = 15; size = 2; burst = B_WRAP;
            start = '1; inc = '1;
        end
        @(posedge clk) start = '0;
        repeat(200) @(posedge clk);
        @(posedge clk) $stop();
    end
endmodule

module Axi4BurstAddrGen(
    input wire clk, rst,
    input wire start, // awvalid & awready | arvalid & arready
    input wire inc,   // wvalid & wready | rvalid & rready
    input wire [31:0] addr,
    input wire [7:0] xlen,
    input wire [2:0] size,  // NB = 2**size
    input wire [1:0] burst,
    output logic [31:0] aout,
    output logic [3:0] strb,
    output logic last
); 
    localparam [1:0] B_FIXED = 0, B_INCR = 1, B_WRAP = 2;
    logic [31:0] a, a_nxt, al, a4kl;
    logic [2:0] nb; // 1~4, = 1 << size
    logic [6:0] wl; // for wrap, = nb * len = (1 + xlen) << size
    logic [1:0] b;  // burst
    logic [7:0] inc_cnt, inc_max;
    logic [3:0] strb0; 
    always_ff@(posedge clk) begin
        if(rst) inc_cnt <= 8'd0;
        else if(start) begin
            inc_cnt <= 8'd0; inc_max <= xlen;
        end
        else if(inc) begin
            if(inc_cnt < inc_max) inc_cnt <= inc_cnt + 8'd1;
        end
    end
    assign last = inc_cnt == inc_max;
    always_ff@(posedge clk) begin
        if(rst) a <= 32'b0;
        else if(start) begin
            // floor(a/nb)*nb
            a <= addr & ~((32'b1 << size) - 32'b1);
            // 2^(rem(addr,4) + nb) - 2^rem(addr,4)
//            strb0 <= (8'b1 << (addr[1:0]+nb)) - (4'b1 << addr[1:0]);
            strb0 <= ((5'b1 << (3'b1 << size)) - 5'b1) << addr[1:0];
            // floor(a/(nb*len))*(nb*len)
            al <= addr & ~(((32'b1 + xlen) << size) - 32'b1);
            a4kl <= addr & ~32'd4095;
            nb <= 3'b1 << size;
            wl <= (32'b1 + xlen) << size;
            b <= burst;
        end
        else if(inc & ~last) a <= a_nxt;
    end
    always_comb begin
        case(b)
        B_FIXED: a_nxt = a;
        B_INCR: begin
            if(a == a4kl + 32'd4096 - nb) a_nxt = a4kl;
            else a_nxt = a + nb;
        end
        B_WRAP: begin
            if(a == al + wl - nb) a_nxt = al;
            else a_nxt = a + nb;
        end
        default: a_nxt = a;
        endcase
    end
    assign aout = a;
    assign strb = inc_cnt == 8'd0 ? strb0 :
//                  (5'b1 << (a[1:0] + nb)) - (4'b1 << a[1:0]);
                  ((5'b1 << nb) - 5'b1) << a[1:0];
endmodule
