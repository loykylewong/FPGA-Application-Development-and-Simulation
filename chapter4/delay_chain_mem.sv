`ifndef __DELAY_CHAIN_MEM_SV__
`define __DELAY_CHAIN_MEM_SV__

`timescale 1ns/1ps
`default_nettype none
`include "../common.sv"

module DelayChainMem #(
    parameter DW = 8,
    parameter LEN = 32
)(
    input wire clk, en,
    input wire [DW - 1 : 0] din,
    output logic [DW - 1 : 0] dout
);
    generate
        if(LEN == 0) begin
            assign dout = din;
        end
        else if(LEN == 1) begin
            always_ff@(posedge clk) begin
                if(en) dout <= din;
            end
        end
        else begin
            logic [$clog2(LEN) - 1 : 0] addr = '0;
            SpRamRf #(DW, LEN) theRam(
                .clk(clk), .addr(addr), .we(en), .din(din), .qout(dout)
            );
            always_ff@(posedge clk) begin
                if(en) begin
                    if(addr < LEN - 2) addr <= addr + 1'b1;
                    else addr <= '0;
                end
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
    DelayChainMem #(8, 0) dc(clk, en, a, y);
endmodule

`endif
