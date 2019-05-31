`default_nettype none
`timescale 1ns/100ps

module Axi4LiteSlave #(parameter REG_NUM = 8)(
    Axi4LiteIf.slave s,
    output logic [31:0] regs[REG_NUM]
);
    logic regs_wr, regs_rd;
    // ==== aw channel ====
    assign s.awready = 1'b1;    // always ready
    logic [s.AW-3 : 0] waddr_reg;   // byte addr --> reg addr
    always_ff@(posedge s.clk) begin
        if(~s.reset_n) waddr_reg <= '0;
        else if(s.awvalid) waddr_reg <= s.awaddr[s.AW-1 : 2];
    end
    // === w channel ===
    assign regs_wr = s.wvalid & s.wready;
    always_ff@(posedge s.clk) begin
        if(~s.reset_n) s.wready <= 1'b0;
        else if(s.awvalid) s.wready <= 1'b1;          //waddr got
        else if(s.wvalid & s.wready) s.wready <= 1'b0; //handshake
    end
    // === b ch ===
    assign s.bresp = 2'b00;     // always ok
    always_ff@(posedge s.clk) begin
        if(~s.reset_n) s.bvalid <= 1'b0;
        else if(s.wvalid & s.wready) s.bvalid <= 1'b1;//wdata got
        else if(s.bvalid & s.bready) s.bvalid <= 1'b0;//handshake
    end
    // === ar ch ===
    logic [s.AW-3 : 0] raddr_reg;
    always_ff@(posedge s.clk) begin
        if(~s.reset_n) raddr_reg <= 1'b0;
        else if(s.arvalid) raddr_reg <= s.araddr[s.AW-1 : 2];
    end
    always_ff@(posedge s.clk) begin
        if(~s.reset_n) s.arready <= 1'b0;
        else if(s.arvalid & ~s.arready) s.arready <= 1'b1;            //raddr got
        else if(s.arvalid & s.arready) s.arready <= 1'b0;//handshake
    end
    assign regs_rd = s.arvalid & s.arready;
    // === r ch ===
    assign s.rresp = 2'b00;     // always ok
    always_ff@(posedge s.clk) begin
        if(~s.reset_n) s.rvalid <= 1'b0;
        else if(regs_rd) s.rvalid <= 1'b1;
        else if(s.rvalid & s.rready) s.rvalid <= 1'b0;
    end
    always_ff@(posedge s.clk) begin
        if(regs_rd) s.rdata <= regs[raddr_reg];
    end
    // === regs ===
    always_ff@(posedge s.clk) begin
        if(~s.reset_n) regs = '{REG_NUM{'0}};
        else if(regs_wr) begin
            if(s.wstrb[0]) regs[waddr_reg][0+:8] <= s.wdata[0+:8];
            if(s.wstrb[1]) regs[waddr_reg][8+:8] <= s.wdata[8+:8];
            if(s.wstrb[2]) regs[waddr_reg][16+:8] <= s.wdata[16+:8];
            if(s.wstrb[3]) regs[waddr_reg][24+:8] <= s.wdata[24+:8];
        end
    end
endmodule
