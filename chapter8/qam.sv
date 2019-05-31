`ifndef __QAM_SV__
`define __QAM_SV__

`include "../common.sv"
`include "../chapter4/counter.sv"
`include "../chapter4/delay_chain.sv"
`include "../chapter7/fir.sv"
`include "../chapter7/dds.sv"
`include "../chapter7/intp_deci.sv"

`timescale 1ns/100ps
`default_nettype none

module TestQAM16;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 8000, 10000);
    initial GenRst(clk, rst, 2, 10);
    // ====== trans side ======
    logic bb_en;
    Counter #(4) cntBb(clk, rst, 1'b1, , bb_en);
    logic [3:0] cnt_dr;
    logic dr_en;     //  symbol rate : 2.5 Mbps
    localparam SRDIV = 10;
    Counter #(SRDIV) cntDr(clk, rst, bb_en, cnt_dr, dr_en);
    wire dr_en180 = bb_en & (cnt_dr == (SRDIV-1)/2);
    logic [7:0] lfsr_out;
    LFSR #(8, 9'h11d >> 1, 8'hff) lfsrDGen(
        clk, rst, dr_en, lfsr_out);
    logic [1:0] txi, txq;
    ManchesterEncoder
        manEncI0(clk, rst, dr_en, dr_en180, lfsr_out[0],, txi[0],),
        manEncI1(clk, rst, dr_en, dr_en180, lfsr_out[1],, txi[1],),
        manEncQ0(clk, rst, dr_en, dr_en180, lfsr_out[2],, txq[0],),
        manEncQ1(clk, rst, dr_en, dr_en180, lfsr_out[3],, txq[1],);
    logic signed [11:0] qam_if;
    QAMModulator #(12, 2)
        qamod(clk, rst, bb_en, 1'b1, 1'b1, txi, txq, qam_if);
    // ====== if channel ======
    logic signed [11:0] noi = '0, qam_if_noi;
    integer noi_seed = 8937872;
    always_comb begin
        noi = $dist_normal(noi_seed, 0, 0);
        qam_if_noi = qam_if + noi;
    end
    // ====== recv side ======
    logic signed [11:0] qam_if_fil;
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
    })  qamIfFilter(clk, rst, 1'b1, qam_if_noi, qam_if_fil);
    logic signed [11:0] loc_sin, loc_cos;
    OrthDDS #(24, 12, 14) locOrthDds(clk, rst, 1'b1,
        24'sd3355443, 24'(int'(-0.9*2**24)), loc_sin, loc_cos);
    logic signed [11:0] ibb, qbb;
    QAMDemod #(12) qademod (clk, rst, 1'b1, bb_en,
        loc_sin, loc_cos, qam_if_fil, ibb, qbb);
    logic [1:0] rxi, rxq;
    logic sync;
    QAM16SyncJudge #(12, SRDIV/2, 10) qamSJ(
        clk, rst, bb_en, ibb, qbb, rxi, rxq, sync);
    logic [3:0] rxd, rxv;
    DiffManDecoder #(SRDIV)
        manDecI0(clk, rst, bb_en, rxi[0], rxd[0], rxv[0]),
        manDecI1(clk, rst, bb_en, rxi[1], rxd[1], rxv[1]),
        manDecQ0(clk, rst, bb_en, rxq[0], rxd[2], rxv[2]),
        manDecQ1(clk, rst, bb_en, rxq[1], rxd[3], rxv[3]);
endmodule

