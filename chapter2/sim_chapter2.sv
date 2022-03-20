`default_nettype none
module test_chapter2;
    code2_39 inst_code2();
endmodule

module code2_9;

logic [3:0] a = 4'he;
logic [1:0] b = a;                         //b=2'b10
logic [5:0] c = a;                         //c=6'b001110
logic [5:0] d = 6'(a);                     //??
logic [5:0] e = 6'($signed(a));            //e=6'b111110
logic signed [7:0] f = 4'sd5 * a;          //f=70
logic signed [7:0] g = 4'sd5 * $signed(a); //g=-10

endmodule

module code2_10;

logic [3:0] a = 4'hF;
logic [5:0] b = 6'h3A;
logic [11:0] c = {a*b};      //c???38
logic [11:0] d = a*b;        //d???870
logic signed [15:0] a0 = 16'sd30000, a1 = 16'sd20000;
logic signed [15:0] sum0 = (a0 + a1) >>> 1;           //sum0=-7768
logic signed [15:0] sum1 = (17'sd0 + a0 + a1) >>> 1;  //sum1=25000
logic signed [15:0] sum2 = (17'(a0) + a1) >>> 1;      //sum2=25000

endmodule

module code2_11;
parameter logic signed [3:0] pa = -4'sd6;
const logic signed [3:0] pb = -4'sd6;
logic [7:0] a = 8'd250;                      //8'd250=8'hFA
logic signed [3:0] b = -4'sd6;               //-4'sd6(4'hA)
logic c = a == b;                            //c=0
logic d = a == -4'sd6;                       //d=1
logic pc = a == pa;
logic pd = a == pb;
logic e = 8'sd0 > b;                         //e=1
logic f = 8'd0 < b;                          //f=1
logic [7:0] prod0 = 4'd9 * -4'sd7;           //prod0=193
logic signed [7:0] prod1 = 4'd9 * -4'sd7;    //prod1=-63
logic [7:0] prod2 = 8'd5 * b;                //prod2=50
logic [7:0] prod3 = 8'd5 * -4'sd6;           //prod3=226

endmodule

module code2_12;
logic [15:0] a = 16'h5e39;               //16'b0101_1110_0011_1001
logic b = a[15], c = a['ha];             //b=1'b0, c=1'b1
logic [3:0] d = a[11:8], e = a[13:10];   //d=4'b1110, e=4'b0111
logic [7:0] f = a[7:0],  g = a[2*4:1];   //f=8'h39, g=8'b0001_1100
logic [7:0] h = a[4+:8], i = a[15-:8];   //h=8'he3, i=8'h5e
logic [3:0] j;
//logic [2:0] k = a[j+2:j];           //???????????????
logic [2:0] l = a[j+:3];            //??i=3, j=3'b111
initial begin
a[7:4] = 4'h9;                      //a=16'h5e99
a[4] = 1'b0;                        //a=16'h5e89
end
endmodule

module code2_13;
logic [7:0] a = 8'hc2;                //a=1100_0010
logic signed [3:0] b = -4'sh6;        //b=4'b1010=4'ha
logic [11:0] c = {a, b};              //c=12'hc2a
logic [15:0] d = {3'b101, b, a, 1'b0};//d=16'b101_1010_1100_0010_0
logic [63:0] e = {4*4{b}};            //e=64'haaaa_aaaa_aaaa_aaaa
logic [17:0] f = {3{b, 2'b11}};       //f=18'b101011_101011_101011
logic [15:0] g = {a, {4{2'b01}}};     //g=16'hc255
initial begin
{a, b} = 12'h9bf;                     //a=8'h9b, b=4'hf=-4'sh1
end
endmodule

module code2_14;
logic [15:0] a = 16'h37bf;    //16'b0011_0111_1011_1111
logic [15:0] b = {>>{a}};     //b=16'h37bf
logic [15:0] c = {<<{a}};     //c=16'hfdec=16'b1111_1101_1110_1100
logic [19:0] d = {<<{4'ha, a}};  //d=16'hfdec5
logic [15:0] e = {<< 4 {a}};     //e=16'hfb73
logic [15:0] f = {<< 8 {a}};     //f=16'hbf37
logic [15:0] g = {<< byte {a}};  //g=16'hbf37
logic [8:0] h = {<< 3 {{<< {9'b110011100}}}};   //h=9'b011_110_001
logic [3:0] i;
initial begin
{<<{i}} = 4'b1011;               //i=4'b1101
{<< 2 {i}} = 4'b1011;            //i=4'b1110
end
endmodule

module code2_15;
logic [7:0] a = 8'h9c;           //  8'b10011100 = 156
logic signed [7:0] b = -8'sh64;  //  8'b10011100 = -100
logic [7:0] c = a << 2;          //c=8'b01110000
logic [7:0] d = b << 2;          //d=8'b01110000
logic [7:0] e = b <<< 2;         //e=8'b01110000
logic [7:0] f = b >> 2;          //f=8'b00100111 = 39 
logic [7:0] g = a >>> 2;         //g=8'b00100111 = 39
logic [7:0] h = b >>> 2;         //h=8'b11100111 = -25
logic [7:0] i = 9'sh9c >>> 2;    //i=8'b00100111
logic [1:0] j = -4'sd5 >>> 2;
endmodule

module code2_16;
logic [3:0] a = 4'h3;
logic [3:0] b;
initial begin
a++;                      //a=4
a--;                      //a=3
b = 4'd1 + a++;           //b=4, a=4
b = 4'd1 + ++a;           //b=6, a=5
b = a++ + (a = a - 1);
end
endmodule

module code2_17;
logic a = 4'b0010 || 2'b1z;      // a = 1'b1 | 1'bx = 1'b1
logic b = 4'b1001 < 4'b11xx;     // b = 1'bx
logic c = 4'b1001 == 4'b100x;    // c = 1'bx
logic d = 4'b1001 != 4'b000x;    // d = 1'b1
logic e = 4'b1001 === 4'b100x;   // e = 1'b0
logic f = 4'b100x === 4'b100x;   // f = 1'b1
logic g = 4'b1001 ==? 4'b10xx;   // g = 1'b1
logic h = 4'b1001 !=? 4'b11??;   // h = 1'b1
logic i = 4'b10x1 !=? 4'b100?;   // i = 1'bx
logic ii0 = 0->1;
logic ii1 = 0->0;
logic ii2 = 1->1;
logic ii3 = 0->1'bx;
logic ii4 = 1'bx->1;
logic ii5 = 1->0;
logic eq0 = 0<->0;
logic eq1 = 1<->1;
logic eq2 = 0<->1;
logic eq3 = 1<->0;
endmodule

module code2_19;
let max(a, b) = a > b ? a : b;
let abs(a) = a > 0 ? a : -a;
logic signed [15:0] a, b, c;
initial begin
c = max(abs(a), abs(b));
end
endmodule

module code2_20;
struct {
    logic signed [15:0] re;
    logic signed [15:0] im;
} c0, c1;
struct {
    time t; integer val;
} a;
endmodule

module code2_21;
typedef struct packed {
    logic signed [15:0] re;
    logic signed [15:0] im;
} Cplx;
Cplx c0, c1;
wire Cplx c2 = c0;
endmodule

package CplxTypes;
typedef struct {
    logic signed [15:0] re;
    logic signed [15:0] im;
} Cplx;
endpackage

module code2_22;
import CplxTypes::*;
logic signed [15:0] a = 16'sd3001;
logic signed [15:0] b = -16'sd8778; 
Cplx c0, c1, c2;                       //c0=c1=c2='{x,x}
wire Cplx c3 = c1;                     //c3=c1='{x,x}
wire Cplx c4 = '{a, b};                //c4={3001,-8778}
initial begin
c0.re = 16'sd3001;                     //c0='{3001,x}
c0.im = b;                             //c0='{3001,-8778}
c1 = '{16'sd3001, -16'sd8778};         //c3=c1={3001,-8778}
c2 = '{a, -16'sd1};                    //c2={3001,-1}
c2 = '{c2.im, c2.re};                  //c2={-1,3001}
a = 16'sd1;                            //c4={1,-8778}
end
endmodule

module code2_23;
typedef struct packed {
    logic signed [15:0] re;
    logic signed [15:0] im;
} Cplx;
Cplx c0 = {16'sd5, -16'sd5};
logic signed [15:0] a = c0.re;        //a=5
logic signed [15:0] b = c0[31:16];    //b=5
logic [3:0] c = c0[17:14];            //c=4'b0111
Cplx c1 = {<<16{c0}};                 //c1='{-5,5}
endmodule

module code2_24;
typedef union packed {
    logic [15:0] val;
    struct packed {
        logic [7:0] msbyte;
        logic [7:0] lsbyte;
    } bytes;
} Abc;
Abc a;
initial begin
a.val = 16'h12a3;           //a.byte.msbyte=8'h12, lsbyte=8'a3
a.bytes.msbyte = 8'hcd;     //a.val=16'hcda3;
end
endmodule

module code2_25;
typedef union tagged {
    logic [31:0] val;
    struct packed {
        byte b3;
        byte b2;
        byte b1;
        byte b0;
    } bytes;
} Abct;
Abct ut;
logic [31:0] c;
byte d;
initial begin
ut.val = 32'h7a3f5569;
ut = tagged val 32'h1234abcd;
d = ut.bytes.b0;
ut = tagged bytes '{'h11, 'h22, 'h33, 'h44};
d = ut.bytes.b0;
end
endmodule

module code2_26;
logic [3:0][7:0] a[0:1][0:2] =
    '{'{32'h00112233, 32'h112a3a44, 32'h22334455},
      '{32'h33445566, 32'h4455aa77, 32'hf5667788}
     };
logic [31:0] b = a[0][2];        //32'h22334455;
logic [15:0] c = a[0][1][2:1];   //16'h2a3a;
logic [7:0] d = a[1][1][1];      //8'haa;
logic [3:0] e = a[1][2][3][4+:4];//4'hf;
initial begin
    a[0][0][3:2] = a[1][0][1:0]; //a[0][0]=32'h55662233
end

logic rd[16], rc[16];
logic [15:0] va;
logic an;
initial begin
	{>>{rd}} = 16'b1 << 1;
	va = {>>{rd}};
	rc = rd;
	an = |({>>{rd}} & {>>{rc}});
end
endmodule

module code2_27;
logic [7:0] a = 8'd0, b = 8'd0;
wire [7:0] #5ns c = a;
wire [7:0] d;
assign #2ns d = c;
initial begin
    #10 a = 8'd10;
    #20 a = 8'd20;
    b = #10 8'd30;
    b = #20 8'd40;
    #30 a = 8'd30;
end
endmodule

module code2_28;
logic [7:0] a = 8'd0, b = 8'd0;
wire [7:0] #5ns c = a;
wire [7:0] d;
assign #2ns d = c;
initial fork
    #10 a = 8'd10;
    #20 a = 8'd20;
    b = #10 8'd30;
    b = #20 8'd40;
    #30 a = 8'd30;
join
endmodule

module code2_28_obs;
import CplxTypes::*;
logic [7:0] arr[0:255];
Cplx c0;
initial begin
    arr = '{256{8'h80}};
    c0 = '{16'sd100, -16'sd100};
end
integer a = 1, b = 2;
initial begin
    a = 3;
    b = a;
end
integer c = 1, d = 2;
initial fork
	c = 3;
    d = c;
join
endmodule

module code2_29;
logic [1:0] data = '1;
logic pup = '0;
wire (pull1, highz0) sda = pup;
assign (highz1, strong0) sda = data[0];
assign (highz1, strong0) sda = data[1];
initial begin
    #10ns data[0] = '0;
	#10ns data[1] = '0;
	#10ns data = '1;
	#10ns pup = '1;
	#10ns data[0] = '0;
	#10ns data[1] = '0;
end
endmodule

module code2_30;
logic ck = '1;
wire #2ns clk = ck;          //?ck??2ns??clk
logic [7:0] a = '0, b = '0;
logic [7:0] c, d, e, f;
always begin
    #10ns ck = ~ck;          //????20ns???ck
end
always begin
    #5ns a = a + 8'b1;       //??10ns?????a
    #5ns b = b + 8'b1;       //??10ns?????b
end
always@(a, b) begin          //???????
    c = a + b;
end
always@(*) begin             //????always???
    d = a + b;
end
always@(clk, a) begin        //clk??????
    if(clk) e = a;
end
always@(posedge clk) begin   //clk??????
    f = a;
end
endmodule

module code2_31;
logic ck = '1;
wire #2ns clk = ck;          //?ck??2ns??clk
logic en = '1, arst = '0;
logic [7:0] a = '0, b = '0;
logic [7:0] c, d, e, f, g, h, i;
initial begin
    #100 en = '0;
    #50 arst = '1;
    #50 en = '1;
    #50 arst = '0;
    #50 arst = '1;
    #50 arst = '0;
end
always begin
    #10ns ck = ~ck;          //????20ns???ck
end
always begin
    #5ns a = a + 8'b1;       //??10ns?????a
    #5ns b = b + 8'b1;       //??10ns?????b
end
always_comb begin             //????always???
    c = a + b;
end
always_comb begin        //clk??????
    if(clk) d = a + b;
end
always_comb begin        //clk??????
    if(clk) e = a + b;
    else e = a - b;
end
always_ff@(posedge clk) begin   //clk?????????
    f = a;
end
always_ff@(posedge clk iff en) //clk???????????????
begin                          //??en??en?????????
    g = a;
end
always_ff@(posedge clk iff en or posedge arst) //clk?????
begin                                          //?????????
    if(arst) h = 8'd0;                     //arst???????h??
    else h = a;
end
always_ff@(posedge clk iff en|arst)             //clk?????
begin                                          //?????????
    if(arst) i = '0;
    else i = a;
end
endmodule

module code2_33;
    logic a = '0, b = '0, c;
    initial begin
        a = '1;     //   1      a = 1
        b = a;      //   2      b = 1
        a <= '0;    //   4      a = 0
        b <= a;     //   4      b = 1
        c = '0;     //   3      c = 0
        c = b;      //   4      c = 1
    end
endmodule

module code2_34;
    logic clk = '1;
    always #10 clk = ~clk;
    logic [1:0] a[4] = '{'0, '0, '0, '0};
    always_ff@(posedge clk) begin :eg1
        a[0][0] = '1;
        a[0][1] = a[0][0];
    end
    always_ff@(posedge clk) begin
        a[1][0] = '1;
        a[1][1] <= a[1][0];
    end
    always_ff@(posedge clk) begin
        a[2][0] <= '1;
        a[2][1] = a[2][0];
    end
    always_ff@(posedge clk) begin
        a[3][0] <= '1;
        a[3][1] <= a[3][0];
    end
endmodule

module code2_35;
    logic [3:0] a = 4'd0;
    always #10 a = a + 4'd1;
    logic [3:0] b[4], c[4];
    always_comb begin
        b[0] = a + 4'd1;
        c[0] = b[0] + 4'd1;
    end
    always_comb begin
        b[1] = a + 4'd1;
        c[1] <= b[1] + 4'd1;
    end
    always_comb begin
        b[2] <= a + 4'd1;
        c[2] = b[2] + 4'd1;
    end
    always_comb begin
        b[3] <= a + 4'd1;
        c[3] <= b[3] + 4'd1;
    end
endmodule

module code2_36;
    initial begin
        $display("Hello World!");
    end
endmodule

// code 2_38
module my_adder #(
    parameter DW = 8                   //integer????????8
)(
    input wire clk, rst, en,
    input wire [DW - 1 :0] a, b,      //????????
    output logic [DW : 0] sum          //????????
);
    always_ff@(posedge clk) begin
        if(rst) sum <= '0;
        else if(en) sum <= a + b;
    end
endmodule

module code2_39;
    logic clk = '0;
    always #5 clk = ~clk;
    logic [7:0] a = '0, b = '0, sum_ab;
    logic co_ab;
    logic [11:0] c = '0, d = '0;
    logic [12:0] sum_cd;
    always begin
        #10 a++; b++; c++; d++;
    end
    my_adder #(.DW(8)) the_adder_8b(
        .clk(clk), .rst(1'b0), .en(1'b1),
        .a(a), .b(b), .sum({co_ab, sum_ab})
    );
    my_adder #(.DW(12)) the_adder_12b(
        .clk(clk), .rst(1'b0), .en(1'b1),
        .a(c), .b(d), .sum(sum_cd)
    );
endmodule

// ====== code 2-40 ======

module mem40 #(
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

module mem_tester40 #(
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

module testmem40;
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

// ====== end of code 2-40 ======

// ====== code 2-41 ======

interface membus #(                       //????membus???
    parameter LEN = 256, DW = 8
)(
    input wire clk, input wire rst        //??????clk?rst
);
    logic [$clog2(LEN) - 1 : 0] addr;
    logic [DW - 1 : 0] d, q;
    logic wr;
    modport master(output addr, d, wr,           //????master
                   input clk, rst, q);
    modport slave(input clk, rst, addr, d, wr,   //????slave
                  output q);
endinterface

module mem #(parameter LEN = 256, DW = 8)
(membus.slave bus);                         //?????????bus
    logic [DW - 1 : 0] m[LEN] = '{LEN{'0}};
    always_ff@(posedge bus.clk) begin       //??bus??clk
        if(bus.rst) m <= '{LEN{'0}};
        else if(bus.wr) m[bus.addr] <= bus.d;
    end
    always_ff@(posedge bus.clk) begin
        if(bus.rst) bus.q <= '0;
        else bus.q <= m[bus.addr];
    end
endmodule

module mem_tester #(parameter LEN = 256, DW = 8)
(membus.master bus);
    initial bus.addr = '0;
    always@(posedge bus.clk) begin
        if(bus.rst) bus.addr <= '0;
        else bus.addr <= bus.addr + 1'b1;
    end
    assign bus.wr = 1'b1;
    assign bus.d = bus.addr;
endmodule

module testintfmem;
    logic clk = '0, rst = '0;
    always #5 clk = ~clk;
    initial begin
        #10 rst = '1;
        #20 rst = '0;
    end
    membus #(64,8) the_bus(clk, rst);       //?????
    mem_tester #(64,8) the_tester(the_bus); //???????????
    mem #(64,8) the_mem(the_bus);           //???????????
endmodule

// ====== end of code 2-41 ======

// code 2-42
module code2_42 (
    input wire [7:0] gray,
    output logic [7:0] bin
);
    assign bin[7] = ^gray[7:7];
    assign bin[6] = ^gray[7:6];
    assign bin[5] = ^gray[7:5];
    assign bin[4] = ^gray[7:4];
    assign bin[3] = ^gray[7:3];
    assign bin[2] = ^gray[7:2];
    assign bin[1] = ^gray[7:1];
    assign bin[0] = ^gray[7:0];
endmodule

// code 2-43
module code2_43 #(
    parameter DW = 8
)(
    input wire [DW - 1 : 0] gray,
    output logic [DW - 1 : 0] bin
);
    generate
        for(genvar i = 0; i < DW; i++) begin :binbits
            assign bin[i] = ^gray[DW - 1 : i];
        end
    endgenerate
endmodule

module code2_44;
    localparam DW = 8;

    task automatic gen_reset(
        ref reset, input time start, input time stop
    );
        #start reset = 1'b1;
        #(stop - start) reset = 1'b0;
    endtask
    logic rst = 1'b0;
    initial gen_reset(rst, 10ns, 25ns);

    function automatic [$clog2(DW) - 1 : 0] log2(
        input [DW - 1 : 0] x
     );
        log2 = 0;
        while(x > 1) begin
            log2++;
            x >>= 1;
        end
    endfunction
    logic [DW - 1 : 0] a = 8'b0;
    logic [$clog2(DW) - 1 : 0] b;
    always #10 a++;
    assign b = log2(a);
endmodule

// ====== code 2-45 ======
package Q15Types;
	typedef logic signed [15:0] Q15;
	typedef struct packed { Q15 re, im; } CplxQ15;
	function CplxQ15 add(CplxQ15 a, CplxQ15 b);
		add.re = a.re + b.re;
		add.im = a.im + b.im;
	endfunction
	function CplxQ15 mulCplxQ15(CplxQ15 a, CplxQ15 b);
		mulCplxQ15.re = (32'(a.re) * b.re - 32'(a.im) * b.im) >>> 15;
		mulCplxQ15.im = (32'(a.re) * b.im + 32'(a.im) * b.re) >>> 15;
	endfunction
endpackage

module testpackage;
	import Q15Types::*;
	CplxQ15 a = '{'0, '0}, b = '{'0, '0};
	always begin
		#10 a.re += 16'sd50;
		a.im += 16'sd100;
		b.re += 16'sd200;
		b.im += 16'sd400;
	end
	CplxQ15 c;
	always_comb c = mulCplxQ15(a, b);
	real ar, ai, br, bi, cr, ci, dr, di;
	always@(c) begin
		ar = real'(a.re) / 32768;
		ai = real'(a.im) / 32768;
		br = real'(b.re) / 32768;
		bi = real'(b.im) / 32768;
		cr = real'(c.re) / 32768;
		ci = real'(c.im) / 32768;
		dr = ar * br - ai * bi;
		di = ar * bi + ai * br;
		if(dr < 1.0 && dr > -1.0 && di < 1.0 && di > -1.0) begin
			if(cr - dr > 1.0 / 32768.0 || cr - dr < -1.0 / 32768.0)
				$display("err:\t", cr, "\t", dr);
			if(ci - di > 1.0 / 32768.0 || ci - di < -1.0 / 32768.0)
				$display("err:\t", ci, "\t", di);
		end
	end
endmodule

// ====== end of code 2-45 ======

module testrealtobits;
	logic [63:0] a;
	logic [31:0] b;
	real c;
	initial begin
		a = $realtobits(0.375);
		b = $shortrealtobits(0.375);
		c = $atan2(0,0);
		c = $atan2(1,0);
		c = $atan2(0,-1);
		c = $atan2(-1,0);
	end
endmodule

module code2_997(input wire integer a, output var integer b);
integer ar[4] = '{11, 13, 17, 19};
always_comb begin
//	case(a) inside
//        0,1: b = 1;
//        2: b = 2;
//        3,4, [6:9], ar: b = 3;
//        default: b = 0;
//    endcase
    b = 0;
    for(int i = 0; i < 10; i++)
        b = b + a;
end
endmodule

module code2_998;
real a = 0.0;
logic b;
always #10 a = a + 1.0;
always_comb begin
    b = a inside {1.0,2.0,5.0,[8.0:10.0]};
end
endmodule

module code2_999;
logic [7:0] af;
logic [7:0] ag[8];

logic a = '0, b = '1;
logic clk = '0;
always #5 clk = ~clk;
//always fork
//a = @(posedge clk) 1'b1;
//b = @(posedge clk) a;
//join
always a = @(posedge clk) 1'b1;
always b = @(posedge clk) a;
endmodule

module code2_996;
    logic clk = '0;
	always #5 clk = ~clk;
    logic rst = '0;
    initial begin
        #10 rst = '1;
        #20 rst = '0;
    end
    logic en1s, en1m, en1h;
    logic [5:0] sec, min;
    logic [4:0] hr;
    cnt #(1000) cnt_1s(.clk, .rst/*, .en(1'b1)*/, .co(en1s));
    cnt #(60) cnt_60s(.clk, .rst, .en(en1s), .cnt(sec), .co(en1m));
    cnt #(60) cnt_60m(.clk, .rst, .en(en1m), .cnt(min), .co(en1h));
    cnt #(24) cnt_60h(.clk, .rst, .en(en1h), .cnt(hr));
endmodule

module cnt #(
    parameter longint unsigned M = 100
)(
    input wire logic clk, rst = 1'b0, en = 1'b1,
    output var logic [$clog2(M) - 1 : 0] cnt = '0,
    output var logic co
);
    localparam DW = $clog2(M);
    always_ff@(posedge clk) begin
        if(rst) cnt <= 1'b0;
        else if(en) begin
            if(cnt < DW'(M - 1)) cnt <= cnt + 1'b1;
            else cnt <= 1'b0;
        end
    end
    assign co = en & (cnt == DW'(M - 1));
endmodule
