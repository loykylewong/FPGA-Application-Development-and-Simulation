`default_nettype none
`include "../Common.sv"
module TestCcdTrigger;
    import SimSrcGen::*;
    logic clk_a, clk_b;
    initial GenClk(clk_a, 2, 10);
	initial GenClk(clk_b, 1, 9);
    logic trig_i = 0;
    always #10 trig_i = $random();
	logic trig_o;
    CcdTrigger theCcdTrigger(clk_a, clk_b, trig_i, trig_o);
endmodule

module CcdTrigger #(
    parameter int SYNC_STG = 2  // must be no less than 1
)(
    input clk_a,
    input trig_i,
    input clk_b,
    output logic trig_o
);
    // ---- domain a ----
    logic toggle_a = 1'b0;
    always_ff@(posedge clk_a)
    begin
        if(trig_i)
        begin
            toggle_a <= ~toggle_a;
        end
    end
    // ---- domain b ----
    logic [SYNC_STG:0] toggle_b;
    always_ff@(posedge clk_b)
    begin
        toggle_b <= {toggle_b[SYNC_STG-1:0], toggle_a};
    end
    always_ff@(posedge clk_b)
    begin
        trig_o <= ^toggle_b[SYNC_STG-:2];
    end
endmodule
