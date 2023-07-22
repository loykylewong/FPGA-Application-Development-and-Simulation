
module Axi4lXXX #(
    // parameter ...
    // ...
    localparam integer RAW = 1,      // reg (32-bit) number = 2**RAW
)(
    input wire aclk, aresetn,
    // --- s_axi ---
    (* mark_debug = "true" *) input  wire  [RAW+1 : 0] s_axi_awaddr ,
                              input  wire  [    2 : 0] s_axi_awprot ,
    (* mark_debug = "true" *) input  wire              s_axi_awvalid,
    (* mark_debug = "true" *) output logic             s_axi_awready,
    (* mark_debug = "true" *) input  wire  [   31 : 0] s_axi_wdata  ,
                              input  wire  [    3 : 0] s_axi_wstrb  ,
    (* mark_debug = "true" *) input  wire              s_axi_wvalid ,
    (* mark_debug = "true" *) output logic             s_axi_wready ,
                              output logic [    1 : 0] s_axi_bresp  ,
    (* mark_debug = "true" *) output logic             s_axi_bvalid ,
    (* mark_debug = "true" *) input  wire              s_axi_bready ,
    (* mark_debug = "true" *) input  wire  [RAW+1 : 0] s_axi_araddr ,
                              input  wire  [    2 : 0] s_axi_arprot ,
    (* mark_debug = "true" *) input  wire              s_axi_arvalid,
    (* mark_debug = "true" *) output logic             s_axi_arready,
    (* mark_debug = "true" *) output logic [   31 : 0] s_axi_rdata  ,
                              output logic [    1 : 0] s_axi_rresp  ,
    (* mark_debug = "true" *) output logic             s_axi_rvalid ,
    (* mark_debug = "true" *) input  wire              s_axi_rready ,
    // --- interrupt ---
    // (* mark_debug = "true" *) output logic             intr
);
    wire clk = aclk;
    wire rst = ~aresetn;
    (* mark_debug = "true" *) logic regs_wr, regs_rd;
    // ==== aw channel ====
    assign s_axi_awready = 1'b1;    // always ready
    (* mark_debug = "true" *) logic [RAW-1 : 0] waddr_reg;   // byte addr --> reg addr
    always_ff@(posedge clk) begin
        if(rst) waddr_reg <= '0;
        else if(s_axi_awvalid) waddr_reg <= s_axi_awaddr[2+:RAW];
    end
    // === w channel ===
    assign regs_wr = s_axi_wvalid & s_axi_wready;
    always_ff@(posedge clk) begin
        if(rst) s_axi_wready <= 1'b0;
        else if(s_axi_awvalid) s_axi_wready <= 1'b1;               //waddr got
        else if(s_axi_wvalid & s_axi_wready) s_axi_wready <= 1'b0; //handshake
    end
    // === b ch ===
    assign s_axi_bresp = 2'b00;     // always ok
    always_ff@(posedge clk) begin
        if(rst) s_axi_bvalid <= 1'b0;
        else if(s_axi_wvalid & s_axi_wready) s_axi_bvalid <= 1'b1; //wdata got
        else if(s_axi_bvalid & s_axi_bready) s_axi_bvalid <= 1'b0; //handshake
    end
    // === ar ch ===
    (* mark_debug = "true" *) logic [RAW-1 : 0] raddr_reg;
    always_ff@(posedge clk) begin
        if(rst) raddr_reg <= 1'b0;
        else if(s_axi_arvalid) raddr_reg <= s_axi_araddr[2+:RAW];
    end
    always_ff@(posedge clk) begin
        if(rst) s_axi_arready <= 1'b0;
        else if(s_axi_arvalid & ~s_axi_arready) s_axi_arready <= 1'b1; //raddr got
        else if(s_axi_arvalid &  s_axi_arready) s_axi_arready <= 1'b0; //handshake
    end
    assign regs_rd = s_axi_arvalid & s_axi_arready;
    // === r ch ===
    assign s_axi_rresp = 2'b00;     // always ok
    always_ff@(posedge clk) begin
        if(rst) s_axi_rvalid <= 1'b0;
        else if(regs_rd) s_axi_rvalid <= 1'b1;
        else if(s_axi_rvalid & s_axi_rready) s_axi_rvalid <= 1'b0;
    end

    // === user logic below ===
    // - drive s_axi_rdata by user regs/logic & raddr_reg @ regs_rd == 1
    // e.g.:
        // always_ff@(posedge clk) begin
        //     if(rst) s_axi_rdata <= '0;
        //     else if(regs_rd) begin
        //         s_axi_rdata <= raddr_reg == 0 ? xxxx :
        //                        raddr_reg == 1 ? xxxx : ... ;
        //     end
        // end

    // - drive user regs/logics by s_axi_wdata, s_axi_wstrb & waddr_reg @ regs_wr == 1
    // e.g.:
        // always_ff@(posedge clk) begin
        //     if(rst) xxx <= '0;
        //     else if(regs_wr && waddr_reg == xxx) begin
        //             xxx[ 0+:8] <= s_axi_wstrb[0]? s_axi_wdata[ 0+:8];
        //             xxx[ 8+:8] <= s_axi_wstrb[1]? s_axi_wdata[ 8+:8];
        //             xxx[16+:8] <= s_axi_wstrb[2]? s_axi_wdata[16+:8];
        //             xxx[24+:8] <= s_axi_wstrb[3]? s_axi_wdata[24+:8];
        //     end
        // end

    // - drive intr and associated ie, is and etc., if interrupt(s) need
    // e.g.:
        // assign intr = |(ie & is);
        // always_ff@(posedge clk) begin
        //     if(rst) is <= '0;
        //     else begin
        //         if(regs_wr && waddr_reg == is_addr)
        //             is <= is & ~s_axi_wdata;    // write one to clear corresponding bit(s)
        //         else begin
        //             if(/* event 1 */) is[0] <= 1'b1;
        //             if(/* event 2 */) is[1] <= 1'b1;
        //             // ...
        //         end
        //     end
        // end


endmodule
