`timescale 1ns/1ps

`include "memory.sv"
`include "cross_cd_cnt_state.sv"

module TestDcFifo;
    import SimSrcGen::*;
    logic w_clk, w_rst;
    logic r_clk, r_rst;
    initial GenClk(w_clk, 8, 10);
    initial GenClk(r_clk, 7,  9);
    initial GenRst(w_clk, w_rst, 1, 2);
    initial GenRst(r_clk, r_rst, 1, 2);
    logic [7:0] din = '0, dout;
    logic wr = '0, rd = '0;
    logic [2:0] w_wc, w_rc, w_dc;
    logic w_fu, w_em;
    logic [2:0] r_wc, r_rc, r_dc;
    logic r_fu, r_em;
    initial begin
        #100;
        // ---- try write 10 data ----
        for(int i = 0; i < 10; i++) begin
            @(posedge w_clk) {wr, din} = {1'b1, 8'($random())};
        end
        @(posedge w_clk) wr = 1'b0;
        // ---- try read 10 data ----
        repeat(2) @(posedge r_clk);
        for(int i = 0; i < 10; i++) begin
            @(posedge r_clk) rd = 1'b1;
        end
        @(posedge r_clk) rd = 1'b0;
        // ---- try write 5 data ----
        for(int i = 0; i < 5; i++) begin
            @(posedge w_clk) {wr, din} = {1'b1, 8'($random())};
        end
        @(posedge w_clk) wr = 1'b0;
        // ---- try read 5 data ----
        repeat(2) @(posedge r_clk);
        for(int i = 0; i < 5; i++) begin
            @(posedge r_clk) rd = 1'b1;
        end
        @(posedge r_clk) rd = 1'b0;
        // ---- try write 5 data ----
        for(int i = 0; i < 5; i++) begin
            @(posedge w_clk) {wr, din} = {1'b1, 8'($random())};
        end
        @(posedge w_clk) wr = 1'b0;
        // ---- try read 5 data ----
        repeat(2) @(posedge r_clk);
        for(int i = 0; i < 5; i++) begin
            @(posedge r_clk) rd = 1'b1;
        end
        @(posedge r_clk) rd = 1'b0;
        // ---- stop ----
        #100 $stop();
    end
    DcFifo #(8, 3) theFifo(
        w_clk, w_rst, din , wr & ~w_fu, w_wc, w_rc, w_dc, w_fu, w_em,
        r_clk, r_rst, dout, rd & ~r_em, r_wc, r_rc, r_dc, r_fu, r_em);
endmodule

module DcFifo #(
    parameter DW = 8,
    parameter AW = 10
)(
    // ---- write domain ----
    input wire w_clk, w_rst,
    input wire [DW - 1 : 0] din,
    input wire write,
    output logic [AW - 1 : 0] w_wr_cnt, w_rd_cnt,
    output logic [AW - 1 : 0] w_data_cnt,
    output logic w_full, w_empty,
    // ---- read domain ----
    input wire r_clk, r_rst,
    output logic [DW - 1 : 0] dout,
    input wire read,
    output logic [AW - 1 : 0] r_wr_cnt, r_rd_cnt,
    output logic [AW - 1 : 0] r_data_cnt,
    output logic r_full, r_empty
);
    localparam CAPACITY = 2**AW - 1;
    logic [DW - 1 : 0] qout_b, qout_b_reg = '0;
    // ---- write counter and read counter ----
    CrossClkCnt #(.W(AW))
    theCcdCntWr (           // write counter on write domain
        .clk_a(w_clk   ), .rst_a(w_rst   ),
        .clk_b(r_clk   ), .rst_b(r_rst   ),
        .inc  (write   ),
        .cnt_a(w_wr_cnt),   // the write counter
        .cnt_b(r_wr_cnt)    // write counter synced to read domain
    ),
    theCcdCntRd (           // read counter on read domain
        .clk_a(r_clk   ), .rst_a(r_rst   ),
        .clk_b(w_clk   ), .rst_b(w_rst   ),
        .inc  (read    ),
        .cnt_a(r_rd_cnt),    // the read counter
        .cnt_b(w_rd_cnt)     // read counter synced to write domain
    );
    // ---- the simple dual clock ram ----
    SdcRam #(.DW(DW), .WORDS(2**AW)) theRam (
        .clk_a (w_clk   ), .addr_a(w_wr_cnt),
        .wr_a  (write   ), .din_a (din     ),
        .clk_b (r_clk   ), .addr_b(r_rd_cnt),
        .qout_b(qout_b  )
    );
    // ---- refine output behavior ----
    logic rd_dly;
    always_ff@(posedge r_clk) begin
        if(r_rst) rd_dly <= 1'b0;
        else      rd_dly <= read;
    end
    always_ff@(posedge r_clk) begin
        if(r_rst)       qout_b_reg <= '0;
        else if(rd_dly) qout_b_reg <= qout_b;
    end
    assign dout = (rd_dly)? qout_b : qout_b_reg;
    // ---- flags ----
    assign w_data_cnt = w_wr_cnt - w_rd_cnt;
    assign w_full     = w_data_cnt == CAPACITY;
    assign w_empty    = w_data_cnt == 0;
    assign r_data_cnt = r_wr_cnt - r_rd_cnt;
    assign r_full     = r_data_cnt == CAPACITY;
    assign r_empty    = r_data_cnt == 0;
endmodule