module QAMModulator #( parameter DW = 12, IQW = 2)(
    input wire clk, rst, bb_en, if_en, mod_en,  // f_bb = f_if / 4
    input wire [IQW-1:0] i, q,
    output logic signed [DW-1:0] qam    // 1.DW-1
);
    localparam LVS = 2**IQW;
    localparam real CONST_RNG = 1.0; // 1.0*0.707 < 1 with margin
    localparam real STAR_DIST = CONST_RNG / (LVS-1);
    logic signed [DW-1:0] levels[LVS];
    generate for(genvar l = 0; l < LVS; l++) begin
        assign levels[l] = (-CONST_RNG/2 + STAR_DIST*l)
                           * (2**(DW-1)-1);
    end endgenerate
    logic signed [DW-1:0] ilvl, qlvl;
    always_ff@(posedge clk) begin
        if(rst) begin ilvl <= '0; qlvl <= '0; end
        else if(bb_en) begin
            ilvl <= levels[i];
            qlvl <= levels[q];
        end
    end
    logic signed [DW-1:0] ilvl_fil, qlvl_fil; 
    FIR #(DW, 56, '{    // base band pass: 0/1-5\6 MHz @ 25MHz
    -0.0001, 0.0037, 0.0096, 0.0116, 0.0056,-0.0025,-0.0021, 0.0062,
     0.0084,-0.0029,-0.0140,-0.0088, 0.0038,-0.0010,-0.0246,-0.0361,
    -0.0179,-0.0002,-0.0214,-0.0621,-0.0617,-0.0125, 0.0076,-0.0589,
    -0.1366,-0.0790, 0.1393, 0.3473, 0.3473, 0.1393,-0.0790,-0.1366,
    -0.0589, 0.0076,-0.0125,-0.0617,-0.0621,-0.0214,-0.0002,-0.0179,
    -0.0361,-0.0246,-0.0010, 0.0038,-0.0088,-0.0140,-0.0029, 0.0084,
     0.0062,-0.0021,-0.0025, 0.0056, 0.0116, 0.0096, 0.0037,-0.0001
    })  ibbFilter(clk, rst, bb_en, ilvl, ilvl_fil),
        qbbFilter(clk, rst, bb_en, qlvl, qlvl_fil);
    logic signed [DW-1:0] ilvl_intp, qlvl_intp;
    InterpDeci #(DW)
        iIntp4x(clk, rst, bb_en, if_en, ilvl_fil, ilvl_intp),
        qIntp4x(clk, rst, bb_en, if_en, qlvl_fil, qlvl_intp);
    logic signed [DW+1:0] ilvlx4, qlvlx4;
    FIR #(DW+2, 23, '{    // low pass: 6\19 MHz @ 100MHz
     0.0005, 0.0021, 0.0033, 0.0000,-0.0105,-0.0240,-0.0263, 0.0000,
     0.0623, 0.1467, 0.2208, 0.2503, 0.2208, 0.1467, 0.0623, 0.0000,
    -0.0263,-0.0240,-0.0105, 0.0000, 0.0033, 0.0021, 0.0005
    }) iIntpFilter(clk, rst, if_en, (DW+2)'(ilvl_intp)<<<2, ilvlx4),
       qIntpFilter(clk, rst, if_en, (DW+2)'(qlvl_intp)<<<2, qlvlx4);
    wire signed [DW-1:0] ilevel = mod_en?DW'(ilvlx4):levels[LVS-1];
    wire signed [DW-1:0] qlevel = mod_en?DW'(qlvlx4):'0;
    logic signed [DW-1:0] sin, cos;
    OrthDDS #(24, DW, DW+2)
        orthDds(clk, rst, if_en, 24'sd3355443, 24'd0, sin, cos);
    logic signed [DW-1:0] imix, qmix;
    always_ff@(posedge clk) begin
        if(rst) begin imix <= '0; qmix <= '0; end
        else if(if_en) begin
            imix <= ((2*DW)'(ilevel) * cos) >>> (DW-1);
            qmix <= ((2*DW)'(qlevel) * -sin) >>> (DW-1);
        end
    end
    always_ff@(posedge clk) begin
        if(rst) qam <= '0;
        else qam <= imix + qmix;
    end
endmodule

module QAMDemod #(parameter DW=12) (
    input wire clk, rst, if_en, bb_en,
    input wire signed [DW-1:0] lc_sin, lc_cos, qam_in,
    output logic signed [DW-1:0] ilevel, qlevel
);
    logic signed [DW-1:0] imix, qmix;
    always_ff@(posedge clk) begin
        if(rst) begin imix <= '0; qmix <= '0; end
        else if(if_en) begin
            imix <= ((2*DW)'(qam_in) *  lc_cos) >>> (DW-1);
            qmix <= ((2*DW)'(qam_in) * -lc_sin) >>> (DW-1);
        end
    end
    logic signed [DW-1:0] im_df, qm_df;
    FIR #(DW, 23, '{    // low pass: 6\19 MHz @ 100MHz
     0.0005, 0.0021, 0.0033, 0.0000,-0.0105,-0.0240,-0.0263, 0.0000,
     0.0623, 0.1467, 0.2208, 0.2503, 0.2208, 0.1467, 0.0623, 0.0000,
    -0.0263,-0.0240,-0.0105, 0.0000, 0.0033, 0.0021, 0.0005
    })  imDeciFilter(clk, rst, if_en, imix, im_df),
        qmDeciFilter(clk, rst, if_en, qmix, qm_df);
    logic signed [DW-1:0] il, ql;
    FIR #(DW, 56, '{    // base band pass: 0/1-5\6 MHz @ 25MHz
    -0.0001, 0.0037, 0.0096, 0.0116, 0.0056,-0.0025,-0.0021, 0.0062,
     0.0084,-0.0029,-0.0140,-0.0088, 0.0038,-0.0010,-0.0246,-0.0361,
    -0.0179,-0.0002,-0.0214,-0.0621,-0.0617,-0.0125, 0.0076,-0.0589,
    -0.1366,-0.0790, 0.1393, 0.3473, 0.3473, 0.1393,-0.0790,-0.1366,
    -0.0589, 0.0076,-0.0125,-0.0617,-0.0621,-0.0214,-0.0002,-0.0179,
    -0.0361,-0.0246,-0.0010, 0.0038,-0.0088,-0.0140,-0.0029, 0.0084,
     0.0062,-0.0021,-0.0025, 0.0056, 0.0116, 0.0096, 0.0037,-0.0001
    })  iBbFilter(clk, rst, bb_en, im_df, il),
        qBbFilter(clk, rst, bb_en, qm_df, ql);
    assign ilevel = il <<< 1;
    assign qlevel = ql <<< 1;
endmodule

module PeakHolder #(parameter DW=12, DECAY_PERIOD=10)(
    input wire clk, rst, en,
    input wire signed [DW-1:0] in,
    output logic signed [DW-1:0] out
);
    logic decay;
    Counter #(DECAY_PERIOD)
        thDecayCnt(clk, rst, en, , decay);
    always_ff@(posedge clk) begin
        if(rst) out <= DW'(-1) <<< (DW-1);
        else if(decay) out <= out - 1'b1;
        else if(en & in > out) out <= in;
    end
