`ifndef __DELAY_CHAIN_MEM_SV__
`define __DELAY_CHAIN_MEM_SV__

`include "../common.sv"
`include "./memory.sv"

`timescale 1ns/1ps
`default_nettype none

module DelayChainMem #(     // add rst in 20220315
    parameter DW = 8,
    parameter LEN = 32
)(
    input wire clk, rst, en,
    input wire [DW - 1 : 0] din,
    output logic [DW - 1 : 0] dout
);
    generate
        if(LEN == 0) begin
            assign dout = din;
        end
        else if(LEN == 1) begin
            always_ff@(posedge clk) begin
                if(rst)     dout <= '0;
                else if(en) dout <= din;
            end
        end
        else begin
            logic [$clog2(LEN) - 1 : 0] addr = '0;
            SpRamRf #(DW, LEN) theRam(
                .clk(clk), .addr(addr), .we(en), .din(din), .qout(dout)
            );
            always_ff@(posedge clk) begin
                if(rst) addr <= '0;
                else if(en) begin
                    if(addr < LEN - 2) addr <= addr + 1'b1;
                    else addr <= '0;
                end
            end
        end
    endgenerate
endmodule

// improved output behavior (just like scfifo2)
module DelayChainMem2 #(     // add rst in 20220315
    parameter DW  = 8,
    parameter LEN = 32
)(
    input  wire clk, rst, en,
    input  wire  [DW - 1 : 0] din,
    output logic [DW - 1 : 0] dout
);
    generate
        if(LEN == 0) begin
            assign dout = din;
        end
        else if(LEN == 1) begin
            always_ff@(posedge clk) begin
                if(rst)     dout <= '0;
                else if(en) dout <= din;
            end
        end
        else begin
            logic en_dly;
            logic [DW-1:0] ram_out, ram_out_dly = '0;
            assign dout = en_dly ? ram_out : ram_out_dly;
            logic [$clog2(LEN) - 1 : 0] addr = '0;
            SpRamRf #(DW, LEN) theRam(
                .clk(clk), .addr(addr), .we(en), .din(din), .qout(ram_out)
            );
            always_ff@(posedge clk) begin
                if(rst) addr <= '0;
                else if(en) begin
                    if(addr < LEN - 2) addr <= addr + 1'b1;
                    else addr <= '0;
                end
            end
            always_ff@(posedge clk) begin
                if(rst)         ram_out_dly <= '0;
                else if(en_dly) ram_out_dly <= ram_out;
            end
            always_ff@(posedge clk) begin
                if(rst) en_dly <= 1'b0; 
                else    en_dly <= en;
            end
        end
    endgenerate
endmodule

module TestDelayChainMem;
    import SimSrcGen::*;
    logic [7:0] a, y;
    logic clk, en = 0;
    initial GenClk(clk, 2, 10);
    initial begin
        #10 en = '1;
        #120 en = '0;
        #20 en = '1;
    end
    always #10 a = $random();
    DelayChainMem #(8, 0) dc(clk, 1'b0, en, a, y);
endmodule

`endif
