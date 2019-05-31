`default_nettype none
interface membus #(
    parameter LEN = 256, DW = 8
)(
    input wire clk, input wire rst
);
    logic [$clog2(LEN) - 1 : 0] addr;
    logic [DW - 1 : 0] d, q;
    logic wr;
    modport master(
        output addr, d, wr,
        input clk, rst, q
    );
    modport slave(
        input clk, rst, addr, d, wr,
        output q
    );
endinterface

module mem #(
    parameter LEN = 256, DW = 8
)(membus.slave bus);

    logic [DW - 1 : 0] m[LEN] = '{LEN{'0}};
    always_ff@(posedge bus.clk) begin
        if(bus.rst) m <= '{LEN{'0}};
        else if(bus.wr) m[bus.addr] <= bus.d;
    end
	always_ff@(posedge bus.clk) begin
        if(bus.rst) bus.q <= '0;
        else bus.q <= m[bus.addr];
    end
endmodule

module mem_tester #(
    parameter LEN = 256, DW = 8
)(membus.master bus);
    initial bus.addr = '0;
    always@(posedge bus.clk) begin
        if(bus.rst) bus.addr <= '0;
        else bus.addr <= bus.addr + 1'b1;
    end
    assign bus.wr = 1'b1;
    assign bus.d = bus.addr;
endmodule

module testintf;
    logic clk = '0, rst = '0;
    always #5 clk = ~clk;
    initial begin
        #10 rst = '1;
        #20 rst = '0;
    end
    membus #(64,8) the_bus(clk, rst);
    mem_tester #(64,8) the_tester(the_bus);
    mem #(64,8) the_mem(the_bus); 
endmodule

