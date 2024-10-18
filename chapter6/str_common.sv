`ifndef __STR_COMMON_SV__
`define __STR_COMMON_SV__

`timescale 1ns/1ps
`default_nettype none

// ==== one stage unit / fwd regslice ====
// unidirectional(forward) reg slice
// a good starting point for simple processing/calculation unit
module str_frs #(parameter integer DW = 8)(
    input  wire           clk   ,
    input  wire           rst   ,
    input  wire  [DW-1:0] idata ,
    input  wire           ilast ,
    input  wire           ivalid,
    output wire           iready,
    output logic [DW-1:0] odata ,
    output logic          olast ,
    output logic          ovalid,
    input  wire           oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    assign iready = osh | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= '0;
        else if(ish)    ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    always_ff @(posedge clk) begin : proc_output
        if(rst) begin
            odata <= '0;
            olast <= '0;
        end
        else if(ish) begin
            odata <= idata;
            olast <= ilast;
        end
    end
endmodule

// ==== bidir regslice ====
// bidirectional reg slice
// for breaking long combinatinoal logic chain between str stages
module str_birs #(parameter integer DW = 8)(
    input  wire          clk   ,
    input  wire          rst   ,
    input  wire [DW-1:0] idata ,
    input  wire          ilast ,
    input  wire          ivalid,
    output wire          iready,
    output wire [DW-1:0] odata ,
    output wire          olast ,
    output wire          ovalid,
    input  wire          oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    reg [DW:0] buffer[2];
    reg wp, rp;
    reg [1:0] dc;
    assign iready = dc < 2'd2;
    assign ovalid = dc > 2'd0;
    always_ff @(posedge clk) begin : proc_wrp
        if(rst) begin
            wp <= '0;
            rp <= '0;
            dc <= '0;
        end
        else begin
            if(ish) wp <= ~wp;
            if(osh) rp <= ~rp;
            case ({ish, osh})
                2'b10:    dc <= dc + 2'b1;
                2'b01:    dc <= dc - 2'b1;
                default : dc <= dc;
            endcase
        end
    end
    always_ff @(posedge clk) begin : proc_buffer
        if(rst) begin
            buffer <= {'0, '0};
        end
        else if(ish) begin
            buffer[wp] <= {ilast, idata};
        end
    end
    assign {olast, odata} = buffer[rp];
endmodule

// ==== handshake combine ====
// for synchronizing multi-upstr & multi-downstr.
// deadlock if d.s. ready depends on u.s. valid.
// deadlock if series 2 str_hscomb(s).
// follow a fifo or a regslice will break deadlock.
module str_hscomb #(
    parameter integer US = 2,
    parameter integer DS = 2
)(
    input  wire [US-1:0] uv,
    output wire [US-1:0] ur,
    output wire [DS-1:0] dv,
    input  wire [DS-1:0] dr
);
    generate
        for(genvar i = 0; i < DS; i++) begin : dvs
            wire [DS-1:0] dre = dr | (DS'(1) << i);
            assign dv[i] = &{uv, dre};
        end
    endgenerate
    generate
        for(genvar i = 0; i < US; i++) begin :urs
            wire [US-1:0] uve = uv | (US'(1) << i);
            assign ur[i] = &{dr, uve};
        end
    endgenerate
endmodule

// raw pipeline stages use to match latency between paths
// if their latencies are predetermined, otherwise fifo
// should be used.
module str_pipestg #(
    parameter integer DW  = 16,
    parameter integer STG =  4
)(
    input  wire           clk   ,
    input  wire           rst   ,
    input  wire  [DW-1:0] idata ,
    input  wire           ilast ,
    input  wire           ivalid,
    output wire           iready,
    output logic [DW-1:0] odata ,
    output logic          olast ,
    output logic          ovalid,
    input  wire           oready
);
    generate
        if(STG <= 0) begin
            $error("STG in str_pipestg must be > 0.");
        end
    endgenerate
    wire [DW-1:0] data [STG + 1];
    wire          last [STG + 1];
    wire          valid[STG + 1];
    wire          ready[STG + 1];
    assign data[0] = idata;
    assign last[0] = ilast;
    assign valid[0] = ivalid;
    assign iready = ready[0];
    assign odata = data[STG];
    assign olast = last[STG];
    assign ovalid = valid[STG];
    assign ready[STG] = oready;
    generate
        for(genvar i = 0; i < STG; i++) begin : stg
            str_frs #(.DW(DW))
            frs(
                .clk(clk), .rst(rst),
                .idata (data [i]),
                .ilast (last [i]),
                .ivalid(valid[i]),
                .iready(ready[i]),
                .odata (data [i+1]),
                .olast (last [i+1]),
                .ovalid(valid[i+1]),
                .oready(ready[i+1])
            );
        end
    endgenerate
endmodule

module str_snk_to_fifo_wr #(
    parameter int DW = 8
)(
    input  wire  [DW-1:0] in_data  ,
    input  wire           in_valid ,
    output logic          in_ready ,
    output logic [DW-1:0] fifo_data,
    output logic          fifo_wr  ,
    input  wire           fifo_full
);
    always_comb in_ready  = ~fifo_full;
    always_comb fifo_wr   = in_ready & in_valid;
    always_comb fifo_data = in_data;
