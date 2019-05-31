`include "../common.sv"
`include "../chapter7/fir.sv"

module TestBasebandSys;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 80, 100);
    initial GenRst(clk, rst, 2, 2);
    // ====== trans side ======
    logic [3:0] cnt_dr;
    logic dr_en;     // baseband dr : 10 Mbps
    Counter #(10) cntDr(clk, rst, 1'b1, cnt_dr, dr_en);
    wire dr_en180 = cnt_dr == 4;
    logic [6:0] bit_cnt;
    // 10 byte frame: 0xff(for sync) - 8 bytes data - 1 byte crc
    Counter #(80) framCnt(clk, rst, dr_en, bit_cnt, );
    logic [7:0] lfsr_out;
    logic lfsr_en, data_bit;
    // generate 0x7F at 1st byte
    assign data_bit = bit_cnt<7'd8 ? bit_cnt!=7'd7 : lfsr_out[0];
    assign lfsr_en = bit_cnt inside {[7'd8 : 7'd71]} & dr_en;
    LFSR #(8, 9'h11d >> 1, 8'hff) lfsrDGen(
        clk, rst, lfsr_en, lfsr_out);
    logic dbit_crc;     // data bits with crc bits
    wire dbit_start = bit_cnt == 7'd8;
    wire dbit_last = bit_cnt == 7'd71;
    CRCGenerator #(8, 9'h19b >> 1, 8'h00) crcGen(clk, rst, 
        dr_en, data_bit, dbit_start, dbit_last, dbit_crc);
    logic dman;
    ManchesterEncoder theManEnc(
        clk, rst, dr_en, dr_en180, dbit_crc, , dman, );
    // limit bandwidth
    logic signed [11:0] baseband;
    // -40dB .1M/3M ~1dB 15M\18M -40dB @ 100Msps
    FIR #(12, 50, '{
        -0.0104, -0.0123, -0.0102, -0.0022,  0.0052,  0.0041,
        -0.0070, -0.0208, -0.0257, -0.0176, -0.0049, -0.0027,
        -0.0183, -0.0416, -0.0515, -0.0355, -0.0052,  0.0097,
        -0.0137, -0.0649, -0.0995, -0.0690,  0.0385,  0.1798,
         0.2794,  0.2794,  0.1798,  0.0385, -0.0690, -0.0995,
        -0.0649, -0.0137,  0.0097, -0.0052, -0.0355, -0.0515,
        -0.0416, -0.0183, -0.0027, -0.0049, -0.0176, -0.0257,
        -0.0208, -0.0070,  0.0041,  0.0052, -0.0022, -0.0102,
        -0.0123, -0.0104
    })  fir1(clk, rst, 1'b1, dman?12'sd1000:-12'sd1000, baseband);
    // ====== channel noise ======
    logic signed [11:0] bb_noi; integer seed = 9527;
    always_ff@(posedge clk) begin
        bb_noi <= baseband + $dist_normal(seed, 0, 1000);
    end
    // ====== recv side ======
    logic signed [11:0] bb_filtered;
    // same as the one above
    FIR #(12, 50, '{
        -0.0104, -0.0123, -0.0102, -0.0022,  0.0052,  0.0041,
        -0.0070, -0.0208, -0.0257, -0.0176, -0.0049, -0.0027,
        -0.0183, -0.0416, -0.0515, -0.0355, -0.0052,  0.0097,
        -0.0137, -0.0649, -0.0995, -0.0690,  0.0385,  0.1798,
         0.2794,  0.2794,  0.1798,  0.0385, -0.0690, -0.0995,
        -0.0649, -0.0137,  0.0097, -0.0052, -0.0355, -0.0515,
        -0.0416, -0.0183, -0.0027, -0.0049, -0.0176, -0.0257,
        -0.0208, -0.0070,  0.0041,  0.0052, -0.0022, -0.0102,
        -0.0123, -0.0104
    })  fir2(clk, rst, 1'b1, baseband, bb_filtered);
    logic bb_1bit;
    HystComp #( 12, 0.01 ) theHystComp(
        clk, rst, 1'b1, bb_filtered, bb_1bit );
    logic decoded, dec_valid;
    DiffManDecoder #( 11 ) theDmanDec( // mimic period err
        clk, rst, 1'b1, bb_1bit, decoded, dec_valid );
    // frame sync
    logic [7:0] dec_reg;
    always_ff@(posedge clk) begin
        if(rst) dec_reg <= '0;
        else if(dec_valid) dec_reg <= {decoded, dec_reg[7:1]};
    end
    logic [6:0] dec_bcnt;
    always_ff@(posedge clk) begin
        if(rst) dec_bcnt <= '0;
        else if(dec_valid) begin
            if((dec_bcnt < 7'd15 || dec_bcnt >= 7'd80 ) && 
                {decoded, dec_reg[7:1]} == 8'h7f) dec_bcnt <= 7'd8;
            else dec_bcnt <= dec_bcnt + 7'b1;
        end
    end
    wire chk_start = dec_bcnt == 7'd8;
    wire chk_last = dec_bcnt == 8'd79;
    logic err, err_reg;
    CRCChecker #( 8, 9'h19b >> 1, 8'h00 ) crcChk(
        clk, rst, dec_valid, decoded, chk_start, chk_last, err);
    always_ff@(posedge clk) if(dec_valid) err_reg <= err;
endmodule
