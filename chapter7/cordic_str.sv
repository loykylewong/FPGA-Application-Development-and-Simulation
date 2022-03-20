// vi: set ai si ts=4 sw=4 ft=systemverilog expandtab nu:
`ifndef __CORDIC_STR_SV__
`define __CORDIC_STR_SV__

`timescale 1ns/1ps
`default_nettype none

// Rotation Mode Stage
module CordicRotStage #(
    parameter integer DW = 10,
    parameter integer AW = DW,
    parameter integer STG = 0
)(
    input wire clk, rst,
    input wire signed [DW-1 : 0] xin,      // x_i
    input wire signed [DW-1 : 0] yin,      // y_i
    input wire signed [AW-1 : 0] ain,      // theta_i
    input wire                   in_last,
    input wire                   in_valid,
    output wire                  in_ready,
    output logic signed [DW-1 : 0] xout,   // x_i+1
    output logic signed [DW-1 : 0] yout,   // y_i+1
    output logic signed [AW-1 : 0] aout,   // theta_i+1
    output logic                   out_last,
    output logic                   out_valid,
    input wire                     out_ready
);
    wire en = in_valid & in_ready;
    wire out_hs = out_valid & out_ready;
    assign in_ready = out_hs | ~out_valid;
    always_ff @(posedge clk) begin : proc_out_valid
        if(rst) out_valid <= 1'b0;
        else if(en) out_valid <= 1'b1;
        else if(out_ready) out_valid <= 1'b0;
    end
    
    // atan:real:[-pi, pi) <=> theta:(Q1.(AW-1)):[-1.0, 1.0) 
    localparam real atan = $atan(2.0**(-STG));
    wire [AW-1 : 0] theta = atan / 3.1415926536 * 2.0**(AW-1);
    wire signed [DW-1 : 0] x_shifted = (xin >>> STG);                                    
    wire signed [DW-1 : 0] y_shifted = (yin >>> STG);
    always_ff@(posedge clk) begin
        if(rst) begin
            aout <= 1'b0;
            xout <= 1'b0;
            yout <= 1'b0;
            out_last <= 1'b0;
        end
        else if(en) begin
            out_last <= in_last;
            if(ain > 0) begin
                aout <= ain - theta;
                xout <= xin - y_shifted;
                yout <= yin + x_shifted;
            end
            else begin
                aout <= ain + theta;
                xout <= xin + y_shifted;
                yout <= yin - x_shifted;
            end
        end
    end
endmodule

// Vectoring Mode Stage
module CordicVecStage #(
    parameter integer DW = 10,
    parameter integer AW = DW,
    parameter integer STG = 0
)(
    input wire clk, rst,
    input wire        [DW-1 : 0] xin,      // x_i, must not be positive
    input wire signed [DW-1 : 0] yin,      // y_i
    input wire signed [AW-1 : 0] ain,      // theta_i
    input wire                   in_last,
    input wire                   in_valid,
    output wire                  in_ready,
    output logic signed [DW-1 : 0] xout,   // x_i+1
    output logic signed [DW-1 : 0] yout,   // y_i+1
    output logic signed [AW-1 : 0] aout,   // theta_i+1
    output logic                   out_last,
    output logic                   out_valid,
    input wire                     out_ready
);
    wire en = in_valid & in_ready;
    wire out_hs = out_valid & out_ready;
    assign in_ready = out_hs | ~out_valid;
    always_ff @(posedge clk) begin : proc_out_valid
        if(rst) out_valid <= 1'b0;
        else if(en) out_valid <= 1'b1;
        else if(out_ready) out_valid <= 1'b0;
    end

    // atan:real:[-pi, pi) <=> theta:(Q1.(AW-1)):[-1.0, 1.0) 
    localparam real atan = $atan(2.0**(-STG));
    wire [AW-1 : 0] theta = atan / 3.1415926536 * 2.0**(AW-1);
    wire        [DW-1 : 0] x_shifted = (xin >>> STG);    
    wire signed [DW-1 : 0] y_shifted = (yin >>> STG);
    always_ff@(posedge clk) begin
        if(rst) begin
            aout <= 1'b0;
            xout <= 1'b0;
            yout <= 1'b0;
            out_last <= 1'b0;
        end
        else if(en) begin
            out_last <= in_last;
            if(yin < 0) begin
                aout <= ain - theta;
                xout <= xin - y_shifted;
                yout <= yin + x_shifted;
            end
            else begin
                aout <= ain + theta;
                xout <= xin + y_shifted;
                yout <= yin - x_shifted;
            end
        end
    end
