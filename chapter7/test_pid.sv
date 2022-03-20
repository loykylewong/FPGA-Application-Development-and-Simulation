`include "../common.sv"
`include "../chapter4/counter.sv"
`include "./iir.sv"
`include "./dds.sv"
`include "../chapter4/pwm.sv"

`timescale 1ns/100ps
`default_nettype none

module TestPID;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 8000, 10000);
    initial GenRst(clk, rst, 2, 2);
    logic signed [11:0] des_amp = 10*2.0**7; //10V (Q5.7)
    logic signed [11:0] vfb;                 // Q5.7
    logic pwm;
    SimpleInverterCtrl inverterCtrl(
        clk, rst, 24'sd8389, 24'sd0, des_amp, pwm, vfb);
    logic signed [11:0] vpwr = 12*2.0**7;  //bridge supply 12V(Q5.7)
    wire signed [11:0] brg_out = pwm ? (vpwr) : (-vpwr);
    logic signed [39:0] lc_out; // Q5.35
    wire signed [39:0] lc_in = brg_out <<< 28; //Q5.7 -> Q5.35
    IIR #(40, 32, 1, '{ 7.59959214012339e-09 },            // g
        '{'{ 0,                  1, 0.999_946_334_773 }},  // num 0~2
        '{'{    -1.999_838_997_761, 0.999_839_012_960 }})  // den 1~2
        theLCFilter ( clk, rst, 1'b1, lc_in, lc_out );
    real inn_volt;
    assign inn_volt = lc_out / 2.0**35;
    real load_res = 10.0, inn_res = 0.5;
    real out_volt;
    assign out_volt = inn_volt * load_res / (load_res + inn_res);
    assign vfb = out_volt * 2.0**7;
    
    initial begin
        repeat(5_000_00) @(posedge clk);
        load_res = 5.0;       // load res from 10Ohm to 5.0Ohm
        repeat(10_000_00) @(posedge clk);
        des_amp = 5 * 2.0**7; // desire amp from 10V to 5V
        repeat(10_000_00) @(posedge clk);
        vpwr = 10*2.0**7;     // bridge supply from 12V to 10V
        repeat(20_000_00) @(posedge clk);
        $stop();
    end
endmodule
module SimpleInverterCtrl(
    input wire clk, rst,        // 100MHz
    input wire signed [23:0] freq,   // fout = freq * 100k / 2^24
    input wire signed [23:0] phase,  // phout = phase * PI / 2^23
    input wire signed [11:0] amp,    // desire amp(Q5.7)
    output logic spwm,          // spwm for half bridge
    input wire signed [11:0] volt_fb // Q5.7 feedback voltage
);
    logic en_100k;
    logic signed [11:0] sine;    //Q1.10
    DDS #( 24, 12, 14 ) theDDS(
        clk, rst, en_100k, freq, phase, sine );
    logic signed [11:0] sin_volt;    //Q5.7
    always_ff@(posedge clk) begin
        if(rst) sin_volt <= '0;
        else if(en_100k)
            sin_volt = (24'(sine) * amp) >>> 11;   //Q1.11*Q5.7->Q5.7
    end
    wire signed [11:0] v_err = sin_volt - volt_fb; //Q5.7
    wire signed [47:0] pid_in = v_err <<< 17;      //Q5.7->Q24.24
    logic signed [47:0] pid_out;
    Pid2 #( .W(36), .FW(24), .P(39), .I(2.35e5/100e3), .D(1.1e-3),
        .N(1.64e5), .TS(1/100e3), .LIMIT(1000) )
    thePid ( clk, rst, en_100k, pid_in, pid_out );
    wire signed [23:0] pid_out_int = pid_out[47:24];
    wire signed [9:0] duty = (pid_out_int >  10'sd500)?  10'sd500 :
                             (pid_out_int < -10'sd500)? -10'sd500 :
                                                       pid_out_int;
    PwmSigned #( .M(1000) ) thePwm(
        clk, rst, duty, spwm, en_100k);
endmodule
