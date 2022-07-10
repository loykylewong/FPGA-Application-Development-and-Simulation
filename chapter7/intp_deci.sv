`ifndef __INTP_DECI_SV__
`define __INTP_DECI_SV__

`timescale 1ns/100ps
`default_nettype none

module InterpDeci #(
    parameter integer W    = 10,
    parameter logic   HOLD =  0
)(
    input wire clk, rst, eni, eno,
    input wire signed [W-1:0] in,
    output logic signed [W-1:0] out
);
    logic signed [W-1:0] candi;
    always_ff@(posedge clk) begin
        if(rst) candi <= '0;
        else if(eni) candi <= in;
        else if(eno) candi <= HOLD ? candi : '0;
    end
    always_ff@(posedge clk) begin
        if(rst) out <= '0;
        else if(eno) out <= candi;
    end
endmodule

`endif
