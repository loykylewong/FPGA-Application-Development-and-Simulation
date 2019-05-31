`ifndef __EDEG2EN_SV__
`define __EDEG2EN_SV__

`include "../common.sv"

`timescale 1ns/1ps
`default_nettype none
module TestEdge2En;
    import SimSrcGen::*;
    logic clk;
    initial GenClk(clk, 2, 10);
    logic in;
    initial begin
        in = 0;
        #44 in = 1;
        #56 in = 0;
    end
    logic en0, en1, en2;
    Rising2En #(0) theR2E0(clk, in, en0, );
    Rising2En theR2E1(clk, in, en1, );
    Rising2En #(2) theR2E2(clk, in, en2, );
endmodule

module Rising2En #( parameter SYNC_STG = 1 )(
    input wire clk, in,
    output logic en, out
);
    logic [SYNC_STG : 0] dly;
    always_ff@(posedge clk) begin
        dly <= {dly[SYNC_STG - 1 : 0], in};    
    end
    assign en = (SYNC_STG ? dly[SYNC_STG -: 2] : {dly, in}) == 2'b01;
    assign out = dly[SYNC_STG];
endmodule

module Falling2En #( parameter SYNC_STG = 1 )(
    input wire clk, in,
    output logic en, out
);
    logic [SYNC_STG : 0] dly;
    always_ff@(posedge clk) begin
        dly <= {dly[SYNC_STG - 1 : 0], in};    
    end
    assign en = (SYNC_STG ? dly[SYNC_STG -: 2] : {dly, in}) == 2'b10;
    assign out = dly[SYNC_STG];
endmodule

module Edge2En #( parameter SYNC_STG = 1 )(
    input wire clk, in,
    output logic rising, falling, out
);
    logic [SYNC_STG : 0] dly;
    always_ff@(posedge clk) begin
        dly <= {dly[SYNC_STG - 1 : 0], in};    
    end
    assign rising = (SYNC_STG ? dly[SYNC_STG -: 2] : {dly, in}) == 2'b01;
    assign falling = (SYNC_STG ? dly[SYNC_STG -: 2] : {dly, in}) == 2'b10;
    assign out = dly[SYNC_STG];
endmodule

`endif
