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

// delay chain with dynamic length
// when lenght change, after new length latched by clock,
// the dout data of the new length quantity will be unreliable.
module DelayChainMem3 #(
    parameter DW      =  8,
    parameter MAX_LEN = 32,
    parameter MIN_LEN =  2
)(
    input  wire  clk, rst, en,
    input  wire  [$clog2(MAX_LEN+1)-1 : 0] length,
    input  wire  [DW - 1              : 0] din   ,
    output logic [DW - 1              : 0] dout
);
    logic en_dly;
    logic [DW-1:0] din_dly, ram_out, ram_out_dly = '0;
    generate
        if(MIN_LEN > 1)
            assign dout = en_dly        ? ram_out : ram_out_dly;
        else if(MIN_LEN > 0)
            assign dout = length == 'd1 ? din_dly :
                          en_dly        ? ram_out : ram_out_dly;
        else
            assign dout = length == 'd0 ? din     :
                          length == 'd1 ? din_dly :
                          en_dly        ? ram_out : ram_out_dly;
    endgenerate
    logic [$clog2(MAX_LEN)-1 : 0] addr = '0;
    SpRamRf #(DW, MAX_LEN) theRam(
        .clk(clk), .addr(addr), .we(en), .din(din), .qout(ram_out)
    );
    always_ff@(posedge clk) begin
        if(rst) addr <= '0;
        else if(en) begin
            if(addr < length - 2'd2) addr <= addr + 1'b1;
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
    always_ff@(posedge clk) begin
        if(rst)     din_dly <= '0;
        else if(en) din_dly <= din;
    end
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

module TestDelayChainMem3;
    import SimSrcGen::*;
    logic [7:0] a, y;
    logic clk, en = 0;
    int seed_en = 321384;
    int seed_len = 8734;
    int en_cnt = 0;
    int len = 0;
    initial GenClk(clk, 2ns, 10ns);
    initial begin
        #20;
        @(posedge clk);
        forever begin
            repeat($dist_poisson(seed_en, 2)) @(posedge clk);
            @(posedge clk) en <= 1'b1;
            // @(posedge clk) en <= ~en;
        end
    end
    initial begin
        #20;
        @(posedge clk);
        forever begin
            repeat($dist_poisson(seed_len, 64)) @(posedge clk);
            @(posedge clk) len <= $random() & 4'hf;
        end
    end
    always @(posedge clk) begin
        if(en) begin
            en_cnt <= en_cnt + 1'b1;
        end
    end
    always@(posedge clk) begin
        if(en) begin
            a <= $random();
        end
    end
    DelayChainMem3 #(8, 16, 0) dc(clk, 1'b0, en, len, a, y);
endmodule

`endif