endmodule

module fifo_rd_to_str_src #(
    parameter int DW = 8
)(
    input  wire           clk       ,
    input  wire           rst       ,
    input  wire  [DW-1:0] fifo_q    ,
    output logic          fifo_rd   ,
    input  wire           fifo_empty,
    output logic [DW-1:0] out_data  ,
    output logic          out_valid ,
    input  wire           out_ready
);
    always_comb fifo_rd  = ~fifo_empty & (~out_valid | out_valid & out_ready);
    always_comb out_data = fifo_q;
    always_ff@(posedge clk) begin
        if(rst)            out_valid <= 1'b0;
        else if(fifo_rd)   out_valid <= 1'b1;
        else if(out_ready) out_valid <= 1'b0;
    end
endmodule

module str_fifo #(
    parameter int DW = 8,
    parameter int AW = 8    // actual fifo depth = 2**AW - 1
)(
    input  wire           clk      ,
    input  wire           rst      ,
    input  wire  [DW-1:0] in_data  ,
    input  wire           in_last  ,
    input  wire           in_valid ,
    output logic          in_ready ,
    output logic [DW-1:0] out_data ,
    output logic          out_last ,
    output logic          out_valid,
    input  wire           out_ready
);
    logic full, empty;
    always_comb in_ready = ~full;
    wire wr = in_ready & in_valid;
    wire rd = ~empty & (~out_valid | out_valid & out_ready);
    ScFifo2 #(.DW(DW+1), .AW(AW))
    theFifo(
        .clk     (clk                 ),
        .rst     (rst                 ),
        .din     ({ in_last,  in_data}),
        .write   (wr                  ),
        .dout    ({out_last, out_data}),
        .read    (rd                  ),
        .wr_cnt  (                    ),
        .rd_cnt  (                    ),
        .data_cnt(                    ),
        .full    (full                ),
        .empty   (empty               )
    );
    always_ff@(posedge clk) begin
        if(rst)            out_valid <= 1'b0;
        else if(rd)        out_valid <= 1'b1;
        else if(out_ready) out_valid <= 1'b0;
    end
endmodule

// replicate data to multiple streams, each have their own
// handshake signals. mean to use in circumstances that downsteams
// latencies are not/hard to predetermined.
module str_replicator #(
    parameter integer       DS =  2,
    parameter integer       DW = 16,
    parameter integer USE_BIRS =  1
)(
    input  wire          clk       ,
    input  wire          rst       ,
    input  wire [DW-1:0] idata     ,
    input  wire          ilast     ,
    input  wire          ivalid    ,
    output wire          iready    ,
    output wire [DW-1:0] odata [DS],
    output wire          olast [DS],
    output wire          ovalid[DS],
    input  wire          oready[DS]
);
    wire [DS-1:0] cvalid, cready;

    str_hscomb #(.US(1), .DS(DS))
    the_hscomb (
        .uv(ivalid), .ur(iready),
        .dv(cvalid), .dr(cready)
    );
    generate
        for(genvar i = 0; i < DS; i++) begin : birs
            if(USE_BIRS) begin
                str_birs #(.DW(DW))
                the_rs(
                    .clk   (clk),
                    .rst   (rst),
                    .idata (idata),
                    .ilast (ilast),
                    .ivalid(cvalid[i]),
                    .iready(cready[i]),
                    .odata (odata[i]),
                    .olast (olast[i]),
                    .ovalid(ovalid[i]),
                    .oready(oready[i])
                );
            end
            else begin
                str_frs #(.DW(DW))
                the_rs(
                    .clk   (clk),
                    .rst   (rst),
                    .idata (idata),
                    .ilast (ilast),
                    .ivalid(cvalid[i]),
                    .iready(cready[i]),
                    .odata (odata[i]),
                    .olast (olast[i]),
                    .ovalid(ovalid[i]),
                    .oready(oready[i])
                );
            end
        end
    endgenerate
