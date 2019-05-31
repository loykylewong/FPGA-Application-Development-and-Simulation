`include "../common.sv"
`include "../chapter4/memory.sv"

`default_nettype none
`timescale 1ns/100ps

module TestPicoMmIf;
    import SimSrcGen::*;
    logic clk, rst;
    initial GenClk(clk, 8, 10);
    initial GenRst(clk, rst, 1, 1);
    PicoMmIf #(32) pico_cu2ic(clk, rst);
    PicoMmIf pico_ic2per[3](clk, rst);
    defparam pico_ic2per[0].AW = 16;
    defparam pico_ic2per[1].AW = 4;
    defparam pico_ic2per[2].AW = 4;
    PicoMmIntercon #(3,
       '{32'h0000_0000, 32'h0001_0000, 32'h0001_0010})
    theIc( pico_cu2ic, pico_ic2per);
    SpRamRf #(32, 16384) theMem( pico_ic2per[0].clk,
        pico_ic2per[0].addr[15:2], pico_ic2per[0].write,
        pico_ic2per[0].wrdata, pico_ic2per[0].rddata);
    logic pwm, co;
    PeriphPwm2 thePwm(pico_ic2per[1], pwm, co);
    logic sclk0, sclk1, mosi, mosi_tri, miso = '1, busy;
    logic [23:0] ss_n;
    PeriphSpiMaster3 theSpim(pico_ic2per[2],
        sclk0, sclk1, mosi, mosi_tri, miso, ss_n, busy);
    initial begin
        repeat(10) @(posedge clk);
        // ==== test memory ====
        // write 2 data
        pico_cu2ic.Write(32'h0000_0c00, 32'h1234_5678);
        pico_cu2ic.Write(32'h0000_0c04, 32'h9abc_edf0);
        // read 2 data
        pico_cu2ic.Read(32'h0000_0c00);
        pico_cu2ic.Read(32'h0000_0c04);
        // ==== test pwm ====
        // set period = 100 clks, duty = 33%
        pico_cu2ic.Write(32'h0001_0000, 32'd99);
        pico_cu2ic.Write(32'h0001_0004, 32'd33);
        // read settings
        pico_cu2ic.Read(32'h0001_0000);
        pico_cu2ic.Read(32'h0001_0004);
        // ==== test spi ====
        // prepare 2 data in tx fifo
        pico_cu2ic.Write(32'h0001_0010, 32'h7c);
        pico_cu2ic.Write(32'h0001_0010, 32'h5b);
        // start transaction
        pico_cu2ic.Write(32'h0001_0014, 32'h01_000001);
        // wait while SpiMaster busy
        do begin
            pico_cu2ic.Read(32'h0001_0018);
            @(posedge clk);
        end while( pico_cu2ic.rddata[16] );
        // read data from rx fifo
        pico_cu2ic.Read(32'h0001_0010);
        pico_cu2ic.Read(32'h0001_0010);
        repeat(100) @(posedge clk);
        $stop();
    end
endmodule
