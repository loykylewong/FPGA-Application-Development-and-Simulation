`ifndef __IIC_MASTER_SV__
`define __IIC_MASTER_SV__

`include "../chapter4/edge2en.sv"

`default_nettype none
`timescale 1ns/100ps

interface IicBus;
    logic scl_i, scl_o, scl_t;
    logic sda_i, sda_o, sda_t;
endinterface

module IicMaster #(
    parameter real CLK_FREQ = 100e6,
    // max time: 1023 / CLK_FREQ
    // T_SSU: Setup time for repeat START
    // T_SSU + T_PH = MIN BUS IDLE
    // T_DSU + T_SCLH + T_DH = 1 / (BUS FREQ)
    // !!! Be sure T_DSU is the maximum one !!!
    parameter real T_SSU = 0.6e-6,                  T_SH = 0.6e-6,
    parameter real T_DSU = 1.3e-6, T_SCLH = 0.9e-6, T_DH = 0.3e-6,
    parameter real T_PSU = 0.6e-6,                  T_PH = 0.7e-6
)(
    input wire clk, rst,
    input wire [9:0] cmd_fifo_q,
    output logic cmd_fifo_rd,
    input wire cmd_fifo_empty,
    output logic [8:0] recv_fifo_data,
    output logic recv_fifo_wr,
    IicBus iic
);
    logic [1:0] iic_bit;
    logic bit_go, bit_idle;
    assign iic.scl_t = iic.scl_o;
    assign iic.sda_t = iic.sda_o;
    IicMasterByteEngine theByteEngine (
        .clk(clk), .rst(rst),
        .fifo_q(cmd_fifo_q), .fifo_rd(cmd_fifo_rd),
        .fifo_empty(cmd_fifo_empty),
        .iic_bit(iic_bit), .bit_go(bit_go), .bit_idle(bit_idle),
        .w9bit_end(recv_fifo_wr)
    );
    IicMasterBitEngine #(
        .CLK_FREQ(CLK_FREQ),
        .T_SSU(T_SSU),                  .T_SH(T_SH),
        .T_DSU(T_DSU), .T_SCLH(T_SCLH), .T_DH(T_DH),
        .T_PSU(T_PSU),                  .T_PH(T_PH)
    ) theBitEngine (
        .clk(clk), .rst(rst),
        .iic_bit(iic_bit), .go(bit_go), .idle(bit_idle),
        .scl_out(iic.scl_o), .sda_out(iic.sda_o), .scl(iic.scl_i)
    );
    IicMasterRecvShifter recv_shift_inst (
        .clk(clk), .rst(rst), .scl(iic.scl_i), .sda(iic.sda_i),
        .shifter(recv_fifo_data)
    );
endmodule

module IicMasterRecvShifter (
    input wire clk, rst,
    input wire scl, sda,
    output logic [8:0] shifter = '0
);
    logic scl_dly = 1'b1;
    wire scl_falling = (scl_dly & ~scl);
    always_ff@(posedge clk) begin
        if(rst) scl_dly <= 1'b1;
        else    scl_dly <= scl;
    end
    always_ff@(posedge clk) begin
        if(scl_falling) shifter <= {shifter[7:0], sda};
    end
endmodule

module IicMasterBitEngine #(
    parameter real CLK_FREQ = 100e6,
    parameter real T_SSU = 0.6e-6,                  T_SH = 0.6e-6,
    parameter real T_DSU = 1.3e-6, T_SCLH = 0.9e-6, T_DH = 0.3e-6,
    parameter real T_PSU = 0.6e-6,                  T_PH = 0.7e-6
)(
    input wire clk, rst,
    // iic_bit: 00: clr dat; 01: rls dat; 10: start; 11: stop
    input wire [1:0] iic_bit,
    input wire go,
    output logic idle,
    input wire scl,
    output logic scl_out, sda_out
);    
    wire [9:0] t_ssu_limit  = (CLK_FREQ * T_SSU);
    wire [9:0] t_sh_limit   = (CLK_FREQ * T_SH);
    wire [9:0] t_dsu_limit  = (CLK_FREQ * T_DSU);
    wire [9:0] t_sclh_limit = (CLK_FREQ * T_SCLH);
    wire [9:0] t_dh_limit   = (CLK_FREQ * T_DH);
    wire [9:0] t_psu_limit  = (CLK_FREQ * T_PSU);
    wire [9:0] t_ph_limit   = (CLK_FREQ * T_PH);
    logic [$clog2(integer'(CLK_FREQ * T_DSU + 1)) - 1 : 0] t_cnt = '0;
    // sda: ^^^\_________X==============...X___________/^^^
    // scl: ^^^^^^^\__________/^^^^^\___..._______/^^^^^^^^
    //      SSU  SH  S_DH  DSU  SCLH  DH     P_DSU  PSU  PH
    localparam S_IDLE = 4'd0;
    localparam S_SSU  = 4'd1, S_SH   = 4'd2, S_SDH = 4'd3;
    localparam S_DSU  = 4'd4, S_SCLH = 4'd5, S_DH  = 4'd6;
    localparam S_PDSU = 4'd7, S_PSU  = 4'd8, S_PH  = 4'd9;
    logic [3:0] state = S_IDLE, state_nxt = S_IDLE;
    assign idle = (state == S_IDLE) | (state_nxt == S_IDLE);
    always_ff@(posedge clk) begin
        if(rst) state <= S_IDLE;
        else state <= state_nxt;
    end
    always_comb begin
        state_nxt = state;
        case(state)
        S_IDLE:
            if(go) begin
                if(iic_bit == 2'b10) state_nxt = S_SSU;
                else if(iic_bit == 2'b11) state_nxt = S_PDSU;
                else state_nxt = S_DSU;
            end
        S_SSU:  if(t_cnt == t_ssu_limit -4'h1) state_nxt = S_SH;
        S_SH:   if(t_cnt == t_sh_limit  -4'h1) state_nxt = S_SDH;
        S_SDH:  if(t_cnt == t_dh_limit  -4'h5) state_nxt = S_IDLE;
        S_PDSU: if(t_cnt == t_dsu_limit -4'h1) state_nxt = S_PSU;
        S_PSU:  if(t_cnt == t_psu_limit -4'h1) state_nxt = S_PH;
        S_PH:   if(t_cnt == t_ph_limit  -4'h5) state_nxt = S_IDLE;
        S_DSU:  if(t_cnt == t_dsu_limit -4'h1) state_nxt = S_SCLH;
        S_SCLH: if(t_cnt == t_sclh_limit-4'h1) state_nxt = S_DH;
        S_DH:   if(t_cnt == t_dh_limit  -4'h2) state_nxt = S_IDLE;
        default: state_nxt = S_IDLE;
        endcase
    end
    always_ff@(posedge clk) begin
        if(rst) t_cnt <= 1'b0;
        else begin
            if((state == S_IDLE) || (state_nxt != state))
                t_cnt <= 1'b0;
            else if(scl == scl_out) // clk sync
                t_cnt <= t_cnt + 1'b1;
        end
    end
    always_ff@(posedge clk) begin
        if(rst) begin scl_out <= 1'b1; sda_out <= 1'b1; end
        else begin
            case(state_nxt)
            S_SSU: begin scl_out <= 1'b1; sda_out <= 1'b1; end
            S_SH:  begin scl_out <= 1'b1; sda_out <= 1'b0; end
            S_SDH: begin scl_out <= 1'b0; sda_out <= 1'b0; end
            S_PDSU:begin scl_out <= 1'b0; sda_out <= 1'b0; end
            S_PSU: begin scl_out <= 1'b1; sda_out <= 1'b0; end
            S_PH:  begin scl_out <= 1'b1; sda_out <= 1'b1; end
            S_DSU: begin scl_out <= 1'b0; sda_out <= iic_bit[0]; end
            S_SCLH:begin scl_out <= 1'b1; sda_out <= iic_bit[0]; end
            S_DH:  begin scl_out <= 1'b0; sda_out <= iic_bit[0]; end
            endcase
        end
    end
endmodule

// byte             means 
// 0_XXXXXXXX_1     write byte & read ack / nak
// 0_XXXXXXXX_0     write byte & write ack
// 0_11111111_0     read byte & write ack
// 0_11111111_1     read byte & read ack / nak
// 1_0XXXXXXX_X     generate start
// 1_1XXXXXXX_X     generate stop
module  IicMasterByteEngine (
    input wire clk, rst,
    input wire [9:0] fifo_q,
    output logic fifo_rd,
    input wire fifo_empty,
    output logic [1:0] iic_bit,
    output logic bit_go,
    input wire bit_idle,
    output logic w9bit_end
);
    localparam S_IDLE      = 3'd0;
    localparam S_RDFIFO    = 3'd1;
    localparam S_CASE      = 3'd2;
    localparam S_1BIT_WR   = 3'd3;
    localparam S_1BIT_WAIT = 3'd4;
    localparam S_9BIT_WR   = 3'd5;
    localparam S_9BIT_WAIT = 3'd6;
    logic [8:0] data = 9'b0;
    logic [3:0] bit_cnt = 4'b0;
    logic [2:0] state = S_IDLE, state_nxt = S_IDLE;
    always_ff@(posedge clk) begin
        if(rst) state <= S_IDLE;
        else state <= state_nxt;
    end
    always_comb begin
        state_nxt = state;
        case(state)
        S_IDLE: if(~fifo_empty)     state_nxt = S_RDFIFO;
        S_RDFIFO:                   state_nxt = S_CASE;
        S_CASE: if(fifo_q[9])       state_nxt = S_1BIT_WR;
                else                state_nxt = S_9BIT_WR;
        S_1BIT_WR:                  state_nxt = S_1BIT_WAIT;
        S_1BIT_WAIT: if(bit_idle)   state_nxt = S_IDLE;
        S_9BIT_WR:                  state_nxt = S_9BIT_WAIT;
        S_9BIT_WAIT:
            if(bit_idle) begin
                if(bit_cnt == 4'h8) state_nxt = S_IDLE;
                else                state_nxt = S_9BIT_WR;
            end
        default:                    state_nxt = S_IDLE;
        endcase
    end
    assign fifo_rd = (state == S_RDFIFO);
    always_ff@(posedge clk) begin
        if(state == S_CASE) begin
            data <= fifo_q[8:0];
            bit_cnt <= 4'b0;
        end
        else if(state == S_9BIT_WAIT && state_nxt == S_9BIT_WR) begin
            data <= {data[7:0], 1'b1};
            bit_cnt <= bit_cnt + 1'b1;
        end
    end
    always_comb begin
        if(state == S_1BIT_WR || state == S_9BIT_WR) bit_go = 1'b1;
        else                                         bit_go = 1'b0;
    end
    always_comb begin
        if(state == S_1BIT_WR || state == S_1BIT_WAIT)
            iic_bit = {1'b1, data[8]};
        else/* if(state == S_9BIT_WR || state == S_9BIT_WAIT)*/
            iic_bit = {1'b0, data[8]};
    end
    assign w9bit_end = (state == S_9BIT_WAIT && state_nxt == S_IDLE);
endmodule

`endif