endmodule

// 1-ch, 2-input signed/unsigned adder/substractor.
module str_addsub #(
    parameter string  OP  = "ADD" , // "ADD" or "SUB"
    parameter integer DW  = 12    ,
    parameter integer ODW = DW + 1
)(
    input  wire                   clk   ,
    input  wire                   rst   ,
    input  wire  signed [DW-1:0]  a     ,
    input  wire  signed [DW-1:0]  b     ,
    input  wire                   ilast ,
    input  wire                   ivalid,
    output wire                   iready,
    output logic signed [ODW-1:0] o     ,
    output logic                  olast ,
    output logic                  ovalid,
    input  wire                   oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    assign iready = osh | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= '0;
        else if(ish)    ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    wire signed [ODW-1:0] result;
    generate
        if(OP == "ADD") begin
            assign result = a + b;
        end
        else if(OP == "SUB") begin
            assign result = a - b;
        end
        else begin
            $error("OP must be \"ADD\" or \"SUB\"");
        end
    endgenerate
    always_ff @(posedge clk) begin : proc_output
        if(rst) begin
            o     <= '0;
            olast <= '0;
        end
        else if(ish) begin
            o     <= result;
            olast <= ilast;
        end
    end
endmodule

// 1-ch 2-input unsigned adder/substractor.
// although unsigned & signed add & sub is the same,
// this module is mean to eliminate warnings about port connections.
module str_usaddsub #(
    parameter string  OP  = "ADD" , // "ADD" or "SUB"
    parameter integer DW  = 12    ,
    parameter integer ODW = DW + 1
)(
    input  wire            clk   ,
    input  wire            rst   ,
    input  wire  [DW-1:0]  a     ,
    input  wire  [DW-1:0]  b     ,
    input  wire            ilast ,
    input  wire            ivalid,
    output wire            iready,
    output logic [ODW-1:0] o     ,
    output logic           olast ,
    output logic           ovalid,
    input  wire            oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    assign iready = osh | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= '0;
        else if(ish)    ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    wire [ODW-1:0] result;
    generate
        if(OP == "ADD") begin
            assign result = a + b;
        end
        else if(OP == "SUB") begin
            assign result = a - b;
        end
        else begin
            $error("OP must be \"ADD\" or \"SUB\"");
        end
    endgenerate
    always_ff @(posedge clk) begin : proc_output
        if(rst) begin
            o     <= '0;
            olast <= '0;
        end
        else if(ish) begin
            o     <= result;
            olast <= ilast;
        end
    end
endmodule

// 1-ch 2-input signed multiplier
module str_mul #(
    parameter integer ADW = 8      ,
    parameter integer BDW = ADW    ,
    parameter integer ODW = ADW+BDW
)(
    input  wire                   clk   ,
    input  wire                   rst   ,
    input  wire  signed [ADW-1:0] a     ,
    input  wire  signed [BDW-1:0] b     ,
    input  wire                   ilast ,
    input  wire                   ivalid,
    output wire                   iready,
    output logic signed [ODW-1:0] o     ,
    output logic                  olast ,
    output logic                  ovalid,
    input  wire                   oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    assign iready = osh | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= '0;
        else if(ish)    ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    always_ff @(posedge clk) begin : proc_output
        if(rst) begin
            o     <= '0;
            olast <= '0;
        end
        else if(ish) begin
            o     <= (ADW+BDW)'(a) * b;
            olast <= ilast;
        end
    end
endmodule

// 1-ch 2-input unsigned multiplier
module str_usmul #(
    parameter integer ADW = 8      ,
    parameter integer BDW = ADW    ,
    parameter integer ODW = ADW+BDW
)(
    input  wire            clk   ,
    input  wire            rst   ,
    input  wire  [ADW-1:0] a     ,
    input  wire  [BDW-1:0] b     ,
    input  wire            ilast ,
    input  wire            ivalid,
    output wire            iready,
    output logic [ODW-1:0] o     ,
    output logic           olast ,
    output logic           ovalid,
    input  wire            oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    assign iready = osh | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= '0;
        else if(ish)    ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    always_ff @(posedge clk) begin : proc_output
        if(rst) begin
            o     <= '0;
            olast <= '0;
        end
        else if(ish) begin
            o     <= (ADW+BDW)'(a) * b;
            olast <= ilast;
        end
    end
endmodule

// 1-ch 2-input signed fixed-point multiplier
module str_fpmul #(
    parameter integer ADW = 8  ,
    parameter integer AFW = 7  ,
    parameter integer BDW = ADW,
    parameter integer BFW = AFW,
    parameter integer ODW = ADW,
    parameter integer OFW = AFW
)(
    input  wire                   clk   ,
    input  wire                   rst   ,
    input  wire  signed [ADW-1:0] a     ,
    input  wire  signed [BDW-1:0] b     ,
    input  wire                   ilast ,
    input  wire                   ivalid,
    output wire                   iready,
    output logic signed [ODW-1:0] o     ,
    output logic                  olast ,
    output logic                  ovalid,
    input  wire                   oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    assign iready = osh | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= '0;
        else if(ish)    ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    always_ff @(posedge clk) begin : proc_output
        if(rst) begin
            o     <= '0;
            olast <= '0;
        end
        else if(ish) begin
            o     <= (ADW+BDW)'(a) * (ADW+BDW)'(b) >>> (AFW+BFW-OFW);
            olast <= ilast;
        end
    end
endmodule

// 1-ch 2-input unsigned fixed-point mulitiplier
module str_usfpmul #(
    parameter integer ADW = 8  ,
    parameter integer AFW = 8  ,
    parameter integer BDW = ADW,
    parameter integer BFW = AFW,
    parameter integer ODW = ADW,
    parameter integer OFW = AFW
)(
    input  wire            clk   ,
    input  wire            rst   ,
    input  wire  [ADW-1:0] a     ,
    input  wire  [BDW-1:0] b     ,
    input  wire            ilast ,
    input  wire            ivalid,
    output wire            iready,
    output logic [ODW-1:0] o     ,
    output logic           olast ,
    output logic           ovalid,
    input  wire            oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    assign iready = osh | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= '0;
        else if(ish)    ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    always_ff @(posedge clk) begin : proc_output
        if(rst) begin
            o     <= '0;
            olast <= '0;
        end
        else if(ish) begin
            o     <= (ADW+BDW)'(a) * (ADW+BDW)'(b) >>> (AFW+BFW-OFW);
            olast <= ilast;
        end
    end
endmodule

// 1-ch multi-input signed/unsigned adder/substractor
// implemented by binary add/sub tree, Latency = $clog2(CH)
module str_mi_addsub #(
    parameter string  OP   = "ADD", // "ADD" or "SUB"
    parameter integer CH   = 4    ,
    parameter integer DW   = 16   ,
    parameter integer EODW = 0      // 0 - width of adders are all DW, 1 - extened width per stage
)(
    input  wire                                     clk          ,
    input  wire                                     rst          ,
    input  wire signed [DW-1:0]                     in_data  [CH],
    input  wire                                     in_last      ,
    input  wire                                     in_valid     ,
    output wire                                     in_ready     ,
    output wire signed [DW+(EODW?$clog2(CH):0)-1:0] out_data     ,
    output wire                                     out_last     ,
    output wire                                     out_valid    ,
    input  wire                                     out_ready
);
    generate
        if(CH <= 1)
            $error("CH in str_mi_usaddsub must be >= 2");
    endgenerate

    localparam integer STG = $clog2(CH);
    localparam integer ECH = 1 << STG;
    localparam integer ODW = EODW ? DW+STG : DW;

    wire signed [ODW-1:0] stg_data [STG+1][ECH];    // dummy wire in non-first stg will be optimized out.
    wire                  stg_last [STG+1];
    wire                  stg_valid[STG+1];
    wire                  stg_ready[STG+1];

    // connect first stage's input
    assign stg_last [0] =  in_last;
    assign stg_valid[0] =  in_valid;
    assign in_ready     =  stg_ready[0];
    generate
        for(genvar i = 0; i < ECH; i++) begin :input_expand
            if(i < CH) begin
                assign stg_data [0][i] =  in_data [i];
            end
            else begin
                assign stg_data [0][i] = '0;
            end
        end
    endgenerate

    // connect last stage's output
    assign out_data  = stg_data [STG][0];
    assign out_last  = stg_last [STG];
    assign out_valid = stg_valid[STG];
    assign stg_ready[STG] = out_ready;

    generate
        for(genvar s = 0; s < STG; s++) begin : stages
            localparam int IW = DW+(EODW?s  :0);
            localparam int OW = DW+(EODW?s+1:0);
            for(genvar i = 0; i < ECH >> s + 1; i++) begin : ops
                if(i == 0) begin
                    str_addsub #(.OP(OP), .DW(IW), .ODW(OW))
                    mop (
                        .clk   (clk                         ),
                        .rst   (rst                         ),
                        .a     (stg_data [s  ][2*i+0][0+:IW]),
                        .b     (stg_data [s  ][2*i+1][0+:IW]),
                        .ilast (stg_last [s  ]              ),
                        .ivalid(stg_valid[s  ]              ),
                        .iready(stg_ready[s  ]              ),
                        .o     (stg_data [s+1][  i  ][0+:OW]),
                        .olast (stg_last [s+1]              ),
                        .ovalid(stg_valid[s+1]              ),
                        .oready(stg_ready[s+1]              )
                    );
                end
                else begin
                    str_addsub #(.OP(OP), .DW(IW), .ODW(OW))
                    sop (
                        .clk   (clk                         ),
                        .rst   (rst                         ),
                        .a     (stg_data [s  ][2*i+0][0+:IW]),
                        .b     (stg_data [s  ][2*i+1][0+:IW]),
                        .ilast (stg_last [s  ]              ),
                        .ivalid(stg_valid[s  ]              ),
                        .iready(                            ),
                        .o     (stg_data [s+1][  i  ][0+:OW]),
                        .olast (                            ),
                        .ovalid(                            ),
                        .oready(stg_ready[s+1]              )
                    );
                end
            end
        end
    endgenerate
