`include "../common.sv"
`include "../chapter4/delay_chain_mem.sv"

`timescale 1ns/100ps
`default_nettype none

module TestR22Sdf;
    import SimSrcGen::*;
    import R22SdfDefines::*;
    localparam STG = 2, LEN = 4**STG;
    logic clk, rst;
    initial GenClk(clk, 8000, 10000);
    initial GenRst(clk, rst, 2, 2);
    Cplx x[LEN]; 
    initial begin
        for(int n = 0; n < LEN; n++) begin
            x[n].re = n < 3 * LEN / 4 ? 16'sd500 : -16'sd500;
            x[n].im = 16'sd0;
        end
    end
    logic [STG*2 - 1 : 0] cnt = '0, cntidx;
	assign cntidx = {<<{cnt + 1'b1}};
	logic sc = '0, inv = '0;
    Cplx out;
	wire sync = cnt == '1;
    R22Sdf #(STG) theR22Sdf(clk, rst, 1'b1, x[cnt], out, sync, sc, inv);
    always@(posedge clk) begin
        if(rst) cnt <= '0;
        else cnt <= cnt + 1'b1;
    end
endmodule

package R22SdfDefines;
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

module Bf2I import R22SdfDefines::*; (
    input Cplx x0, x1,
    output Cplx z0, z1,
	input wire s, scale
);
    always_comb z0 = ~s ? x0 : cadd(x0, x1, scale);
    always_comb z1 = ~s ? x1 : csub(x0, x1, scale);
endmodule

module Bf2II import R22SdfDefines::*; (
    input Cplx x0, x1,
    output Cplx z0, z1,
	input wire s, t, scale, invexp
);
	wire Cplx x1rot = ~(~t & s) ? x1 :
	                  ~invexp   ? '{-x1.im, x1.re} : '{x1.im, -x1.re};
	always_comb z0 = ~s ? x0    : cadd(x0, x1rot, scale);
	always_comb z1 = ~s ? x1rot : csub(x0, x1rot, scale);
//////////////////////////////////////////
//	wire Cplx x1x = ~(~t & s) ? x1 : '{x1.im, x1.re};
//	//                  ~invexp  ? '{-x1.im, x1.re} : '{x1.im, -x1.re};
//	always_comb z0 = ~s ? x0    : cadd(x0, {x1x.re, (~t & s)? x1x.im : -x1x.im}, scale);
//	always_comb z1 = ~s ? x1x : csub(x0, {x1x.re, (~t & s)? x1x.im : -x1x.im}, scale);
//
endmodule 

module R22SdfCoefRom #( parameter DW = 16, AW = 8, RI = "Real" )(
    input wire clk,
    input wire [AW-1:0] addr,
    output logic signed [DW-1:0] qout
);
    logic signed [DW-1:0] ram[0 : 2**AW - 1];
    initial begin
        for(int k = 0; k < 2**AW; k++) begin
            if(RI == "Real")
                ram[k] = $cos(2.0 * 3.1415926536 * k / 2**AW) * (2**(DW-1) - 1);
            else
                ram[k] = $sin(2.0 * 3.1415926536 * k / 2**AW) * (2**(DW-1) - 1);
        end
    end
//    always_ff@(posedge clk) qout <= ram[addr];
    always_comb qout = ram[addr];
endmodule

module R22Sdf import R22SdfDefines::*; #( STG = 3 )(
	input wire clk, rst, en,
	input Cplx in,
	output Cplx out,
	input wire sync, scale, invexp
);
    Cplx  bf2i_x0[STG],  bf2i_x1[STG],  bf2i_z0[STG],  bf2i_z1[STG];
    Cplx bf2ii_x0[STG], bf2ii_x1[STG], bf2ii_z0[STG], bf2ii_z1[STG];
	assign bf2i_x1[STG - 1] = in;
	assign out = bf2ii_z0[0];
	logic [STG * 2 - 1 : 0] ccnt;
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
			Bf2I theBf2I (
			    .x0(bf2i_x0[s]), .x1(bf2i_x1[s]),
			    .z0(bf2i_z0[s]), .z1(bf2i_z1[s]),
				.s(ccnt[s * 2 + 1]), .scale(sc) );
		    DelayChainMem #(.DW(DW), .LEN(4**s * 2)) dcBf2iReal (
		        clk, rst, en, bf2i_z1[s].re, bf2i_x0[s].re);
	   	 	DelayChainMem #(.DW(DW), .LEN(4**s * 2)) dcBf2iImag (
		        clk, rst, en, bf2i_z1[s].im, bf2i_x0[s].im);
			assign bf2ii_x1[s] = bf2i_z0[s];
			Bf2II theBf2II (
				.x0(bf2ii_x0[s]), .x1(bf2ii_x1[s]),
				.z0(bf2ii_z0[s]), .z1(bf2ii_z1[s]),
				.s(ccnt[s * 2]), .t(ccnt[s * 2 + 1]),
				.scale(sc), .invexp(inv) );
		    DelayChainMem #(.DW(DW), .LEN(4**s)) dcBf2iiReal (
		        clk, rst, en, bf2ii_z1[s].re, bf2ii_x0[s].re);
		    DelayChainMem #(.DW(DW), .LEN(4**s)) dcBf2iiImag (
		        clk, rst, en, bf2ii_z1[s].im, bf2ii_x0[s].im);		
		end
	endgenerate
	generate
		for(genvar s = STG - 2; s >= 0; s--) begin : mulStg
        	Cplx mulin, w, mulout;
        	logic [s*2+3 : 0] waddr;
		    assign mulin = bf2ii_z0[s+1];
//		    assign waddr = ccnt[0 +: (s*2+2)] * ccnt[(s*2+2) +: 2];
	    	assign waddr = ccnt[0 +: (s*2+2)] * 2'({<<{ccnt[(s*2+2) +: 2]}});
		    R22SdfCoefRom #(DW, s*2+4, "Real") wReal(clk, waddr, w.re);
		    R22SdfCoefRom #(DW, s*2+4, "Imag") wImag(clk, waddr, w.im);
		    always_comb mulout = cmul(mulin, w);
		    assign bf2i_x1[s] = mulout;
		end
	endgenerate
endmodule
// change addr : x
// change back addr, change ~(~t & s) : x
// change back to (~t & s), change rom to -sin : x