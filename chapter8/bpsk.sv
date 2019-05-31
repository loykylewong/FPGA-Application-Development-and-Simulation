`include "../common.sv"
`include "../chapter4/counter.sv"
`include "../chapter7/fir.sv"
`include "../chapter7/dds.sv"
`include "../chapter7/intp_deci.sv"
`include "../chapter8/man_coding.sv"

`timescale 1ns/100ps
`default_nettype none

module TestBPSK;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 80, 100);
    initial GenRst(clk, rst, 2, 10);
    // ====== trans side ======
    logic bb_en;
    Counter #(4) cntBb(clk, rst, 1'b1, , bb_en);
    logic [3:0] cnt_dr;
    logic dr_en;     //  data rate : 2.5 Mbps
    Counter #(10) cntDr(clk, rst, bb_en, cnt_dr, dr_en);
    wire dr_en180 = bb_en & (cnt_dr == 4);
    logic [7:0] lfsr_out;
    LFSR #(8, 9'h11d >> 1, 8'hff) lfsrDGen(
        clk, rst, dr_en, lfsr_out);
    logic dman;
    ManchesterEncoder theManEnc(
        clk, rst, dr_en, dr_en180, lfsr_out[0], , dman, );
    logic signed [11:0] bpsk_if;
    BPSKMod #(12, 24) bpskMod(
        clk, rst, bb_en, 1'b1, 24'sd3355443, dman, bpsk_if);
    // ====== if channel ======
    logic signed [11:0] noi = '0, bpsk_if_noi;
    integer noi_seed = 2327489;
    always_comb begin
        noi = $dist_normal(noi_seed, 0, 50);
        bpsk_if_noi = (bpsk_if >>> 1) + noi;
    end
    // ====== recv side ======
    logic signed [11:0] bpsk_if_fil;
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
    })  regAmIfFilter(clk, rst, 1'b1, bpsk_if_noi, bpsk_if_fil);
    logic signed [11:0] locar;
    DDS #(24, 12, 14) localCar(
        clk, rst, 1'b1, 24'sd3355443, 24'(int'(-0.5*2**24)), locar);
    logic dman_recv;
    BPSKDemod #(12) bpskDemod(
        clk, rst, 1'b1, bb_en, bpsk_if_fil, locar, dman_recv);
    logic bs_recv, bs_valid;
    DiffManDecoder #(10) dmanDec(
        clk, rst, bb_en, dman_recv, bs_recv, bs_valid);
endmodule

module BPSKMod #( parameter DW=12, PW=24 )(
    input wire clk, rst, bb_en, if_en,    // bb sr = 1/4 if sr
    input wire signed [PW-1:0] carr_freq, // freq / fs * 2^PW
    input wire bin,  // m[n], Q1.W-1
    output logic signed [DW-1:0] modout   // s_BPSK  Q1.W-1
);
    logic signed [DW-1:0] phase, ph_fil, ph_intp, ph_if;
    always_ff@(posedge clk) begin
        //             pi/2              -pi/2
        phase <= bin ? DW'(1) <<< (DW-2) : DW'(-1) <<< (DW-2);
    end
    FIR #(DW, 56, '{    // base band pass: 0/1-5\6 MHz @ 25MHz
    -0.0001, 0.0037, 0.0096, 0.0116, 0.0056,-0.0025,-0.0021, 0.0062,
     0.0084,-0.0029,-0.0140,-0.0088, 0.0038,-0.0010,-0.0246,-0.0361,
    -0.0179,-0.0002,-0.0214,-0.0621,-0.0617,-0.0125, 0.0076,-0.0589,
    -0.1366,-0.0790, 0.1393, 0.3473, 0.3473, 0.1393,-0.0790,-0.1366,
    -0.0589, 0.0076,-0.0125,-0.0617,-0.0621,-0.0214,-0.0002,-0.0179,
    -0.0361,-0.0246,-0.0010, 0.0038,-0.0088,-0.0140,-0.0029, 0.0084,
     0.0062,-0.0021,-0.0025, 0.0056, 0.0116, 0.0096, 0.0037,-0.0001
    }) bbFilter(clk, rst, bb_en, phase, ph_fil);
    InterpDeci #(DW) intp4x(clk, rst, bb_en, if_en, ph_fil, ph_intp);
    FIR #(DW, 23, '{    // low pass: 6\19 MHz @ 100MHz
     0.0005, 0.0021, 0.0033, 0.0000,-0.0105,-0.0240,-0.0263, 0.0000,
     0.0623, 0.1467, 0.2208, 0.2503, 0.2208, 0.1467, 0.0623, 0.0000,
    -0.0263,-0.0240,-0.0105, 0.0000, 0.0033, 0.0021, 0.0005
    })  intpFilter(clk, rst, if_en, ph_intp, ph_if);
    logic signed [PW-1:0] dds_phase;
    always_ff@(posedge clk) begin
        //            comp intp attn, align to PW,+ pi/2
        dds_phase <= ((PW'(ph_if)<<<2)<<<(PW-DW))+(PW'(1)<<<(PW-2));
    end
    DDS #(PW, DW, DW+2) carrierDDS(
        clk, rst, if_en, carr_freq, dds_phase, modout);
endmodule

module BPSKDemod #( parameter W = 12 )(
    input wire clk, rst, if_en, bb_en,
    input wire signed [W-1:0] in, locar,
    output logic out
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
    })  deciFilter(clk, rst, if_en, mix, deci_fil);
    logic signed [W-1:0] bb_ana;
    FIR #(W, 56, '{    // base band pass: 0/1-5\6 MHz @ 25MHz
    -0.0001, 0.0037, 0.0096, 0.0116, 0.0056,-0.0025,-0.0021, 0.0062,
     0.0084,-0.0029,-0.0140,-0.0088, 0.0038,-0.0010,-0.0246,-0.0361,
    -0.0179,-0.0002,-0.0214,-0.0621,-0.0617,-0.0125, 0.0076,-0.0589,
    -0.1366,-0.0790, 0.1393, 0.3473, 0.3473, 0.1393,-0.0790,-0.1366,
    -0.0589, 0.0076,-0.0125,-0.0617,-0.0621,-0.0214,-0.0002,-0.0179,
    -0.0361,-0.0246,-0.0010, 0.0038,-0.0088,-0.0140,-0.0029, 0.0084,
     0.0062,-0.0021,-0.0025, 0.0056, 0.0116, 0.0096, 0.0037,-0.0001
    }) bbFilter(clk, rst, bb_en, deci_fil, bb_ana);
    HystComp #(12, 0.1) hystComp(clk, rst, bb_en, bb_ana, out);
endmodule