endmodule

// 1-ch multi-input unsigned adder/substractor
// implemented by binary add/sub tree, Latency = $clog2(CH)
// although unsigned & signed add & sub is the same,
// this module is mean to eliminate warnings about port connections.
module str_mi_usaddsub #(
    parameter string  OP   = "ADD", // "ADD" or "SUB"
    parameter integer CH   = 4    ,
    parameter integer DW   = 16   ,
    parameter integer EODW = 0      // 0 - width of adders are all DW, 1 - extened width per stage
)(
    input  wire                              clk          ,
    input  wire                              rst          ,
    input  wire [DW-1:0]                     in_data  [CH],
    input  wire                              in_last      ,
    input  wire                              in_valid     ,
    output wire                              in_ready     ,
    output wire [DW+(EODW?$clog2(CH):0)-1:0] out_data     ,
    output wire                              out_last     ,
    output wire                              out_valid    ,
    input  wire                              out_ready
);
    generate
        if(CH <= 1)
            $error("CH in str_mi_usaddsub must be >= 2");
    endgenerate

    localparam integer STG = $clog2(CH);
    localparam integer ECH = 1 << STG;
    localparam integer ODW = EODW ? DW+STG : DW;

    wire [ODW-1:0] stg_data [STG+1][ECH];    // dummy wire in non-first stg will be optimized out.
    wire           stg_last [STG+1];
    wire           stg_valid[STG+1];
    wire           stg_ready[STG+1];

    // connect first stage's input
    assign stg_last [0] =  in_last;
    assign stg_valid[0] =  in_valid;
    assign in_ready     =  stg_ready[0];
    generate
        for(genvar i = 0; i < ECH; i++) begin :input_expand
            if(i < CH) begin
                assign stg_data [0][i] =  in_data [i];
            end
            else begin
                assign stg_data [0][i] = '0;
            end
        end
    endgenerate

    // connect last stage's output
    assign out_data  = stg_data [STG][0];
    assign out_last  = stg_last [STG];
    assign out_valid = stg_valid[STG];
    assign stg_ready[STG] = out_ready;

    generate
        for(genvar s = 0; s < STG; s++) begin : stages
            localparam int IW = DW+(EODW?s  :0);
            localparam int OW = DW+(EODW?s+1:0);
            for(genvar i = 0; i < ECH >> s + 1; i++) begin : ops
                if(i == 0) begin
                    str_usaddsub #(.OP(OP), .DW(IW), .ODW(OW))
                    mop (
                        .clk   (clk                         ),
                        .rst   (rst                         ),
                        .a     (stg_data [s  ][2*i+0][0+:IW]),
                        .b     (stg_data [s  ][2*i+1][0+:IW]),
                        .ilast (stg_last [s  ]              ),
                        .ivalid(stg_valid[s  ]              ),
                        .iready(stg_ready[s  ]              ),
                        .o     (stg_data [s+1][  i  ][0+:OW]),
                        .olast (stg_last [s+1]              ),
                        .ovalid(stg_valid[s+1]              ),
                        .oready(stg_ready[s+1]              )
                    );
                end
                else begin
                    str_usaddsub #(.OP(OP), .DW(IW), .ODW(OW))
                    sop (
                        .clk   (clk                         ),
                        .rst   (rst                         ),
                        .a     (stg_data [s  ][2*i+0][0+:IW]),
                        .b     (stg_data [s  ][2*i+1][0+:IW]),
                        .ilast (stg_last [s  ]              ),
                        .ivalid(stg_valid[s  ]              ),
                        .iready(                            ),
                        .o     (stg_data [s+1][  i  ][0+:OW]),
                        .olast (                            ),
                        .ovalid(                            ),
                        .oready(stg_ready[s+1]              )
                    );
                end
            end
        end
    endgenerate
