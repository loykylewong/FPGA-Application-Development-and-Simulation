`ifndef __MM_INTERCON_SV__
`define __MM_INTERCON_SV__

`default_nettype none
`timescale 1ns/100ps

interface PicoMmIf#(parameter AW = 16)( input wire clk, rst );
    logic [AW-1:0] addr;
    logic write; logic [31:0] wrdata;
    logic read; logic [31:0] rddata;
    modport master(input clk, rst, rddata,
        output addr, write, wrdata, read);
    modport slave(input clk, rst, addr, write, wrdata, read,
        output rddata);
    task automatic Write(
        input logic [31:0] a, input logic [31:0] d);
        addr = a; wrdata = d; write = 1'b1;
        @(posedge clk) write = 1'b0;
    endtask
    task automatic Read(
        input logic [31:0] a);
        addr = a; read = 1'b1;
        @(posedge clk) read = 1'b0;
    endtask
endinterface

module PicoMmInterconnector1to3 (
    PicoMmIf.slave s,
    PicoMmIf.master m[3]
);
    assign m[0].wrdata = s.wrdata;
    assign m[1].wrdata = s.wrdata;
    assign m[2].wrdata = s.wrdata;
    always_comb begin
        casez(s.addr)
        32'h0000_????: begin
            m[0].write = s.write;
            m[0].read = s.read;
            m[0].addr = s.addr[m[0].AW-1:0];
        end
        32'h0001_000?: begin
            m[1].write = s.write;
            m[1].read = s.read;
            m[1].addr = s.addr[m[1].AW-1:0];
        end
        32'h0001_001?: begin
            m[2].write = s.write;
            m[2].read = s.read;
            m[2].addr = s.addr[m[2].AW-1:0];
        end
        default: begin
            m[2].write = '0;
            m[2].read = '0;
            m[2].addr = '0;
        end
        endcase
    end
    logic [31:0] addr_reg;
    always_ff@(posedge s.clk) addr_reg <= s.addr;
    always_comb begin
        casez(addr_reg)
        32'h0000_????: s.rddata = m[0].rddata;
        32'h0001_000?: s.rddata = m[1].rddata;
        32'h0001_001?: s.rddata = m[2].rddata;
        default: s.rddata = '0;
        endcase
    end
endmodule

module PicoMmIntercon #(
    parameter M_NUM = 4,
    parameter [31:0] BA[M_NUM]
)(
    PicoMmIf.slave s, PicoMmIf.master m[M_NUM]
);
    logic [M_NUM-1 : 0] sel, sel_reg;
    always_ff@(posedge s.clk) sel_reg <= sel;
    logic [31:0] rddata[M_NUM];
    generate
        for(genvar i = 0; i < M_NUM; i++) begin
            always@(*) begin
                sel[i] = s.addr[31 : m[i].AW] == BA[i][31 : m[i].AW];
                m[i].addr = s.addr[m[i].AW - 1 : 0];
                m[i].wrdata = s.wrdata;
                m[i].write = s.write & sel[i];
                m[i].read = s.read & sel[i];
                rddata[i] = m[i].rddata;
            end
        end
    endgenerate
    always_comb begin
        s.rddata = '0;
        for(int i = 0; i < M_NUM; i++) begin
            if(sel_reg[i]) s.rddata = rddata[i];
        end
    end
endmodule
            
`endif
