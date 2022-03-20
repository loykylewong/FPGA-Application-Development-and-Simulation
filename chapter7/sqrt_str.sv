`ifndef __STR_SQRT_SV__
`define __STR_SQRT_SV__

`timescale 1ns/1ps
`default_nettype none

module str_sqrt_stg #(
    parameter integer RBP = 0,  // root working bit pos
    parameter integer RDW = 4   // root width
)(
    input  wire  clk, rst,
    // rem & root input from prev. stg.
    input  wire  [2*RDW-1:0] remi,
    input  wire  [  RDW-1:0] rooti,
    input  wire  ilast, ivalid,
    output wire  iready,
    // rem & root output to next. stg.
    output logic [2*RDW-1:0] remo,
    output logic [  RDW-1:0] rooto,
    output logic olast, ovalid,
    input  wire  oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    assign iready = osh | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= 1'b0;
        else if(ish)    ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    generate if(RBP >= RDW)
        $fatal("Stage exceed limit.");
    endgenerate
    // delta root
    wire [RDW-1:0] dr = (RDW)'(1) << RBP;
    // sub   =   enough  ?   2 * rooti * dr   +          dr^2
    wire [2*RDW-1:0] sub = (rooti << (RBP+1)) | ((2*RDW)'(1) << (2*RBP));
    wire enough = remi >= sub;
    always_ff @(posedge clk) begin : proc_output
        if(rst) begin
            remo <= '0;
            rooto <= '0;
            olast <= 1'b0;
        end
        else if(ish) begin
            olast <= ilast;
            if(enough) begin
                remo <= remi - sub;
                rooto <= rooti | dr;
            end
            else begin
                remo <= remi;
                rooto <= rooti;
            end
        end
    end
endmodule : str_sqrt_stg

module str_sqrt #(
    parameter integer RDW = 4
)(
    input  wire              clk, rst,
    input  wire  [2*RDW-1:0] num,
    input  wire              ilast, ivalid,
    output wire              iready,
    output wire  [  RDW-1:0] sqrt,
    output wire  [2*RDW-1:0] rem,
    output wire              olast, ovalid,
    input  wire              oready
);
    wire [2*RDW-1:0] rems[RDW+1];
    wire [  RDW-1:0] root[RDW+1];
    wire [  RDW  :0] last, valid, ready;
    assign rems[RDW]  = num;
    assign root[RDW]  = '0;
    assign last[RDW]  = ilast;
    assign valid[RDW] = ivalid;
    assign iready = ready[RDW];
    generate
        for(genvar i = RDW-1; i >=0; i--) begin :stages
            str_sqrt_stg #(i, RDW) sqrt_stg(clk, rst,
                rems[i+1], root[i+1], last[i+1], valid[i+1], ready[i+1],
                rems[i],   root[i],   last[i],   valid[i],   ready[i]
            );
        end
    endgenerate
    assign sqrt     = root [0];
    assign rem      = rems [0];
    assign olast    = last [0];
    assign ovalid   = valid[0];
    assign ready[0] = oready;

endmodule

`default_nettype wire
`endif
