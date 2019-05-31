`ifndef __CRC_SV__
`define __CRC_SV__
`include "../chapter4/counter.sv"

module CRCGenerator #(
    parameter N = 8,
    parameter [N-1 : 0] FB = 8'hcd,//FB = representation value >> 1
    parameter [N-1 : 0] INIT = 8'h00
)(
    input wire clk, rst, en, in,
    // 8 bits will be ignored after dlast, padding dummy bits
    input wire calc_start, calc_last,
    output logic out
);
    logic crc, crc_end; // crc outputting, crc output finish
    Counter #(N) crcBitCnt(clk, rst, en & crc, , crc_end);
    always_ff@(posedge clk) begin
        if(rst) crc <= '0;
        else if(en & calc_last) crc <= '1;
        else if(crc_end | en&calc_start) crc <= '0;
    end
    logic [N-1:0] lfsr;
    always_ff@(posedge clk) begin
        if(rst) lfsr <= '0;
        else if(en & calc_start)
            lfsr <= (INIT[0]^in) ? (INIT>>1)^FB : (INIT>>1);
        else if(en)
            lfsr <= crc? lfsr >> 1 :
                        (lfsr[0]^in) ? (lfsr>>1)^FB : (lfsr>>1);
    end
    assign out = crc ? lfsr[0] : in;
endmodule

module CRCChecker #(
    parameter N = 8,
    parameter [N-1 : 0] FB = 8'hcd, // FB = representation value>> 1
    parameter [N-1 : 0] INIT = 8'h00
)(
    input wire clk, rst, en, in,
    input wire chk_start, chk_last, // chk_last including crc bits
    output logic err    // should occur when chk_last and en high
);
    logic [N-1:0] lfsr, lfsr_nxt;
    always_ff@(posedge clk) begin
        if(rst) lfsr <= '0;
        else if(en & chk_start)
            lfsr <= (INIT[0] ^ in) ?  (INIT>>1) ^ FB : (INIT>>1);
        else if(en) lfsr <= lfsr_nxt;
    end
    always_comb lfsr_nxt = (lfsr[0] ^ in) ?
                            (lfsr >> 1) ^ FB : (lfsr >> 1);
    assign err = en & chk_last & (lfsr_nxt != N'(0));
endmodule

`endif
