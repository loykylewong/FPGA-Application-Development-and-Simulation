`include "../common.sv"
`include "../chapter4/memory.sv"

`default_nettype none
`timescale 1ns/100ps

module TestAxi4Lite;
    import SimSrcGen::*;
    logic clk;
    logic rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 2, 2);
    Axi4LiteIf #(5) theIf(clk, ~rst);
    logic start = '0;
    Axi4LiteMasterEg theMas(theIf, start);
    logic [31:0] regs[8];
    Axi4LiteSlave #(8) theSla(theIf, regs);
    initial begin
        wait(rst); wait(~rst);
        theSla.regs = '{123, -2334, 48327342, -218377853, 232889, 33612, -812, -456783321};
    end
    initial begin
        repeat(10) @(posedge clk);
        start = '1;
        @(posedge clk) start = '0;
        repeat(100) @(posedge clk);
        $stop();
    end
endmodule