endmodule

// 1-ch, multi-inputpair signed multiplier
module str_mi_fpmul #(
    parameter integer CH  = 4  ,
    parameter integer ADW = 8  ,
    parameter integer AFW = 7  ,
    parameter integer BDW = ADW,
    parameter integer BFW = AFW,
    parameter integer ODW = ADW,
    parameter integer OFW = AFW
)(
    input  wire                   clk       ,
    input  wire                   rst       ,
    input  wire  signed [ADW-1:0] a     [CH],
    input  wire  signed [BDW-1:0] b     [CH],
    input  wire                   ilast     ,
    input  wire                   ivalid    ,
    output wire                   iready    ,
    output logic signed [ODW-1:0] o     [CH],
    output logic                  olast     ,
    output logic                  ovalid    ,
    input  wire                   oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    assign iready = osh | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= '0;
        else if(ish)    ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    wire signed [ODW-1:0] muls[CH];
    generate
        for(genvar i = 0; i < CH; i++) begin
            assign muls[i] =
                (ADW+BDW)'(a[i]) * (ADW+BDW)'(b[i]) >>> (AFW+BFW-OFW);
        end
    endgenerate
    always_ff @(posedge clk) begin : proc_output
        if(rst) begin
            o     <= '{CH{'0}};
            olast <= '0;
        end
        else if(ish) begin
            o     <= muls;
            olast <= ilast;
        end
    end
