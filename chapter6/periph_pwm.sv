`default_nettype none
`timescale 1ns/100ps

module Pwm2 (
    input wire clk, rst,
    input wire [31 : 0] max,
    input wire [31 : 0] data,
    output logic pwm, co
);
    logic [31 : 0] cnt = '0;
    always_ff@(posedge clk) begin
        if(rst) cnt <= '0;
        else if(cnt < max) cnt <= cnt + 1'd1;
        else cnt <= '0;
    end
    always_ff@(posedge clk) pwm <= (data > cnt);
    assign co = cnt == max;
endmodule

module PeriphPwm (
    input wire clk, rst,
    input wire addr,
    input wire [31 : 0] wrdata,
    input wire write,
    output logic [31 : 0] rddata,
    output logic pwm, co
);
    logic [31 : 0] period, duty;
    always_ff@(posedge clk) begin
        if(rst) begin
            period <= '0;
            duty <= '0;
        end
        else if(write) begin
            case(addr)
            0: period <= wrdata;
            1: duty <= wrdata;
            endcase
        end
    end
    assign rddata = addr == 0 ? period : duty;
    Pwm2 thePwm(clk, rst, period, duty, pwm, co);
endmodule

module PeriphPwm2 (
    PicoMmIf.slave s,
    output logic pwm, co
);
    wire addr = s.addr >> 2;
    logic [31 : 0] period, duty;
    always_ff@(posedge s.clk) begin
        if(s.rst) begin
            period <= '0;
            duty <= '0;
        end
        else if(s.write) begin
            case(addr)
            0: period <= s.wrdata;
            1: duty <= s.wrdata;
            endcase
        end
    end
    always_ff@(posedge s.clk) s.rddata <= addr == 0 ? period : duty;
    Pwm2 thePwm(s.clk, s.rst, period, duty, pwm, co);
endmodule
    