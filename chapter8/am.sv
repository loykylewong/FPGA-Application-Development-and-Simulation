`ifndef __AM_SV__
`define __AM_SV__

`include "../common.sv"
`include "../chapter4/counter.sv"
`include "../chapter7/fir.sv"
`include "../chapter7/dds.sv"

`timescale 1ns/100ps
`default_nettype none

module TestAM;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 80, 100);
    initial GenRst(clk, rst, 2, 10);
    // ====== modulation side ======
    logic signed [11:0] carrier;
    DDS #(24, 12, 14) carrierDDS(
        clk, rst, 1'b1, 24'sd3_355_443, 24'sd0, carrier);
    logic signed [11:0] randsig = '0; integer sig_seed = 8273;
    always begin
        repeat(10) @(posedge clk);
        randsig <= $dist_normal(sig_seed, 0, 1000);
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
    logic signed [12:0] reg_am, dsb_am;
    logic signed [11:0] ssb_am;
    AMModulator #(12) regAmMod( clk, rst, 1'b1, carrier, bbsig,
        12'(int'(2**11-1)), 12'(int'(0.5*2**11)), reg_am);
    AMModulator #(12) dsbAmMod( clk, rst, 1'b1, carrier, bbsig,
        12'(0), 12'(int'(2**11-1)), dsb_am);
    FIR #(12, 96, '{ // ssb high pass, : 19/21M @100Msps
     0.0002, 0.0001,-0.0002,-0.0003, 0.0001, 0.0006, 0.0002,-0.0007,
    -0.0008, 0.0003, 0.0013, 0.0005,-0.0014,-0.0016, 0.0007, 0.0026,
     0.0009,-0.0027,-0.0030, 0.0013, 0.0047, 0.0016,-0.0047,-0.0052,
     0.0022, 0.0079, 0.0027,-0.0077,-0.0085, 0.0036, 0.0128, 0.0044,
    -0.0127,-0.0140, 0.0059, 0.0214, 0.0074,-0.0217,-0.0245, 0.0107,
     0.0399, 0.0144,-0.0453,-0.0560, 0.0277, 0.1264, 0.0654,-0.5148,
     0.5148,-0.0654,-0.1264,-0.0277, 0.0560, 0.0453,-0.0144,-0.0399,
    -0.0107, 0.0245, 0.0217,-0.0074,-0.0214,-0.0059, 0.0140, 0.0127,
    -0.0044,-0.0128,-0.0036, 0.0085, 0.0077,-0.0027,-0.0079,-0.0022,
     0.0052, 0.0047,-0.0016,-0.0047,-0.0013, 0.0030, 0.0027,-0.0009,
    -0.0026,-0.0007, 0.0016, 0.0014,-0.0005,-0.0013,-0.0003, 0.0008,
     0.0007,-0.0002,-0.0006,-0.0001, 0.0003, 0.0002,-0.0001,-0.0002
    }) ssbFilter(clk, rst, 1'b1, 12'(dsb_am), ssb_am);
    // ====== if channel ======
    logic signed [11:0] noi = '0, reg_am_noi, ssb_am_noi;
    integer noi_seed = 983457;
    always@(posedge clk) begin
        noi = $dist_normal(noi_seed, 0, 50);
        reg_am_noi <= 12'(reg_am >>> 1) + noi;
        ssb_am_noi <= ssb_am + noi;
    end
    // ====== demodulation side ======
    logic signed [11:0] reg_am_fil, ssb_am_fil;
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
    })  regAmIfFilter(clk, rst, 1'b1, reg_am_noi, reg_am_fil),
        ssbAmIfFilter(clk, rst, 1'b1, ssb_am_noi, ssb_am_fil);
    logic signed [11:0] reg_am_demod, ssb_am_demod;
    AMEnvDemod #(12) envDemod(
        clk, rst, 1'b1, reg_am_fil, reg_am_demod);
    wire signed [11:0] locar = carrier;
    AMCohDemod #(12) cohDemod(
        clk, rst, 1'b1, ssb_am_fil, locar, ssb_am_demod);
endmodule

module AMModulator #( parameter W = 12 )(
    input wire clk, rst, en,
    input wire signed [W-1:0] carr,
    input wire signed [W-1:0] base,  // m[n], Q1.W-1
    input wire signed [W-1:0] shift, // a0,   Q1.W-1 in [0, 1)
    input wire signed [W-1:0] index, // M,    Q1.W-1 in [0, 1)
    output logic signed [W:0] modout   // s_AM  Q2.W-1
);
    localparam FW = W - 1;
    import Fixedpoint::*;
    logic signed [W-1:0] m_attn;    // Q1.FW
    always_ff@(posedge clk) begin
        m_attn <= ((2*W)'(base) * index) >>> FW;
    end
    logic signed [W:0] m_shift;     // Q2.FW
    always_ff@(posedge clk) begin
        m_shift <= m_attn + shift;
    end
    always_ff@(posedge clk) begin
        modout <= ((2*W+1)'(m_shift) * carr) >>> FW;
    end
endmodule

module AMEnvDemod #( parameter W = 12 )(
    input wire clk, rst, en,
    input wire signed [W-1:0] in,
    output logic signed [W-1:0] out
);
    logic signed [W-1:0] abs;
    always_ff@(posedge clk) begin
        abs <= in >= 'sd0 ? in : -in;
    end
    logic signed [W-1:0] deci_fil;
    FIR #(W, 23, '{    // low pass: 6\19 MHz @ 100MHz
     0.0005, 0.0021, 0.0033, 0.0000,-0.0105,-0.0240,-0.0263, 0.0000,
     0.0623, 0.1467, 0.2208, 0.2503, 0.2208, 0.1467, 0.0623, 0.0000,
    -0.0263,-0.0240,-0.0105, 0.0000, 0.0033, 0.0021, 0.0005
    })  deciFilter(clk, rst, en, abs, deci_fil);
    logic deci_en;
    Counter #(4) deciCnt(clk, rst, en, , deci_en);
    logic signed [W-1:0] out_fil;
    FIR #(W, 56, '{    // base band pass: 0/1-5\6 MHz @ 25MHz
    -0.0001, 0.0037, 0.0096, 0.0116, 0.0056,-0.0025,-0.0021, 0.0062,
     0.0084,-0.0029,-0.0140,-0.0088, 0.0038,-0.0010,-0.0246,-0.0361,
    -0.0179,-0.0002,-0.0214,-0.0621,-0.0617,-0.0125, 0.0076,-0.0589,
    -0.1366,-0.0790, 0.1393, 0.3473, 0.3473, 0.1393,-0.0790,-0.1366,
    -0.0589, 0.0076,-0.0125,-0.0617,-0.0621,-0.0214,-0.0002,-0.0179,
    -0.0361,-0.0246,-0.0010, 0.0038,-0.0088,-0.0140,-0.0029, 0.0084,
     0.0062,-0.0021,-0.0025, 0.0056, 0.0116, 0.0096, 0.0037,-0.0001
    }) envFilter(clk, rst, deci_en, deci_fil, out_fil);
    assign out = out_fil <<< 1;
