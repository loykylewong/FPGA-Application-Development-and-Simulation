`ifndef __STR_DIV_SV__
`define __STR_DIV_SV__

`timescale 1ns/1ps
`default_nettype none

module str_usdiv_stg #(
    parameter int DW = 8
)( 
    input  wire           clk          ,
    input  wire           rst          ,
    input  wire  [DW-1:0] in_remainder ,
    input  wire  [DW-1:0] in_dividend  ,
    input  wire  [DW-1:0] in_divisor   ,
    input  wire  [DW-1:0] in_quotient  ,
    input  wire           in_last      ,
    input  wire           in_valid     ,
    output logic          in_ready     ,
    output logic [DW-1:0] out_remainder,
    output logic [DW-1:0] out_dividend ,
    output logic [DW-1:0] out_divisor  ,
    output logic [DW-1:0] out_quotient ,
    output logic          out_last     ,
    output logic          out_valid    ,
    input  wire           out_ready    
);
    wire ish = in_valid & in_ready;
    wire osh = out_valid & out_ready;
    assign in_ready = osh | ~out_valid;
    always_ff @( posedge clk ) begin : proc_out_valid
        if(rst) out_valid <= 1'b0;
        else if(ish) out_valid <= 1'b1;
        else if(out_ready) out_valid <= 1'b0;
    end
    wire [DW-1:0] exdd = {in_remainder[DW-2:0], in_dividend[DW-1]};
    wire enough = exdd >= in_divisor;

    always_ff @( posedge clk ) begin : proc_output
        if(rst) begin
            out_remainder <= '0;
            out_dividend  <= '0;
            out_divisor   <= '0;
            out_quotient  <= '0;
            out_last      <= 1'b0;
        end
        else if(ish) begin
            out_remainder <= enough ? exdd - in_divisor : exdd;
            out_dividend  <= {in_dividend[DW-2:0], 1'b0};
            out_divisor   <= in_divisor;
            out_quotient  <= {in_quotient[DW-2:0], enough};
            out_last      <= in_last;
        end
    end
endmodule

// About parameter PRESHIFT: 
//     if divisor_min / 2.0**N > dividend_max / 2.0**DW, set PRESHIFT = N,
//     which can reduce number of stages to DW-PRESHIFT.
module str_usdiv #(
    parameter int DW       = 8,
    parameter int PRESHIFT = 0
)(
    input  wire           clk          ,
    input  wire           rst          ,
    input  wire  [DW-1:0] in_dividend  ,
    input  wire  [DW-1:0] in_divisor   ,
    input  wire           in_last      ,
    input  wire           in_valid     ,
    output logic          in_ready     ,
    output logic [DW-1:0] out_quotient ,
    output logic [DW-1:0] out_remainder,
    output logic          out_last     ,
    output logic          out_valid    ,
    input  wire           out_ready
);
    localparam int STG = DW - PRESHIFT;
    wire [DW-1:0] rem  [STG+1];
    wire [DW-1:0] ddent[STG+1];
    wire [DW-1:0] dsor [STG+1];
    wire [DW-1:0] quot [STG+1];
    wire          last [STG+1];
    wire          valid[STG+1];
    wire          ready[STG+1];
    assign {rem[0], ddent[0]} 
                    = (2*DW)'(in_dividend) << PRESHIFT;
    assign dsor [0] = in_divisor;
    assign quot [0] = '0;
    assign last [0] = in_last;
    assign valid[0] = in_valid;
    assign in_ready = ready[0];
    generate
        for(genvar i = 0; i < STG; i++) begin : stgs
            str_usdiv_stg #( .DW(DW) )
            divs(
                .clk          (clk       ),
                .rst          (rst       ),
                .in_remainder (rem  [i]  ),
                .in_dividend  (ddent[i]  ),
                .in_divisor   (dsor [i]  ),
                .in_quotient  (quot [i]  ),
                .in_last      (last [i]  ),
                .in_valid     (valid[i]  ),
                .in_ready     (ready[i]  ),
                .out_remainder(rem  [i+1]),
                .out_dividend (ddent[i+1]),
                .out_divisor  (dsor [i+1]),
                .out_quotient (quot [i+1]),
                .out_last     (last [i+1]),
                .out_valid    (valid[i+1]),
                .out_ready    (ready[i+1])
            );
        end
    endgenerate
    assign out_remainder = rem  [STG];
    assign out_quotient  = quot [STG];
    assign out_last      = last [STG];
    assign out_valid     = valid[STG];
    assign ready[STG]     = out_ready;

endmodule

`default_nettype wire

`endif