endmodule

module CordicQuadrantTrans #(
    parameter string MODE = "ROT",  // "ROT" or "VEC"
    parameter integer DW = 10, AW = DW
)(
    input wire clk, rst,
    input wire signed [DW-1 : 0] xin,       //Q1.9
    input wire signed [DW-1 : 0] yin,       //Q1.9
    input wire signed [AW-1 : 0] ain,       //Q1.9 [-1,1)->[-pi,pi)
    input wire                   in_last,
    input wire                   in_valid,
    output wire                  in_ready,
    output logic signed [DW : 0] xout,      //Q2.9
    output logic signed [DW : 0] yout,      //Q2.9
    output logic signed [AW : 0] aout,      //Q1.10 [-1,1)->[-pi,pi)
    output logic                 out_last,
    output logic                 out_valid,
    input wire                   out_ready
);
    wire en = in_valid & in_ready;
    wire out_hs = out_valid & out_ready;
    assign in_ready = out_hs | ~out_valid;
    always_ff @(posedge clk) begin
        if(rst) out_valid <= 1'b0;
        else if(en) out_valid <= 1'b1;
        else if(out_ready) out_valid <= 1'b0;
    end
    generate if(MODE == "ROT") begin
        always_ff @(posedge clk) begin
            if(rst) begin
                xout <= '0;
                yout <= '0;
                aout <= '0;
                out_last <= '0;
            end
            else if(en) begin
                out_last <= in_last;
                if(~^ain[AW-1 -: 2]) begin   // in quadrant 1 or 4
                    xout <= xin;
                    yout <= yin;
                    aout <= ain <<< 1;
                end
                else begin    // in quadrant 2 or 3
                    xout <= -xin;
                    yout <= -yin;
                    aout <= (ain + (AW'(1) << (AW-1))) <<< 1;   // rotate 180 deg
                end
            end
        end
    end
    else if(MODE == "VEC") begin
        always_ff @(posedge clk) begin
            if(rst) begin
                xout <= '0;
                yout <= '0;
                aout <= '0;
                out_last <= '0;
            end
            else if(en) begin
                out_last <= in_last;
                if(~xin[DW-1]) begin    // in quadrant 1 or 4
                    xout <= xin;
                    yout <= yin;
                    aout <= ain <<< 1;
                end
                else begin    // in quadrant 2 or 3
                    xout <= -xin;
                    yout <= -yin;
                    aout <= (ain + (AW'(1) << (AW-1))) <<< 1;   // rotate 180 deg
                end
            end
        end
    end
    endgenerate
endmodule

// Dual mode Cordic: Rotation mode and Vectoring mode
module CordicStr #(
    parameter string MODE = "ROT",      // "ROT" or "VEC"
    parameter integer DW = 10, AW = DW, ITER = DW
)(  
    input  wire                      clk, rst,
    input  wire signed [DW - 1 : 0]  xin,    //Q1.9
    input  wire signed [DW - 1 : 0]  yin,    //Q1.9
    input  wire signed [AW - 1 : 0]  ain,    //Q1.9 [-1,1)->[-pi,pi)
    input  wire                      in_last,
    input  wire                      in_valid,
    output wire                      in_ready,
    output logic signed [DW - 1 : 0] xout, //Q1.9
    output logic signed [DW - 1 : 0] yout, //Q1.9
    output logic signed [AW - 1 : 0] aout, //Q1.9 [-1,1)->[-pi,pi)
    output logic                     out_last,
    output logic                     out_valid,
    input  wire                      out_ready
);
    wire signed [DW : 0] x [ITER+1];  //Q2.9 to against overflow
    wire signed [DW : 0] y [ITER+1];  //Q2.9 to against overflow
    wire signed [AW : 0] a [ITER+1];  //Q1.10 [-1,1)->[-pi,pi)
    wire                 l [ITER+1];
    wire                 v [ITER+1];
    wire                 r [ITER+1];
    CordicQuadrantTrans #(MODE, DW, AW) quadtrans_inst(
        clk, rst,
        xin, yin, ain, in_last, in_valid, in_ready,
        x[0], y[0], a[0], l[0], v[0], r[0]);
    generate for(genvar i = 0; i < ITER; i++)
    begin : stages
        if(MODE == "ROT")
        begin : rot_stages
            CordicRotStage #(DW+1, AW+1, i) cordicStgs(clk, rst,
                x[i],   y[i],   a[i],   l[i],   v[i],   r[i],
                x[i+1], y[i+1], a[i+1], l[i+1], v[i+1], r[i+1]
            );
        end
        else if(MODE == "VEC")
        begin : vec_stages
            CordicVecStage #(DW+1, AW+1, i) cordicStgs(clk, rst,
                x[i],   y[i],   a[i],   l[i],   v[i],   r[i],
                x[i+1], y[i+1], a[i+1], l[i+1], v[i+1], r[i+1]
            );
        end
        else
        begin
            $fatal("Parameter \"MODE\" in module \"CordicDM\" must be \"ROT\" or \"VEC\"");
        end
    end    
    endgenerate

    wire scale_hs = v[ITER] & r[ITER];
    wire out_hs = out_valid & out_ready;
    assign r[ITER] = out_hs | ~out_valid;
    always_ff@(posedge clk) begin
        if(rst) out_valid <= 1'b0;
        else if(scale_hs) out_valid <= 1'b1;
        else if(out_ready) out_valid <= 1'b0;
    end
    localparam real lambda = 0.6072529350;
    wire signed [DW : 0] lam = lambda * 2**DW; // 0.607253(Q1.10)
    always_ff@(posedge clk) begin
        if(rst) begin
            xout <= 1'b0;
            yout <= 1'b0;
            aout <= 1'b0;
            out_last <= 1'b0;
        end
        else if(scale_hs) begin
            // Q2.(DW-1) * Q1.DW --> Q1.(DW-1)
            xout <= ((2*DW)'(x[ITER]) * lam) >>> DW;
            yout <= ((2*DW)'(y[ITER]) * lam) >>> DW;
            aout <= a[ITER] >>> 1;
            out_last <= l[ITER];
        end
    end
endmodule

module axi4s_cordic #(
    parameter string MODE = "ROT",      // "ROT" or "VEC"
    parameter integer DW = 12,
    parameter integer PAR = 1,
    parameter integer TDW = ((DW + 7) / 8) * 8
)(  
    input  wire clk, resetn,
    input  wire signed [TDW*3*PAR - 1 : 0]  s_axis_tdata,
    input  wire                             s_axis_tlast,
    input  wire                             s_axis_tvalid,
    output wire                             s_axis_tready,
    output logic signed [TDW*3*PAR - 1 : 0] m_axis_tdata,
    output logic                            m_axis_tlast,
    output logic                            m_axis_tvalid,
    input  wire                             m_axis_tready
);
    localparam integer PADW = TDW - DW;
    (* debug = "true" *) wire signed [DW-1:0] xin[PAR];
    (* debug = "true" *) wire signed [DW-1:0] yin[PAR];
    (* debug = "true" *) wire signed [DW-1:0] ain[PAR];
    (* debug = "true" *) wire signed [DW-1:0] xout[PAR];
    (* debug = "true" *) wire signed [DW-1:0] yout[PAR];
    (* debug = "true" *) wire signed [DW-1:0] aout[PAR];
    (* debug = "true" *) wire [PAR-1:0] in_ready;
    (* debug = "true" *) wire [PAR-1:0] out_last;
    (* debug = "true" *) wire [PAR-1:0] out_valid;
    assign s_axis_tready = &in_ready;
    assign m_axis_tvalid = &out_valid;
    assign m_axis_tlast = |out_last;
    generate
        for(genvar i = 0; i < PAR; i++) begin : parallel_units
            assign xin[i] = s_axis_tdata[(i*3+1)*TDW-1 -: DW];
            assign yin[i] = s_axis_tdata[(i*3+2)*TDW-1 -: DW];
            assign ain[i] = s_axis_tdata[(i*3+3)*TDW-1 -: DW];
            assign m_axis_tdata[(i*3)*TDW +: 3*TDW] = PADW ?
                    {aout[i], PADW'(0), yout[i], PADW'(0), xout[i], PADW'(0)} :
                    {aout[i], yout[i], xout[i]};
            CordicStr #(MODE, DW) cordic_inst(  
                clk, ~resetn,
                xin[i], yin[i], ain[i], s_axis_tlast, s_axis_tvalid & s_axis_tready, in_ready[i],
                xout[i], yout[i], aout[i], out_last[i], out_valid[i], m_axis_tready & m_axis_tvalid
            );
        end
    endgenerate

endmodule

`default_nettype wire
`endif

