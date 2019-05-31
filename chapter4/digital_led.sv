
module Bin2Bcd (
    input wire clk,
    input wire [7 : 0] bin,
    output logic [2 : 0][3 : 0] bcd
);
    logic [7 : 0] bin_temp;
    logic [2 : 0][3 : 0] bcd_temp;
    always@(posedge clk) begin
        if(bin_temp >=              8'd100) begin
            bin_temp <= bin_temp -  8'd100;
            bcd_temp <= bcd_temp + 12'h100;
        end
        else if(bin_temp >=         8'd010) begin
            bin_temp <= bin_temp -  8'd010;
            bcd_temp <= bcd_temp + 12'h010;
        end
        else if(bin_temp >=         8'd001) begin
            bin_temp <= bin_temp -  8'd001;
            bcd_temp <= bcd_temp + 12'h001;
        end
        else begin
            bin_temp <= bin;
            bcd_temp <= 20'h0;
            bcd <= bcd_temp;
        end
    end
endmodule

module DigitalLedSeg (
	input wire clk,
	input wire [3 : 0] in,
	output logic [6 : 0] seg
);
	logic [6:0] segs[16] = '{
		7'h3f, 7'h06, 7'h5b, 7'h4f, 7'h66, 7'h6d, 7'h7d, 7'h07,
	 	7'h7f, 7'h6f, 7'h77, 7'h7c, 7'h39, 7'h5e, 7'h79, 7'h71};
	always_ff@(posedge clk) seg <= segs[in];
endmodule