endmodule

// 1-ch, multi-inputpair unsigned multiplier
module str_mi_usfpmul #(
    parameter integer CH  = 4  ,
    parameter integer ADW = 8  ,
    parameter integer AFW = 8  ,
    parameter integer BDW = ADW,
    parameter integer BFW = AFW,
    parameter integer ODW = ADW,
    parameter integer OFW = AFW
)(
    input  wire            clk       ,
    input  wire            rst       ,
    input  wire  [ADW-1:0] a     [CH],
    input  wire  [BDW-1:0] b     [CH],
    input  wire            ilast     ,
    input  wire            ivalid    ,
    output wire            iready    ,
    output logic [ODW-1:0] o     [CH],
    output logic           olast     ,
    output logic           ovalid    ,
    input  wire            oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    assign iready = osh | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= '0;
        else if(ish)    ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    wire [ODW-1:0] muls[CH];
    generate
        for(genvar i = 0; i < CH; i++) begin
            assign muls[i] =
                (ADW+BDW)'(a[i]) * (ADW+BDW)'(b[i]) >>> (AFW+BFW-OFW);
        end
    endgenerate
    always_ff @(posedge clk) begin : proc_output
        if(rst) begin
            o     <= '{CH{'0}};
            olast <= '0;
        end
        else if(ish) begin
            o     <= muls;
            olast <= ilast;
        end
    end
endmodule

`default_nettype wire
`endif