endmodule

module QAM16SyncJudge #(parameter DW=12, PERIOD=5, TH_DECAY_PRD=10)(
    input wire clk, rst, bb_en,
    input wire signed [DW-1:0] ilevel, qlevel,
    output logic [1:0] i, q,
    output logic sync
);
    logic signed [DW-1:0] idiff, qdiff, ilvl_dly, qlvl_dly;
    always_ff@(posedge clk) begin
        if(rst) begin ilvl_dly <= '0; qlvl_dly <= '0; end
        else if(bb_en) begin
            ilvl_dly <= ilevel;
            qlvl_dly <= qlevel;
        end
    end
    always_ff@(posedge clk) begin
        if(rst) begin idiff <= '0; qdiff <= '0; end
        else if(bb_en) begin
            idiff <= ilevel - ilvl_dly;
            qdiff <= qlevel - qlvl_dly;
        end
    end
    logic signed [DW-1:0] idabs, qdabs, pulse, iabs, qabs;
    always_ff@(posedge clk) begin
        if(rst) pulse <= '0;
        else if(bb_en) begin
            idabs <= idiff < 0 ? -idiff : idiff;
            qdabs <= qdiff < 0 ? -qdiff : qdiff;
            pulse <= ((DW+1)'(idabs) + qdabs) >>> 1;
            iabs <= ilevel < 0 ? -ilevel : ilevel;
            qabs <= qlevel < 0 ? -qlevel : qlevel;
        end
    end
    logic signed [DW-1:0] pulse_peak, i_peak, q_peak;
    PeakHolder #(DW,TH_DECAY_PRD)
        pulsePeak(clk, rst, bb_en, pulse, pulse_peak),
        iPeak    (clk, rst, bb_en, iabs, i_peak),
        qPeak    (clk, rst, bb_en, qabs, q_peak);
    wire pedge = bb_en & (pulse >= pulse_peak);
    // compensate delay of diff, abs, sum and comp
    localparam DELAY = PERIOD - 4;
    logic pedge_dly;
    DelayChain #(1, DELAY)
        pulseDelay(clk, rst, bb_en, pedge, pedge_dly);
    logic signed [$clog2(PERIOD)-1:0] sp_cnt;
    Counter #(PERIOD)
        symPerCnt(clk, rst | pedge_dly, bb_en, sp_cnt, );
    assign sync = bb_en & (sp_cnt == (PERIOD - 1) / 2);
    logic signed [DW-1:0] ith, qth;
    wire signed [DW-1:0] two3rds = 0.667*2**(DW-1);
    always_ff@(posedge clk) begin
        if(rst) begin ith <= '0; qth <= '0; end
        else begin
            ith <= ( (2*DW)'(two3rds) * i_peak ) >>> (DW-1);
            qth <= ( (2*DW)'(two3rds) * q_peak ) >>> (DW-1);
        end
    end
    always_ff@(posedge clk) begin
        if(rst) begin i <= 2'b00; q <= 2'b00; end
        else if(sync) begin
            if(ilevel > ith) i <= 2'd3;
            else if(ilevel > 0) i <= 2'd2;
            else if(ilevel > -ith) i <= 2'd1;
            else i <= 2'd0;
            if(qlevel > qth) q <= 2'd3;
            else if(qlevel > 0) q <= 2'd2;
            else if(qlevel > -qth) q <= 2'd1;
            else q <= 2'd0;
        end
    end
endmodule   

`endif
