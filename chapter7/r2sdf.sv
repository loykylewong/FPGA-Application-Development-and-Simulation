`include "../common.sv"
`include "../chapter4/delay_chain_mem.sv"
`include "../chapter4/delay_chain.sv"

`timescale 1ns/100ps
`default_nettype none

module TestR2Sdf;
    import SimSrcGen::*;
    import R2SdfDefines::*;
    localparam STG = 4, LEN = 2**STG;
    logic clk, rst;
    initial GenClk(clk, 8000, 10000);
    initial GenRst(clk, rst, 2, 2);
    Cplx x[LEN]; 
    initial begin
        for(int n = 0; n < LEN; n++) begin
            x[n].re = n < 2 * LEN / 4 ? 16'sd10000 : -16'sd10000;
            x[n].im = 16'sd0;
        end
    end
    logic [STG - 1 : 0] cnt = '0;
    logic sc = '1, inv = '0, osync;
    Cplx out;
    wire isync = cnt == '1;
    R2Sdf #(STG) theR2Sdf(clk, rst, 1'b1, sc, inv, x[cnt], isync, out, osync);
    always@(posedge clk) begin
        if(rst) cnt <= '0;
        else cnt <= cnt + 1'b1;
    end
    logic [STG - 1 : 0] dicnt = '0;
    always@(posedge clk) begin
        if(osync) dicnt <= '0;
        else dicnt <= dicnt + 1'b1;
    end
    wire [STG - 1 : 0] dataIdx = {<<{dicnt}};
endmodule

package R2SdfDefines;
    localparam DW = 16, FW = DW - 1;
    typedef struct {
        logic signed [DW-1:0] re;
        logic signed [DW-1:0] im;
    } Cplx;
    function automatic Cplx cmul(Cplx a, Cplx b);
        cmul.re = ( (DW*2)'(a.re) * b.re - (DW*2)'(a.im) * b.im ) >>> FW;
        cmul.im = ( (DW*2)'(a.re) * b.im + (DW*2)'(a.im) * b.re ) >>> FW;
    endfunction
    function automatic Cplx cadd(Cplx a, Cplx b, logic sc);
        cadd.re = ( (DW+1)'(a.re) + b.re ) >>> sc;
        cadd.im = ( (DW+1)'(a.im) + b.im ) >>> sc;
    endfunction
    function automatic Cplx csub(Cplx a, Cplx b, logic sc);
        csub.re = ( (DW+1)'(a.re) - b.re ) >>> sc;
        csub.im = ( (DW+1)'(a.im) - b.im ) >>> sc;
    endfunction
endpackage

module Bf2 import R2SdfDefines::*; (
    input Cplx x0, x1,
    output Cplx z0, z1,
    input wire s, scale
);
    always_comb z0 = ~s ? x0 : cadd(x0, x1, scale);
    always_comb z1 = ~s ? x1 : csub(x0, x1, scale);
endmodule

module R2SdfCoefRom #( parameter DW = 16, AW = 8, RI = "Real" )(
    input wire clk,
    input wire [AW-1:0] addr,
    output logic signed [DW-1:0] qout
);
    logic signed [DW-1:0] ram[0 : 2**AW - 1];
    initial begin
        for(int k = 0; k < 2**AW; k++) begin
            if(RI == "Real")
                ram[k] = $cos(3.1415926536 * k / 2**AW) * (2**(DW-1) - 1);
            else
                ram[k] = $sin(3.1415926536 * k / 2**AW) * (2**(DW-1) - 1);
        end
    end
    always_ff@(posedge clk) qout <= ram[addr];
endmodule

module R2Sdf import R2SdfDefines::*; #( STG = 4 )(
    input wire clk, rst, en, scale, invexp,
    input Cplx in, input wire in_sync,
    output Cplx out, output logic out_sync
);
    Cplx  bf2_x0[STG],  bf2_x1[STG],  bf2_z0[STG],  bf2_z1[STG];
    assign bf2_x1[STG - 1] = in;
    always_ff@(posedge clk) begin
        if(rst) out <= '{'0, '0};
        else if(en) out <= bf2_z0[0];
    end
    logic [STG - 1 : 0] ccnt;
    always_ff@(posedge clk) begin
        if(rst) ccnt <= 'b0;
        else if(en) begin
            if(in_sync) ccnt <= 'b0;
            else ccnt <= ccnt + 1'b1;
        end
    end
    always_ff@(posedge clk) begin
        if(rst) out_sync <= '0;
        else if(en) out_sync <= ccnt == STG'(STG*2-4);
    end
    generate
        for(genvar s = STG - 1; s >= 0; s--) begin : bfStg
            logic s_dly;
            DelayChain #(1, 2*(STG-s-1)) dlyCnt(
                clk, rst, en, ccnt[s], s_dly);
            Bf2 theBf2 (
                .x0(bf2_x0[s]), .x1(bf2_x1[s]),
                .z0(bf2_z0[s]), .z1(bf2_z1[s]),
                .s(s_dly), .scale(scale) );
            DelayChainMem #(.DW(DW), .LEN(2**s)) dcBf2Real (
                clk, rst, en, bf2_z1[s].re, bf2_x0[s].re);
            DelayChainMem #(.DW(DW), .LEN(2**s)) dcBf2Imag (
                clk, rst, en, bf2_z1[s].im, bf2_x0[s].im);    
        end
    endgenerate
    generate
        for(genvar s = STG - 2; s >= 0; s--) begin : mulStg
            logic [s+1:0] cnt_dly;
            DelayChain #(s+2, 2*(STG-s-2)) dlyCnt(
                clk, rst, en, ccnt[s+1:0], cnt_dly);
            Cplx mulin, w, mulout;
            logic [s : 0] waddr;
            always_ff@(posedge clk) begin
                if(rst) mulin <= '{'0, '0};
                else if(en) mulin <= bf2_z0[s+1];
            end
            assign waddr = cnt_dly[s+1] ? '0 : cnt_dly[s : 0];
            R2SdfCoefRom #(DW, s+1, "Real") wReal(clk, waddr, w.re);
            R2SdfCoefRom #(DW, s+1, "Imag") wImag(clk, waddr, w.im);
            always_comb mulout = cmul(mulin, '{w.re, invexp? -w.im : w.im});
            always_ff@(posedge clk) begin
                if(rst) bf2_x1[s] <= '{'0, '0};
                else if(en) bf2_x1[s] <= mulout;
            end
        end
    endgenerate
endmodule

/*
`include "../common.sv"
`include "../chapter4/delay_chain_mem.sv"

`timescale 1ns/100ps
`default_nettype none

module TestR2Sdf;
    import SimSrcGen::*;
    import R2SdfDefines::*;
    localparam STG = 8, LEN = 2**STG;
    logic clk, rst;
    initial GenClk(clk, 8000, 10000);
    initial GenRst(clk, rst, 2, 2);
    Cplx x[LEN]; 
    initial begin
        for(int n = 0; n < LEN; n++) begin
            x[n].re = n < 2 * LEN / 4 ? 16'sd10000 : -16'sd10000;
            x[n].im = 16'sd0;
        end
    end
    logic [STG - 1 : 0] cnt = '0, cntidx;
    assign cntidx = {<<{cnt + 1'b1}};
    logic sc = '1, inv = '0;
    Cplx out;
    wire sync = cnt == '1;
    R2Sdf #(STG) theR2Sdf(clk, rst, 1'b1, x[cnt], out, sync, sc, inv);
    always@(posedge clk) begin
        if(rst) cnt <= '0;
        else cnt <= cnt + 1'b1;
    end
endmodule

package R2SdfDefines;
    localparam DW = 16, FW = DW - 1;
    typedef struct {
        logic signed [DW-1:0] re;
        logic signed [DW-1:0] im;
    } Cplx;
    function automatic Cplx cmul(Cplx a, Cplx b);
        cmul.re = ( (DW*2)'(a.re) * b.re - (DW*2)'(a.im) * b.im ) >>> FW;
        cmul.im = ( (DW*2)'(a.re) * b.im + (DW*2)'(a.im) * b.re ) >>> FW;
    endfunction
    function automatic Cplx cadd(Cplx a, Cplx b, logic sc);
        cadd.re = ( (DW+1)'(a.re) + b.re ) >>> sc;
        cadd.im = ( (DW+1)'(a.im) + b.im ) >>> sc;
    endfunction
    function automatic Cplx csub(Cplx a, Cplx b, logic sc);
        csub.re = ( (DW+1)'(a.re) - b.re ) >>> sc;
        csub.im = ( (DW+1)'(a.im) - b.im ) >>> sc;
    endfunction
endpackage

module Bf2 import R2SdfDefines::*; (
    input Cplx x0, x1,
    output Cplx z0, z1,
    input wire s, scale
);
    always_comb z0 = ~s ? x0 : cadd(x0, x1, scale);
    always_comb z1 = ~s ? x1 : csub(x0, x1, scale);
endmodule

module R2SdfCoefRom #( parameter DW = 16, AW = 8, RI = "Real" )(
    input wire clk,
    input wire [AW-1:0] addr,
    output logic signed [DW-1:0] qout
);
    logic signed [DW-1:0] ram[0 : 2**AW - 1];
    initial begin
        for(int k = 0; k < 2**AW; k++) begin
            if(RI == "Real")
                ram[k] = $cos(3.1415926536 * k / 2**AW) * (2**(DW-1) - 1);
            else
                ram[k] = $sin(3.1415926536 * k / 2**AW) * (2**(DW-1) - 1);
        end
    end
//    always_ff@(posedge clk) qout <= ram[addr];
    always_comb qout = ram[addr];
endmodule

module R2Sdf import R2SdfDefines::*; #( STG = 4 )(
    input wire clk, rst, en,
    input Cplx in,
    output Cplx out,
    input wire sync, scale, invexp
);
    Cplx  bf2_x0[STG],  bf2_x1[STG],  bf2_z0[STG],  bf2_z1[STG];
    assign bf2_x1[STG - 1] = in;
    assign out = bf2_z0[0];
    logic [STG - 1 : 0] ccnt;
    logic sc, inv;
    always@(posedge clk) begin
        if(rst) begin
            ccnt <= 'b0;
             sc <= scale;
            inv <= invexp;
        end
        else if(en) begin
            if(sync) begin
                ccnt <= 'b0;
                sc <= scale;
                inv <= invexp;
            end
            else ccnt <= ccnt + 1'b1;
        end
    end
    generate
        for(genvar s = STG - 1; s >= 0; s--) begin : bfStg
            Bf2 theBf2 (
                .x0(bf2_x0[s]), .x1(bf2_x1[s]),
                .z0(bf2_z0[s]), .z1(bf2_z1[s]),
                .s(ccnt[s]), .scale(sc) );
            DelayChainMem #(.DW(DW), .LEN(2**s)) dcBf2Real (
                clk, rst, en, bf2_z1[s].re, bf2_x0[s].re);
            DelayChainMem #(.DW(DW), .LEN(2**s)) dcBf2Imag (
                clk, rst, en, bf2_z1[s].im, bf2_x0[s].im);    
        end
    endgenerate
    generate
        for(genvar s = STG - 2; s >= 0; s--) begin : mulStg
            Cplx mulin, w, mulout;
            logic [s : 0] waddr;
            assign mulin = bf2_z0[s+1];
            assign waddr = ccnt[s+1] ? '0 : ccnt[s : 0];
            R2SdfCoefRom #(DW, s+1, "Real") wReal(clk, waddr, w.re);
            R2SdfCoefRom #(DW, s+1, "Imag") wImag(clk, waddr, w.im);
            always_comb mulout = cmul(mulin, w);
            assign bf2_x1[s] = mulout;
        end
    endgenerate
endmodule
*/