`default_nettype none
`timescale 1ns/100ps

interface Axi4LiteIf #( parameter AW = 32)(
    input wire clk, reset_n
);
    logic [AW-1:0] awaddr;
    logic [2:0] awprot;
    logic awvalid = '0, awready;
    logic [31:0] wdata;
    logic [3:0] wstrb;
    logic wvalid = '0, wready;
    logic [1:0] bresp;
    logic bvalid = '0, bready;
    logic [AW-1:0] araddr;
    logic [2:0] arprot;
    logic arvalid = '0, arready;
    logic [31:0] rdata;
    logic [1:0] rresp;
    logic rvalid = '0, rready;
    modport master(
        input clk, reset_n,
        output awaddr, awprot, awvalid, input awready,
        output wdata, wstrb, wvalid, input wready,
        input bresp, bvalid, output bready,
        output araddr, arprot, arvalid, input arready,
        input rdata, rresp, rvalid, output rready
    );
    modport slave(
        input clk, reset_n,
        input awaddr, awprot, awvalid, output awready,
        input wdata, wstrb, wvalid, output wready,
        output bresp, bvalid, input bready,
        input araddr, arprot, arvalid, output arready,
        output rdata, rresp, rvalid, input rready
    );
//    task Write(
//        input logic [AW-1:0] addr, logic [31:0] data,
//        logic [31:0] strb = '1, logic [2:0] prot = '0
//    );
//        @(posedge clk) begin
//            awaddr = addr; awprot = prot; awvalid = '1;
//            wdata = data; wstrb = strb; wvalid = '1;
//            bready = '1;
//        end
//        fork
//            wait(awready) @(posedge clk) awvalid = '0;
//            wait(wready) @(posedge clk) wvalid = '0;
//            wait(bvalid) @(posedge clk) bready = '0;
//        join
//    endtask
//    task Read(
//        input logic [AW-1:0] addr, output logic [31:0] data,
//        input logic [3:0] prot = '0
//    );
//        @(posedge clk) begin
//            araddr = addr; arprot = prot; arvalid = '1;
//            rready = '1;
//        end
//        wait(arready) @(posedge clk) arvalid = '0;
//        wait(rvalid) @(posedge clk) begin
//            rready = '0;
//            data = rdata;
//        end
//    endtask
endinterface
