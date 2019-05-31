`ifndef __LFSR_SV__
`define __LFSR_SV__

module LFSR #(
    parameter N = 8,
    parameter [N-1:0] FB = 8'h8e, //FB = representation value >> 1
    parameter [N-1:0] INIT = 8'hff
)(
    input wire clk, rst, en,
    output logic [N-1:0] out
); 
    always_ff@(posedge clk) begin
        if(rst) out <= INIT;
        else if(en) out <= (out[0]) ? (out >> 1) ^ FB : (out >> 1);
    end
endmodule

`endif
