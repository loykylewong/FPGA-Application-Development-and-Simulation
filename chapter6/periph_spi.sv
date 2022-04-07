`include "../chapter5/spi.sv"
`include "../chapter4/scfifo.sv"
`default_nettype none
`timescale 1ns/100ps
    
module PeriphSpiMaster(
    input wire clk, rst,
    input wire addr,
    input wire [31:0] wrdata,
    input wire write,
    output logic [31:0] rddata,
    input wire read,
    output logic sclk0, sclk1, mosi, mosi_tri,
    input wire miso,
    output logic [23:0] ss_n,
    output logic busy
);
    logic start, txf_write, txf_read, rxf_write, rxf_read;
    logic [23:0] ss;
    logic [7:0] tx_len;
    logic [7:0] txf_din, txf_dout, rxf_din, rxf_dout;
    SpiMaster theSpiMaster(clk, rst, start, ss, tx_len,
        txf_read, txf_dout, rxf_write, rxf_din,
        busy, sclk0, sclk1, mosi, mosi_tri, miso, ss_n);
    ScFifo2 #(8, 8) tx_fifo(
        clk, rst, txf_din, txf_write, txf_dout, txf_read, , , , , );
    ScFifo2 #(8, 8) rx_fifo(
        clk, rst, rxf_din, rxf_write, rxf_dout, rxf_read, , , , , ); 
    // write addr 0
    assign txf_write = write & (addr == 0);
    assign txf_din = wrdata[7:0];
    // write addr 1
    always_ff@(posedge clk) begin
        if(rst) {tx_len, ss} <= '0;
        else if(write && (addr == 1)) {tx_len, ss} <= wrdata;
    end
    always_ff@(posedge clk) start <= (write && (addr == 1));
    // read
    logic addr_reg;
    always_ff@(posedge clk) addr_reg <= addr;
    assign rxf_read = read & (addr == 0);
    assign rddata = addr_reg ? {tx_len, ss} : rxf_dout;
endmodule

module PeriphSpiMaster2(
    input wire clk, rst,
    input wire [1:0] addr,
    input wire [31:0] wrdata,
    input wire write,
    output logic [31:0] rddata,
    input wire read,
    output logic sclk0, sclk1, mosi, mosi_tri,
    input wire miso,
    output logic [23:0] ss_n,
    output logic busy
);
    logic start, txf_write, txf_read, rxf_write, rxf_read;
    logic [23:0] ss;
    logic [7:0] tx_len;
    logic [7:0] txf_din, txf_dout, rxf_din, rxf_dout;
    logic [7:0] txf_dc, rxf_dc;
    SpiMaster theSpiMaster(clk, rst, start, ss, tx_len,
        txf_read, txf_dout, rxf_write, rxf_din,
        busy, sclk0, sclk1, mosi, mosi_tri, miso, ss_n);
    ScFifo2 #(8, 8) tx_fifo(
        clk, rst, txf_din, txf_write, txf_dout, txf_read, , , txf_dc, , );
    ScFifo2 #(8, 8) rx_fifo(
        clk, rst, rxf_din, rxf_write, rxf_dout, rxf_read, , , rxf_dc, , ); 
    // write addr 0
    assign txf_write = write & (addr == 0);
    assign txf_din = wrdata[7:0];
    // write addr 1
    always_ff@(posedge clk) begin
        if(rst) {tx_len, ss} <= '0;
        else if(write && (addr == 1)) {tx_len, ss} <= wrdata;
    end
    always_ff@(posedge clk) start <= (write && (addr == 1));
    // read
    logic [1:0] addr_reg;
    always_ff@(posedge clk) addr_reg <= addr;
    assign rxf_read = read & (addr == 0);
    always_comb begin
        case(addr_reg)
        0: rddata = rxf_dout;
        1: rddata = {tx_len, ss};
        2: rddata = {busy, rxf_dc, txf_dc};
        default: rddata = '0;
        endcase 
    end
endmodule

module PeriphSpiMaster3(
    PicoMmIf.slave s,
    output logic sclk0, sclk1, mosi, mosi_tri,
    input wire miso,
    output logic [23:0] ss_n,
    output logic busy
);
    wire [1:0] addr = s.addr >> 2;
    logic start, txf_write, txf_read, rxf_write, rxf_read;
    logic [23:0] ss;
    logic [7:0] tx_len;
    logic [7:0] txf_din, txf_dout, rxf_din, rxf_dout;
    logic [7:0] txf_dc, rxf_dc;
    SpiMaster theSpiMaster(s.clk, s.rst, start, ss, tx_len,
        txf_read, txf_dout, rxf_write, rxf_din,
        busy, sclk0, sclk1, mosi, mosi_tri, miso, ss_n);
    ScFifo2 #(8, 8) tx_fifo(
        s.clk, s.rst, txf_din, txf_write, txf_dout, txf_read, , , txf_dc, , );
    ScFifo2 #(8, 8) rx_fifo(
        s.clk, s.rst, rxf_din, rxf_write, rxf_dout, rxf_read, , , rxf_dc, , ); 
    // write addr 0
    assign txf_write = s.write & (addr == 0);
    assign txf_din = s.wrdata[7:0];
    // write addr 1
    always_ff@(posedge s.clk) begin
        if(s.rst) {tx_len, ss} <= '0;
        else if(s.write & (addr == 1)) {tx_len, ss} <= s.wrdata;
    end
    always_ff@(posedge s.clk) start <= (s.write && (addr == 1));
    // read
    logic [1:0] addr_reg;
    always_ff@(posedge s.clk) addr_reg <= addr;
    assign rxf_read = s.read & (addr == 0);
    always_comb begin
        case(addr_reg)
        0: s.rddata = rxf_dout;
        1: s.rddata = {tx_len, ss};
        2: s.rddata = {busy, rxf_dc, txf_dc};
        default: s.rddata = '0;
        endcase
    end
endmodule