endmodule

module AMCohDemod #( parameter W = 12 )(
    input wire clk, rst, en,
    input wire signed [W-1:0] in, locar,
    output logic signed [W-1:0] out
);
    logic signed [W-1:0] mix;
    always_ff@(posedge clk) begin
        mix <= ((2*W)'(in) * locar) >>> (W-1);
    end
    logic signed [W-1:0] deci_fil;
    FIR #(W, 23, '{    // low pass: 6\19 MHz @ 100MHz
     0.0005, 0.0021, 0.0033, 0.0000,-0.0105,-0.0240,-0.0263, 0.0000,
     0.0623, 0.1467, 0.2208, 0.2503, 0.2208, 0.1467, 0.0623, 0.0000,
    -0.0263,-0.0240,-0.0105, 0.0000, 0.0033, 0.0021, 0.0005
    })  deciFilter(clk, rst, en, mix, deci_fil);
    logic deci_en;
    Counter #(4) deciCnt(clk, rst, en, , deci_en);
    logic signed [W-1:0] out_fil;
    FIR #(W, 56, '{    // base band pass: 0/1-5\6 MHz @ 25MHz
    -0.0001, 0.0037, 0.0096, 0.0116, 0.0056,-0.0025,-0.0021, 0.0062,
     0.0084,-0.0029,-0.0140,-0.0088, 0.0038,-0.0010,-0.0246,-0.0361,
    -0.0179,-0.0002,-0.0214,-0.0621,-0.0617,-0.0125, 0.0076,-0.0589,
    -0.1366,-0.0790, 0.1393, 0.3473, 0.3473, 0.1393,-0.0790,-0.1366,
    -0.0589, 0.0076,-0.0125,-0.0617,-0.0621,-0.0214,-0.0002,-0.0179,
    -0.0361,-0.0246,-0.0010, 0.0038,-0.0088,-0.0140,-0.0029, 0.0084,
     0.0062,-0.0021,-0.0025, 0.0056, 0.0116, 0.0096, 0.0037,-0.0001
    }) envFilter(clk, rst, deci_en, deci_fil, out_fil);
    assign out = out_fil <<< 1;
endmodule

`endif
