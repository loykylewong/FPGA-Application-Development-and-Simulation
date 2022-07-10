`include "../common.sv"
//`include "../chapter4/counter.sv"
//`include "./dds.sv"

`timescale 1ns/100ps
`default_nettype none

module Integrator #( parameter W = 10 )(
    input wire clk, rst, en,
    input wire signed [W-1:0] in,
    output logic signed [W-1:0] out
);
    always_ff@(posedge clk) begin
        if(rst) out <= '0;
        else if(en) out <= out + in;
    end
endmodule

module Comb #( parameter W = 10, M = 1 )(
    input wire clk, rst, en,
    input wire signed [W-1:0] in,
    output logic signed [W-1:0] out
);
    logic signed [W-1:0] dly[M];    // imp z^-M
   generate
       if(M > 1) begin
            always_ff@(posedge clk) begin
                if(rst) dly <= '{M{'0}};
                else if(en) dly <= {in, dly[0:M-2]};
            end
       end
       else begin
           always_ff@(posedge clk) begin
               if(rst) dly <= '{M{'0}};
               else if(en) dly[0] <= in;
           end
       end
   endgenerate
    always_ff@(posedge clk) begin
        if(rst) out <= '0;
        else if(en) out <= in - dly[M-1];
    end
endmodule

module CicUpSampler #( parameter integer W = 10, R = 4, M = 1, N = 2 )(
    input wire clk, rst, eni, eno,
    input wire signed [W-1:0] in,
    output logic signed [W-1:0] out
);
    import Fixedpoint::*;
    function real Gain(integer k);
        if(k <= N) Gain = 2.0**k;
        else Gain = 2.0**(2 * N - k) * (R * M)**(k - N) / R;
    endfunction
    function integer StgWidth(integer k);  // imp eq.7-??
		StgWidth = W + $clog2(integer'(0.5 + Gain(k)));
    endfunction
    function integer MaxWidth;
        MaxWidth = 0;
        for(int k = 1; k <= 2*N; k++)
            if(MaxWidth < StgWidth(k)) MaxWidth = StgWidth(k);
        return MaxWidth;
    endfunction
    localparam WMAX = MaxWidth();
    logic signed [WMAX-1:0] combs_data[N+1];  // max width interconnect
    assign combs_data[0] = in;
    generate
        for(genvar k = 0; k < N; k++) begin : Combs
            localparam DW = StgWidth(k+1);
            logic signed [DW-1:0] comb_out;
            Comb #(DW, M) theComb(
                clk, rst, eni, combs_data[k][DW-1:0], comb_out);
            assign combs_data[k+1] = comb_out;
        end
    endgenerate
    localparam INTPW = StgWidth(N);
    logic signed [INTPW-1:0] intp_out;
    InterpDeci #(INTPW, 0) theInterp(
        clk, rst, eni, eno, combs_data[N][INTPW-1:0], intp_out);
    logic signed [WMAX-1:0] intgs_data[N+1];
    assign intgs_data[0] = intp_out;
    generate
        for(genvar k = 0; k < N; k++) begin : Intgs
            localparam DW = StgWidth(k+1+N);
            logic signed [DW-1:0] intg_out;
            Integrator #(DW) theIntg(
                clk, rst, eno, intgs_data[k][DW-1:0], intg_out);
            assign intgs_data[k+1] = intg_out;
        end
    endgenerate
    localparam FINALW = StgWidth(2*N);
    localparam real FINAL_GAIN = Gain(2*N);
    // Q1.(FINALW-1)
    wire signed [FINALW-1:0] attn = (1.0 / FINAL_GAIN * 2**(FINALW-1));
    `DEF_FP_MUL(mul, FINALW-W+1, W-1, 1, FINALW-1, W-1);
    always_ff@(posedge clk) begin 
        if(rst) out <= '0;
        else if(eno) out <= mul(intgs_data[N], attn);
    end
endmodule

module CicDownSampler #( parameter integer W = 10, R = 4, M = 1, N = 2 )(
    input wire clk, rst, eni, eno,
    input wire signed [W-1:0] in,
    output logic signed [W-1:0] out
);
    import Fixedpoint::*;
    localparam real GAIN = (real'(R) * M)**(N);
    localparam integer DW = W + $ceil($ln(GAIN)/$ln(2));
    logic signed [DW-1:0] intgs_data[N+1];
    assign intgs_data[0] = in;
    generate
        for(genvar k = 0; k < N; k++) begin : Intgs
            Integrator #(DW) theIntg(
                clk, rst, eni, intgs_data[k], intgs_data[k+1]);
        end
    endgenerate
    logic signed [DW-1:0] combs_data[N+1];
    InterpDeci #(DW, 0) theDeci(
        clk, rst, eni, eno, intgs_data[N], combs_data[0]);
    generate
        for(genvar k = 0; k < N; k++) begin : Combs
            Comb #(DW, M) theComb(
                clk, rst, eno, combs_data[k], combs_data[k+1]);
        end
    endgenerate
    // Q1.(DW-1)
    wire signed [DW-1:0] attn = (1.0 / GAIN * 2.0**(DW-1));
    `DEF_FP_MUL(mul, DW-W+1, W-1, 1, DW-1, W-1);
    always_ff@(posedge clk) begin
        if(rst) out <= '0;
        else if(eno) out <= mul(combs_data[N], attn);
    end
endmodule

