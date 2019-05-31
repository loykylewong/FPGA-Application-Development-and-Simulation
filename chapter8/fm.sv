`include "../common.sv"
`include "../chapter7/fir.sv"
`include "../chapter7/dds.sv"
`include "./am.sv"

`timescale 1ns/100ps
`default_nettype none

module TestFM;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 80, 100);
    initial GenRst(clk, rst, 2, 10);
    // ====== modulation side ======
    logic signed [11:0] randsig = '0; integer sig_seed = 8273;
    always begin
        repeat(10) @(posedge clk);
        randsig <= $dist_normal(sig_seed, 0, 2000);
    end
    logic signed [11:0] bbsig;
    FIR #(12, 136, '{ // randsig filter : 1/2.5 - 3.5\5M @100Msps
    -0.0012,-0.0003,-0.0003,-0.0003,-0.0002,-0.0002,-0.0001,-0.0001,
     0.0000, 0.0000, 0.0000,-0.0001,-0.0003,-0.0004,-0.0007,-0.0010,
    -0.0014,-0.0017,-0.0021,-0.0023,-0.0026,-0.0026,-0.0025,-0.0022,
    -0.0017,-0.0009, 0.0002, 0.0015, 0.0031, 0.0048, 0.0066, 0.0084,
     0.0102, 0.0117, 0.0130, 0.0138, 0.0141, 0.0138, 0.0129, 0.0112,
     0.0088, 0.0058, 0.0021,-0.0020,-0.0065,-0.0112,-0.0159,-0.0203,
    -0.0242,-0.0275,-0.0299,-0.0313,-0.0315,-0.0305,-0.0282,-0.0248,
    -0.0201,-0.0145,-0.0082,-0.0012, 0.0060, 0.0132, 0.0200, 0.0263,
     0.0316, 0.0359, 0.0388, 0.0403, 0.0403, 0.0388, 0.0359, 0.0316,
     0.0263, 0.0200, 0.0132, 0.0060,-0.0012,-0.0082,-0.0145,-0.0201,
    -0.0248,-0.0282,-0.0305,-0.0315,-0.0313,-0.0299,-0.0275,-0.0242,
    -0.0203,-0.0159,-0.0112,-0.0065,-0.0020, 0.0021, 0.0058, 0.0088,
     0.0112, 0.0129, 0.0138, 0.0141, 0.0138, 0.0130, 0.0117, 0.0102,
     0.0084, 0.0066, 0.0048, 0.0031, 0.0015, 0.0002,-0.0009,-0.0017,
    -0.0022,-0.0025,-0.0026,-0.0026,-0.0023,-0.0021,-0.0017,-0.0014,
    -0.0010,-0.0007,-0.0004,-0.0003,-0.0001, 0.0000, 0.0000, 0.0000,
    -0.0001,-0.0001,-0.0002,-0.0002,-0.0003,-0.0003,-0.0003,-0.0012
    }) sigFilter(clk, rst, 1'b1, randsig, bbsig);
    logic signed [11:0] wbfm;
    FMModulator #(12, 24) fmMod(
        clk, rst, 1'b1, 24'sd3355443, 24'sd335544, bbsig, wbfm);
    // ====== if channel ======
    logic signed [11:0] noi = '0, wbfm_noi;
    integer noi_seed = 983457;
    always@(posedge clk) begin
        noi = $dist_normal(noi_seed, 0, 50);
        wbfm_noi <= (wbfm >>> 1) + noi;
    end
    // ====== demodulation side ======
    logic signed [11:0] wbfm_fil;
    FIR #(12, 104, '{ // if band pass : 12/14 - 26\28M, @100Msps
    -0.0003, 0.0004,-0.0002, 0.0006, 0.0028, 0.0014,-0.0055,-0.0071,
     0.0034, 0.0119, 0.0036,-0.0089,-0.0070, 0.0017, 0.0009,-0.0012,
     0.0063, 0.0088,-0.0037,-0.0114,-0.0026, 0.0029,-0.0020, 0.0027,
     0.0142, 0.0055,-0.0148,-0.0126, 0.0030, 0.0010,-0.0028, 0.0150,
     0.0211,-0.0092,-0.0283,-0.0066, 0.0073,-0.0057, 0.0076, 0.0406,
     0.0161,-0.0449,-0.0396, 0.0096, 0.0016,-0.0116, 0.0678, 0.1075,
    -0.0556,-0.2208,-0.0774, 0.2155, 0.2155,-0.0774,-0.2208,-0.0556,
     0.1075, 0.0678,-0.0116, 0.0016, 0.0096,-0.0396,-0.0449, 0.0161,
     0.0406, 0.0076,-0.0057, 0.0073,-0.0066,-0.0283,-0.0092, 0.0211,
     0.0150,-0.0028, 0.0010, 0.0030,-0.0126,-0.0148, 0.0055, 0.0142,
     0.0027,-0.0020, 0.0029,-0.0026,-0.0114,-0.0037, 0.0088, 0.0063,
    -0.0012, 0.0009, 0.0017,-0.0070,-0.0089, 0.0036, 0.0119, 0.0034,
    -0.0071,-0.0055, 0.0014, 0.0028, 0.0006,-0.0002, 0.0004,-0.0003
    })  wbfmIfFilter(clk, rst, 1'b1, wbfm_noi, wbfm_fil);
    logic signed [11:0] wbfm_demod;
    WBFMDemod #(12) fmDemod( clk, rst, 1'b1, wbfm_fil, wbfm_demod);
endmodule

module FMModulator #(parameter DW = 12, PW = 24)(
    input wire clk, rst, en,
    input wire signed [PW-1:0] carr_freq, // freq / fs * 2^PW
    input wire signed [PW-1:0] freq_shift,// df / fs * 2^PW
    input wire signed [DW-1:0] modin,     // m[n], Q1.DW-1
    output logic signed [DW-1:0] modout   // s_fm[n],  Q1.DW-1
);
    logic signed [PW-1:0] dfreq, dds_freq;
    always_ff@(posedge clk) begin
        if(rst) dfreq <= '0;
        else if(en) dfreq <= ((DW+PW)'(modin)*freq_shift)>>>(DW-1);
    end
    always_ff@(posedge clk) begin
        if(rst) dds_freq <= '0;
        else if(en) dds_freq <= dfreq + carr_freq;
    end
    DDS #(PW, DW, DW+2) fmDDS(
        clk, rst, en, dds_freq, PW'(0), modout);
endmodule

module WBFMDemod #(parameter W = 12)(
    input wire clk, rst, en,
    input wire signed [W-1:0] in,
    output logic signed [W-1:0] out
);
    logic signed [W+1:0] in_fil, env_out;
    FIR #(W+2, 39, '{ //high pass: lin 18(0.336)/22(0.664) MHz @100MHz
    -0.000007,-0.000012, 0.000041, 0.000168, 0.000000,-0.000657,
    -0.000661, 0.000952, 0.001930, 0.000000,-0.001259, 0.000496,
    -0.003088,-0.012358, 0.000000, 0.043346, 0.046010,-0.081935,
    -0.292968, 0.599996,-0.292968,-0.081935, 0.046010, 0.043346,
     0.000000,-0.012358,-0.003088, 0.000496,-0.001259, 0.000000,
     0.001930, 0.000952,-0.000661,-0.000657, 0.000000, 0.000168,
     0.000041,-0.000012,-0.000007
    })  freqDetFilter(clk, rst, en, (W+2)'(in)<<<2, in_fil);
    AMEnvDemod #(W+2) theEnvDet(clk, rst, en, in_fil, env_out);
    assign out = env_out;
endmodule
