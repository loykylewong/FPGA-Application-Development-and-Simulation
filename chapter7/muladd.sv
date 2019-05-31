`include "../common.sv"
`include "../chapter6/axi4_fifo.sv"

`timescale 1ns/100ps
`default_nettype none

module TestCplx16MulAdd;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 2, 2);
    Axi4StreamIf us(clk, ~rst), ds(clk, ~rst);
    Cplx16MulAdd theCMA(us.sink, ds.source);
//    let q15(x) = 16'(integer'(x * 32768));
    `DEF_REAL_TO_Q(q15, 1, 15);
    `DEF_Q_TO_REAL(r15, 1, 15);
    real re = 0, im = 0;
    initial begin
        us.Put((15 <<< 4) | 3'b000, 1'b1);//cplx normal mul, Q1.15
        us.Put({ q15(0.5) , q15( 0.5) }); // 0.5+0.5i
        us.Put({ q15(0.3) , q15(-0.7) }); // 0.3-0.7i
        us.Get();
        re = r15(us.tdata[0+:16]); im = r15(us.tdata[16+:16]);
        us.Put((15 <<< 4) | 3'b001, 1'b1);//real normal mul, Q1.15
        us.Put({ q15(0.5) , q15( 0.5) }); // 0.5,  0.5
        us.Put({ q15(0.3) , q15(-0.7) }); // 0.3, -0.7
        us.Get();
        re = r15(us.tdata[0+:16]); im = r15(us.tdata[16+:16]);
        
    end

    
endmodule

module Cplx16MulAdd (
    Axi4StreamIf.sink snk,
    Axi4StreamIf.source src
);
    // mode[0] 0: complex mul; 1: 2 ch seprate mul
    // mode[1] 0: normal mode; 1: conjugate 1st arg mode
    // mode[2] 0: mul mode;    1: mul-add mode(a0*b0+a1*b1+...)
    logic [3:0] mode, fw;
    wire clk = snk.clk;
    wire rst = ~snk.reset_n;
    assign snk.tready = 1'b1;
    // fw & mode
    always_ff@(posedge clk) begin
        if(rst) begin mode <= 4'b0; fw <= 4'd15;
        end
        else begin
            if(snk.tvalid & snk.tlast) begin
                mode <= snk.tdata[3:0];
                fw <= snk.tdata[7:4];
            end
        end
    end
    // register data input
    logic signed [15:0] rr, ri;
    wire signed [15:0] ir = snk.tdata[15:0];
    wire signed [15:0] ii = snk.tdata[31:16];
    always_ff@(posedge clk) begin
        if(rst) begin rr <= 16'sd0; ri <= 16'sd0;
        end
        else if(snk.tvalid) begin
            if(snk.tlast) begin
                rr <= 16'sd0; ri <= 16'sd0;
            end
            else begin
                rr <= ir; ri <= mode[1]? -ii : ii;
            end
        end
    end
    // product
    logic signed [31:0] mr, mi;
    always_ff@(posedge clk) begin
        if(rst) begin
            mr <= 32'sd0; mi <= 32'sd0;
        end
        else if(snk.tvalid) begin
            if(snk.tlast) begin
                mr <= 32'sd0; mi <= 32'sd0;
            end
            else begin
                mr <= mode[0]?
                    (32'(rr) * ir) >>> fw :
                    (32'(rr) * ir - 32'(ri) * ii) >>> fw;
                mi <= mode[0]?    
                    (32'(ri) * ii) >>> fw :
                    (32'(rr) * ii + 32'(ri) * ir) >>> fw;
            end
        end
    end
    // control accumulation
    logic cnt;
    always_ff@(posedge clk) begin
        if(rst) cnt <= 1'b0;
        else if(snk.tvalid) begin
            if(snk.tlast) cnt <= 1'b0;
            else cnt <= ~cnt;
        end
    end
    logic acc;
    always_ff@(posedge clk) begin
        if(rst) acc <= 1'b0;
        else acc <= snk.tvalid & ~snk.tlast & cnt;
    end
    // sum
    logic signed [31:0] sr, si;
    always_ff@(posedge clk) begin
        if(rst) begin
            sr <= 32'sd0; si <= 32'sd0;
        end
        else if(snk.tvalid & snk.tlast) begin
            sr <= 32'sd0; si <= 32'sd0;
        end
        else if(acc) begin
            sr <= sr + mr; si <= si + mi;
        end
    end
    wire signed [31:0] r = mode[2]? sr : mr;
    wire signed [31:0] i = mode[2]? si : mi;
    always_comb src.tdata[15:0] =
            (r >= 32'sd32768)? 16'sd32767 :
            (r <= -32'sd32768)? -16'sd32767 : r[15:0];
    always_comb src.tdata[31:16] =
            (i >= 32'sd32768)? 16'sd32767 :
            (i <= -32'sd32768)? -16'sd32767 : i[15:0];
    always_comb src.tvalid = mode[2] ? ~acc : 1'b1;
    always_comb src.tlast = 1'b0;
endmodule
