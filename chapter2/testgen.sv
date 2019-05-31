`default_nettype none
module delaychain8 #(
    parameter DW = 8
)(
    input wire clk, rst, en,
    input wire [DW - 1 : 0] in,
    output logic [DW - 1 : 0] out
);
    logic [DW - 1 : 0] dly[8];
    always_ff@(posedge clk) begin
        if(rst) dly = '{8{'0}};
        else if(en) begin
            dly[0:7] <= {in, dly[0:6]};
        end
    end
    assign out = dly[7];

endmodule

module fir #(
    parameter DW = 16,
    parameter TAPS = 32,
    parameter real COEF[TAPS] = '{TAPS{0.0}}
)(
    input wire [$clog2(TAPS) - 1 : 0] addr,
    output logic signed [DW - 1 : 0] cout
);
    localparam FW = DW - 1;
    logic signed [DW - 1 : 0] coefs[TAPS];

    generate
        for(genvar i = 0; i < TAPS; i++) begin :init_coefs
            assign coefs[i] = COEF[i] * (2.0 ** FW);
        end
    endgenerate

    always_comb begin
        cout = coefs[addr];
    end

endmodule

//00-00,
//01-01,
//10-11,
//11-10
module gray2bin #(
    parameter DW = 8
)(
    input wire [DW-1:0] gray,
    output var logic [DW-1:0] bin
);
    task nn(input [3:0] a, output logic [3:0] b);
		b = ~a;
        b = ^b;
    endtask
    generate
        for(genvar i = 0; i < DW; i++) begin// : binbits
            assign bin[i] = ^gray[DW-1:i];
        end
    endgenerate
endmodule

module testgen;
    logic [3:0] addr = 4'b0;
    always #10 addr++;
    logic signed [15:0] cout;
    fir #(16, 4, '{0.3, 0.2, 0.56, -0.99}) the_fir(addr, cout);
endmodule
