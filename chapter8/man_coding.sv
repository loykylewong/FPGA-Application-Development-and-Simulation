`ifndef __MAN_CODING_SV__
`define __MAN_CODING_SV__

module ManchesterEncoder #( parameter POL = 0 )( // POL = 0 or 1
    input wire clk, rst, en, en180, in,
    output logic man, dman, sck
);
    always_ff@(posedge clk) begin
        if(rst) sck <= 1'b0;
        else if(en) sck <= '1;
        else if(en180) sck <= '0;
    end
    always_ff@(posedge clk) begin
        if(rst) man <= '0;
        else if(en) man <= in ^ (POL? 1'b1 : 1'b0);
        else if(en180) man <= in ^ (POL? 1'b0 : 1'b1);
    end
    always_ff@(posedge clk) begin
        if(rst) dman <= '0;
        else if(en) dman <= ~dman;
        else if(en180) dman <= in ~^ dman;
    end
endmodule

module HystComp #(
    parameter W = 12,
    parameter real HYST = 0.1
)(
    input wire clk, rst, en,
    input wire signed [W-1:0] in,
    output logic out
);
    wire signed [W-1:0] hyst = HYST * 2**(W-1);
    always_ff@(posedge clk) begin
        if(rst) out <= '0;
        else if(~out & in > hyst) out <= '1;
        else if(out & in < -hyst) out <= '0;
    end
endmodule

module DiffManDecoder #( parameter PERIOD = 10 )( // period of NRZ
    input wire clk, rst, en, in,
    output logic out, out_valid
);
    localparam integer P3Q = PERIOD * 3.0 / 4.0;
    logic [$clog2(PERIOD) : 0] pcnt;
    logic in_reg, in_edge;
    always_ff@(posedge clk) if(en) in_reg <= in;
    assign in_edge = in_reg ^ in;
    always_ff@(posedge clk) begin
        if(rst) pcnt <= '0;
        else if(en) begin
            if (pcnt >= P3Q && in_edge) pcnt <= '0;
            else pcnt <= pcnt + 1'b1;
        end
    end
    logic trans;
    always_ff@(posedge clk) begin
        if(rst) trans <= '0;
        else if(en & in_edge) begin
            if(pcnt >= P3Q) trans <= '0;
            else trans <= '1;
        end
    end
    always_ff@(posedge clk) begin
        if((en & in_edge) && pcnt >= P3Q) out <= ~trans;
    end
    always_ff@(posedge clk)
        out_valid <= ((en & in_edge) && pcnt >= P3Q);
endmodule

`endif
