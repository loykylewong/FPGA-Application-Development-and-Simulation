`ifndef __COMMON_SV__
`define __COMMON_SV__

package SimSrcGen;
	task automatic GenClk(
	    ref logic clk, input realtime delay, realtime period
	);
	    clk = 1'b0;
	    #delay;
	    forever #(period/2) clk = ~clk;
	endtask
	task automatic GenRst(
		ref logic clk,
		ref logic rst,
		input int start,
		input int duration
	);
		rst = 1'b0;
		repeat(start) @(posedge clk);
		rst = 1'b1;
		repeat(duration) @(posedge clk);
		rst = 1'b0;
	endtask
	task automatic KeyPress(ref logic key, input realtime t);
		for(int i = 0; i < 30; i++) begin
			#0.11ms key = '0; #0.14ms key = '1;
		end
		#t; key = '0;
	endtask
    task automatic QuadEncGo(ref logic a, b, input logic ccw, realtime qprd);
        a = 0; b = 0;
        if(!ccw) begin
            #qprd a = 1; #qprd b = 1; #qprd a = 0; #qprd b = 0;
        end
        else begin
            #qprd b = 1; #qprd a = 1; #qprd b = 0; #qprd a = 0;
        end
    endtask
endpackage

package CombFunctions;
	`define DEF_PRIO_ENC(fname, ow) \
	function automatic logic [ow - 1 : 0] fname( \
		input logic [2**ow - 1 : 0] in \
	); \
		fname = '0; \
		for(integer i = 2**ow - 1; i >= 0; i--) begin \
			if(in[i]) fname = ow'(i); \
		end \
	endfunction
endpackage

package Fixedpoint;
let max(x, y) = x > y? x : y;
`define DEF_REAL_TO_Q(name, i, f) \
    let name(x) = ((i)+(f))'(integer(x * (2**(f))));
`define DEF_Q_TO_REAL(name, i, f) \
    let name(x) = real'($signed(x)) / 2.0 ** (f);
`define DEF_FP_ADD(name, i0, f0, i1, f1, fr) \
    let name(x, y) = \
    ((f0) >= (f1)) ? \
        (   (  max((i0),(i1))+(f0))'(x) + \
            ( (max((i0),(i1))+(f0))'(y) <<< ((f0)-(f1)) ) \
        ) >>> ((f0)-(fr)) : \
        (   ( (max((i0),(i1))+(f1))'(x) <<< ((f1)-(f0)) ) + \
              (max((i0),(i1))+(f1))'(y) \
        ) >>> ((f1)-(fr));
`define DEF_FP_MUL(name, i0, f0, i1, f1, fr) \
    let name(x, y) = \
    (   ((i0)+(i1)+(f0)+(f1))'(x) * ((i0)+(i1)+(f0)+(f1))'(y) \
    ) >>> ((f0)+(f1)-(fr));
// // if you need DEF_FP_MUL and your compiler doesn't support "let":
// `define DEF_FP_MUL(name, i0, f0, i1, f1, fr) \
//     function automatic signed [(i0)+(i1)+(fr)-1:0] name(input signed [(i0)+(f0)-1:0] x, input signed [(i1)+(f1)-1:0] y); \
//         name = (((i0)+(i1)+(f0)+(f1))'(x) * ((i0)+(i1)+(f0)+(f1))'(y)) >>> ((f0)+(f1)-(fr)); \
//     endfunction
    
`define DEF_CPLX_CALC(typename, addname, subname, mulname, i, f) \
    typedef struct { \
        logic signed [(i)+(f)-1:0] re; \
        logic signed [(i)+(f)-1:0] im; \
    } typename; \
    function automatic typename mulname(typename a, typename b, logic sc); \
        mulname.re = ( (2*(i)+2*(f))'(a.re) * b.re - (2*(i)+2*(f))'(a.im) * b.im ) >>> ((f)+sc); \
        mulname.im = ( (2*(i)+2*(f))'(a.re) * b.im + (2*(i)+2*(f))'(a.im) * b.re ) >>> ((f)+sc); \
    endfunction \
    function automatic typename addname(typename a, typename b, logic sc); \
        addname.re = ( ((i)+(f)+1)'(a.re) + b.re ) >>> sc; \
        addname.im = ( ((i)+(f)+1)'(a.im) + b.im ) >>> sc; \
    endfunction \
    function automatic typename subname(typename a, typename b, logic sc); \
        subname.re = ( ((i)+(f)+1)'(a.re) - b.re ) >>> sc; \
        subname.im = ( ((i)+(f)+1)'(a.im) - b.im ) >>> sc; \
    endfunction
    
endpackage

`endif
