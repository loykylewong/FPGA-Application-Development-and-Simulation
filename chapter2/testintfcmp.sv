`default_nettype none
module mem #(
    parameter LEN = 256, DW = 8
)(
    input wire clk, rst,
    input wire [$clog2(LEN) - 1 : 0] addr,
    input wire [DW - 1 : 0] d,
    input wire wr,
    output logic [DW - 1 : 0] q
);
    logic [DW - 1 : 0] m[LEN] = '{LEN{'0}};
    always_ff@(posedge clk) begin
        if(rst) m <= '{LEN{'0}};
        else if(wr) m[addr] <= d;
    end
    always_ff@(posedge clk) begin
        if(rst) q <= '0;
        else q <= m[addr];
    end
endmodule

module mem_tester #(
    parameter LEN = 256, DW = 8
)( 
    input wire clk, rst,
    output logic [$clog2(LEN) - 1 : 0] addr,
    output logic [DW - 1 : 0] d, 
    output logic wr,
    input wire [DW - 1 : 0] q
);
    initial addr = '0;
    always@(posedge clk) begin
        if(rst) addr <= '0;
        else addr <= addr + 1'b1;
    end
    assign wr = 1'b1;
    assign d = DW'(addr);
endmodule

module testintfcmp;
    logic clk = '0, rst = '0;
    always #5 clk = ~clk;
    initial begin
        #10 rst = '1;
        #20 rst = '0;
    end
    logic [5:0] addr;
    logic [7:0] d, q;
    logic wr;
    mem_tester #(64,8) the_tester(clk, rst, addr, d, wr, q);
    mem #(64,8) the_mem(clk, rst, addr, d, wr, q); 
endmodule

