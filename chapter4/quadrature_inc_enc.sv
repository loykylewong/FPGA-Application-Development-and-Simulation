`timescale 1ns/1ps
`default_nettype none
`include "../Common.sv"
module TestQuadEncIf;
    import SimSrcGen::*;
    task automatic QuadEncGo(ref logic a, b, input logic ccw, realtime qprd);
        a = 0; b = 0;
        if(!ccw) begin
            #qprd a = 1; #qprd b = 1; #qprd a = 0; #qprd b = 0;
        end
        else begin
            #qprd b = 1; #qprd a = 1; #qprd b = 0; #qprd a = 0;
        end
    endtask
    logic a0 = '0, b0 = '0, a1 = '0, b1 = '0;
    initial begin
        for(int i = 0; i < 40; i++) QuadEncGo(a0, b0, 0, 100);
        for(int i = 0; i < 50; i++) QuadEncGo(a0, b0, 1, 80);
        #1000 $stop();
    end
    initial begin
        for(int i = 0; i < 30; i++) QuadEncGo(a1, b1, 0, 133.333);
        for(int i = 0; i < 40; i++) QuadEncGo(a1, b1, 1, 100);
    end
    logic clk, rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 1, 1);
    logic [7:0] acc0, acc1;
    logic acc_valid;
    QuadEncIf #(2, 8, 1000) theQei(clk, rst, '{a1, a0}, '{b1, b0}, '{acc1, acc0}, acc_valid);
endmodule

module QuadEncIf #(
    parameter CH = 1,
    parameter ACCW = 16,
    parameter SMP_INTV = 1_000_000
)(
    input wire clk, rst,
    input wire a[CH], b[CH],
    output logic signed [ACCW - 1 : 0] acc[CH],
    output logic acc_valid
);
    logic co;
    Counter #(SMP_INTV) theIntvCnt(clk, rst, 1'b1, , co);
    logic [1:0] a_reg[CH], b_reg[CH];
    logic a_rising[CH], a_falling[CH], b_rising[CH], b_falling[CH];
    logic [ACCW - 1 : 0] iacc[CH];
    generate
        for(genvar ch = 0; ch < CH; ch++) begin : channel
            always_ff@(posedge clk) begin
                if(rst) begin
                    a_reg[ch] <= 2'b00; b_reg[ch] <= 2'b00;
                end
                else begin
                    a_reg[ch] <= {a_reg[ch][0], a[ch]};
                    b_reg[ch] <= {b_reg[ch][0], b[ch]};
                end
            end
            assign a_rising[ch]  = a_reg[ch] == 2'b01;
            assign a_falling[ch] = a_reg[ch] == 2'b10;
            assign b_rising[ch]  = b_reg[ch] == 2'b01;
            assign b_falling[ch] = b_reg[ch] == 2'b10;
            always_ff@(posedge clk) begin
                if(rst) iacc[ch] <= '0;
                else if(co) iacc[ch] <= '0;
                else if(a_rising[ch]) iacc[ch] <= iacc[ch] + (b_reg[ch][0]?-1:1);
                else if(a_falling[ch]) iacc[ch] <= iacc[ch] + (b_reg[ch][0]?1:-1);
                else if(b_rising[ch]) iacc[ch] <= iacc[ch] + (a_reg[ch][0]?1:-1);
                else if(b_falling[ch]) iacc[ch] <= iacc[ch] + (a_reg[ch][0]?-1:1);
            end
            always_ff@(posedge clk) begin
                if(rst) acc[ch] <= '0;
                else if(co) acc[ch] <= iacc[ch];
            end
        end
    endgenerate
    always_ff@(posedge clk) acc_valid <= co;
endmodule
