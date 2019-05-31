`timescale 1ms/1us
`default_nettype none
`include "../Common.sv"
module TestStopWatchFsm;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 0.8, 1);
    initial GenRst(clk, rst, 1, 1);
    logic k0 = '0, k1 = '0;
    initial begin
        #200 KeyPress(k0, 50);  //start
        #450 KeyPress(k0, 50);  //pause
        #220 KeyPress(k1, 50);  //stop
        #260 KeyPress(k0, 50);  //start
        #450 KeyPress(k1, 50);  //freeze
        #680 KeyPress(k1, 50);  //freeze
        #990 KeyPress(k0, 50);  //run
        #220 KeyPress(k0, 50);  //pause
        #120 KeyPress(k1, 50);  //stop
        #100 $stop();
    end
    logic k0en, k1en;
    KeyProcess #(10, 2) key2en(clk, {k1, k0}, {k1en, k0en});
    logic t, f, r, u;
    StopWatchFsm sw_sm(clk, rst, k0en, k1en, t, f, r, u);
    logic en_10ms;
    Counter #(10) cntClk(clk, rst | r, t, , en_10ms);
    logic en_1sec, en_1min;
    logic [6:0] cnt_centisec;
    logic [5:0] cnt_sec;
    Counter #(100) cntCentiSec(clk, rst | r, en_10ms, cnt_centisec, en_1sec);
    Counter #(60) cntSec(clk, rst | r, en_1sec, cnt_sec, en_1min);
    logic [6:0] centisec;
    logic [5:0] sec;
    always@(posedge clk) begin
        if(rst) begin
            centisec <= 7'b0;
            sec <= 6'b0;
        end
        else if(~f | u) begin
            centisec <= cnt_centisec;
            sec <= cnt_sec;
        end
    end
endmodule

module StopWatchFsm(
    input wire clk, rst, k0, k1,
    output logic timming, freezing, reset, update
);
    localparam S_STOP = 4'h1;
    localparam S_RUN = 4'h2;
    localparam S_PAUSE = 4'h4;
    localparam S_FREEZE = 4'h8;
    logic [3:0] state, state_nxt;
    always_ff@(posedge clk) begin
        if(rst) state <= S_STOP;
        else state <= state_nxt;
    end
    always_comb begin
        state_nxt = state;
        case(state)
        S_STOP:
            if(k0) state_nxt = S_RUN;
        S_RUN:
            if(k0) state_nxt = S_PAUSE;
            else if(k1) state_nxt = S_FREEZE; 
        S_PAUSE:
            if(k0) state_nxt = S_RUN;
            else if(k1) state_nxt = S_STOP;
        S_FREEZE:
            if(k0) state_nxt = S_RUN;
            else if(k1) state_nxt = S_FREEZE;
        default: state_nxt = state;
        endcase
    end
    always_ff@(posedge clk)
        timming <= (state == S_RUN) || (state == S_FREEZE);
    always_ff@(posedge clk)
        freezing <= (state == S_FREEZE);
    always_ff@(posedge clk)
        reset <= k1 && (state == S_PAUSE);
    always_ff@(posedge clk)
        update <= k1 && (state == S_FREEZE);
endmodule
