`default_nettype none

module str_frs_with_en #(parameter integer DW = 1)(
    input  wire           clk   ,
    input  wire           rst   ,
    input  wire  [DW-1:0] idata ,
    input  wire           ivalid,
    output wire           iready,
    output logic [DW-1:0] odata ,
    output logic          ovalid,
    input  wire           oready,
    output wire           en
);
    assign en = ivalid & iready;
    assign iready = oready | ~ovalid;
    always_ff @(posedge clk) begin : proc_ovalid
        if(rst)         ovalid <= 1'b0;
        else if(en)     ovalid <= 1'b1;
        else if(oready) ovalid <= 1'b0;
    end
    always_ff @(posedge clk) begin : proc_output
        if(rst)     odata <= '0;
        else if(en) odata <= idata;
    end
endmodule

module str_frs_deci #(  // NOT TESTED
    parameter integer DW   = 1,
    parameter integer DECI = 2
)(
    input  wire           clk   ,
    input  wire           rst   ,
    input  wire  [DW-1:0] idata ,
    input  wire           ivalid,
    output wire           iready,
    output logic [DW-1:0] odata ,
    output logic          ovalid,
    input  wire           oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    localparam integer CW = $clog2(DECI + 1);
    logic [CW-1:0] wc;
    assign iready = (wc < DECI) || osh;
    assign ovalid = wc == DECI;
    always_ff@(posedge clk) begin
        if(rst) begin
            wc <= '0;
        end
        else begin
            case({ish, osh})
            2'b10:   wc <= wc + 1'b1;
            2'b01:   wc <= wc - DECI;
            2'b11:   wc <= 1'b1;
            default: wc <= wc;
            endcase
        end
    end
    always_ff@(posedge clk) begin
        if(rst) begin
            odata <= '0;
        end
        else if(ish) begin
            odata <= idata;
        end
    end
endmodule

module str_frs_interp #(  // NOT TESTED
    parameter integer DW = 1,
    parameter integer INTP = 2,
    parameter integer HOLD = 0
)(
    input  wire           clk   ,
    input  wire           rst   ,
    input  wire  [DW-1:0] idata ,
    input  wire           ivalid,
    output wire           iready,
    output logic [DW-1:0] odata ,
    output logic          ovalid,
    input  wire           oready
);
    wire ish = ivalid & iready;
    wire osh = ovalid & oready;
    localparam integer CW = $clog2(INTP + 1);
    logic [CW-1:0] wc;
    assign iready = (wc == 0) || (wc == 1'b1 && osh);
    assign ovalid = wc > 0;
    always_ff@(posedge clk) begin
        if(rst) begin
            wc <= '0;
        end
        else begin
            case({ish, osh})
            2'b10:   wc <= wc + INTP;
            2'b01:   wc <= wc - 1'b1;
            2'b11:   wc <= INTP;
            default: wc <= wc;
            endcase
        end
    end
    always_ff@(posedge clk) begin
        if(rst) begin
            odata <= '0;
        end
        else if(ish) begin
            odata <= idata;
        end
        else if(osh) begin
            odata <= HOLD ? odata : '0;
        end
    end
endmodule

module str_active_pipe #(
    parameter integer DW  = 1,
    parameter integer STG = 2
)(
    input  wire            clk            ,
    input  wire            rst            ,
    input  wire  [DW-1:0]  idata          ,
    input  wire            ivalid         ,
    output wire            iready         ,
    output logic [DW-1:0]  odata          ,
    output logic           ovalid         ,
    input  wire            oready         ,
    output wire  [STG-1:0] en             ,
    output wire  [DW -1:0] data  [STG + 1]
);
    generate
        if(STG <= 0) begin
            $error("STG in str_pipestg must be > 0.");
        end
    endgenerate
    wire          valid[STG + 1];
    wire          ready[STG + 1];
    assign data[0] = idata;
    assign valid[0] = ivalid;
    assign iready = ready[0];
    assign odata = data[STG];
    assign ovalid = valid[STG];
    assign ready[STG] = oready;
    generate
        for(genvar i = 0; i < STG; i++) begin : stg
            str_frs_with_en #(.DW(DW))
            frs(
                .clk(clk), .rst(rst),
                .idata (data [i]  ),
                .ivalid(valid[i]  ),
                .iready(ready[i]  ),
                .odata (data [i+1]),
                .ovalid(valid[i+1]),
                .oready(ready[i+1]),
                .en    (en   [i]  )
            );
        end
    endgenerate
endmodule

module str_passive_pipe #(
    parameter integer DW  = 1,
    parameter integer STG = 2
)(
    input  wire            clk  ,
    input  wire            rst  ,
    input  wire  [STG-1:0] en   ,
    input  wire  [DW-1:0]  idata,
    output logic [DW-1:0]  odata
);
    generate
        if(STG <= 0) begin
            $error("STG in str_pipestg must be > 0.");
        end
    endgenerate
    logic [DW-1:0] data [STG + 1];
    assign data[0] = idata;
    assign odata = data[STG];
    generate
        for(genvar i = 0; i < STG; i++) begin : stg
            always_ff @( posedge clk ) begin
                if(rst) data[i+1] <= '0;
                else if(en[i]) data[i+1] <= data[i];
            end
        end
    endgenerate
endmodule
