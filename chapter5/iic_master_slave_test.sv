`include "../common.sv"
`include "../chapter4/scfifo.sv"
`include "../chapter4/memory.sv"

`default_nettype none
`timescale 1ns/100ps

module TestIicMasterSlave;
    import SimSrcGen::*;
    logic clk;
    initial GenClk(clk, 8, 10);
    logic rst;
    initial GenRst(clk, rst, 1, 2);
    // ======== iic wires ========
    wire scl, sda;
    pullup resScl(scl), resSda(sda);// pull up resistor or current source
    // ======== master side ========
    logic cfifo_write='0, cfifo_read, cfifo_empty;
    logic dfifo_write, dfifo_read='0;
    logic [9:0] cfifo_din, cfifo_dout;
    logic [8:0] dfifo_din, dfifo_dout;
    logic [5:0] dfifo_dc;
    ScFifo2 #(10, 6) theCmdFifo(
        clk, rst, cfifo_din, cfifo_write, cfifo_dout, cfifo_read,
         , , , , cfifo_empty);
    ScFifo2 #(9, 6) theDataFifo(
        clk, rst, {dfifo_din[0], dfifo_din[8:1]}, dfifo_write, dfifo_dout, dfifo_read,
         , , dfifo_dc, , );
    IicBus miic();
    assign scl = miic.scl_t ? 'z : miic.scl_o;
    assign sda = miic.sda_t ? 'z : miic.sda_o;
    assign miic.scl_i = scl, miic.sda_i = sda;
    IicMaster theMas(clk, rst, cfifo_dout, cfifo_read, cfifo_empty,
        dfifo_din, dfifo_write, miic);
    initial begin
        repeat(100) @(posedge clk);
        // access nonpresent slave
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b1_0000_0000_0}; // start
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_1011011_0_1}; // sa=0x5b, wr, read ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_0011_1001_1}; // any data, read ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b1_1000_0000_0}; // stop
        // access the slave, write 0xc9, 0x65 to 0x39, 0x3a
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b1_0000_0000_0}; // start
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_1011010_0_1}; // sa=0x5a, wr, read ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_0011_1001_1}; // ia=0x39, read ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_1100_1001_1}; // data=0xc9, read ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_0110_0101_1}; // data=0x65, read ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b1_1000_0000_0}; // stop
        // access the slave, read data from 0x39
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b1_0000_0000_0}; // start
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_1011010_0_1}; // sa=0x5a, wr, read ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_0011_1001_1}; // ia=0x39, read ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b1_0000_0000_0}; // repeat start
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_1011010_1_1}; // sa=0x5a, rd, read ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_1111_1111_0}; // read data, send ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_1111_1111_0}; // read data, send ack
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b0_1111_1111_1}; // read data, send nak
        @(posedge clk) {cfifo_write, cfifo_din}
                     = {1'b1, 10'b1_1000_0000_0}; // stop
        @(posedge clk) cfifo_write = 1'b0;
    end
    initial begin
        wait(dfifo_dc >= 6'd12);
        repeat(12) begin
            @(posedge clk) dfifo_read = 1'b1;
        end
        @(posedge clk) dfifo_read = 1'b0;
        repeat(1000) @(posedge clk);
        $stop();
    end
    // ======== slave side ========
    logic [7:0] iaddr, iwrdata, irddata;
    logic iwr, ird;
    SpRamRf #(8, 256) innerRam(clk, iaddr, iwr, iwrdata, irddata);
    initial innerRam.ram = '{256{'0}};
    IicBus siic();
    assign scl = siic.scl_t ? 'z : siic.scl_o;
    assign sda = siic.sda_t ? 'z : siic.sda_o;
    assign siic.scl_i = scl, siic.sda_i = sda;
    IicSlave #(8'h5a, 8)theSla(clk, rst, siic, iaddr, iwrdata, iwr, irddata, ird);
endmodule
