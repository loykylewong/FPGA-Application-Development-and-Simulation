`ifndef __IIC_SLAVE_SV__
`define __IIC_SLAVE_SV__

`include "../chapter4/edge2en.sv"

`default_nettype none
`timescale 1ns/100ps

module IicSlave #(
    parameter integer SLV_ADDR = 127,  // 7-bit slave address
    parameter integer IADDR_WIDTH = 8
)(
    input wire clk, rst,
    IicBus iic,
    output logic [IADDR_WIDTH - 1 : 0] m_address,
    output logic [7:0] m_writedata,
    output logic m_write,
    input wire [7:0] m_readdata,
    output logic m_read
);
    assign iic.scl_o = 1'b1, iic.scl_t = 1'b1;
    assign iic.sda_t = iic.sda_o;
    logic sda_rising, sda_falling, scl_rising, scl_falling;
    logic sda, scl;
    Edge2En e2eSda(clk, iic.sda_i, sda_rising, sda_falling, sda);
    Edge2En e2eScl(clk, iic.scl_i, scl_rising, scl_falling, scl);
    wire start = scl & sda_falling;
    wire stop = scl & sda_rising;
    localparam S_IDLE       = 3'd0;
    localparam S_RECV_SADDR = 3'd1;
    localparam S_RECV_IADDR = 3'd2;
    localparam S_RECV_DATA  = 3'd3;
    localparam S_TRANS_DATA = 3'd4;
    logic [7 : 0] outdata;
    logic [2 : 0] state, state_nxt;
    logic [3 : 0] bitcnt, bitcnt_nxt;
    logic [$clog2(IADDR_WIDTH+1)-1 : 0] ia_bitcnt, ia_bitcnt_nxt;
    
    // sda       ^\___<=A6=><=A5=><=A4=><=A3=><=A2=><=A1=><=A0=><=RW=><ACK=><=D7=><=D6=><=D5=><=D4=><=D3=><=D2=><=D1=><=D0=><ACK=>_____/^
    // scl       ^^^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^^^
    // bitcnt    X><0><=1==><=2==><=3==><=4==><=5==><=6==><=7==><=8==><=9==><=1==><=2==><=3==><=4==><=5==><=6==><=7==><=8==><=9==><=1==><
    // ia_bitcnt XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX><=0==><=1==><=2==><=3==><=4==><=5==><=6==><=7==><=8==><=8==><
    // state     =><=S_RECV_SADDR=========================================><=S_RECV_IADDR====================================><======

    // m_address
    always_ff@(posedge clk) begin
        if(state == S_RECV_IADDR && bitcnt == 4'd9 && scl_rising)
            m_address <= (m_address << 8) | m_writedata;
        else if(m_write | m_read)
            m_address <= m_address + 1'b1;
    end
    // m_write
    always_ff@(posedge clk) begin
        if(state == S_RECV_DATA && bitcnt == 4'd9 && scl_rising)
            m_write <= 1'b1;
        else
            m_write <= 1'b0;
    end
    // m_writedata
    always_ff@(posedge clk) begin
        if(bitcnt < 4'd9 && scl_rising)
            m_writedata <= (m_writedata << 1) | sda;
    end
    // m_read
    always_ff@(posedge clk) begin
        if(bitcnt == 4'd9 && scl_rising) begin
            if(state == S_TRANS_DATA && (~sda))
                m_read <= 1'b1;
            else if(state == S_RECV_SADDR &&
                    (m_writedata[7 : 1] == SLV_ADDR) && m_writedata[0])
                m_read <= 1'b1;
            else
                m_read <= 1'b0;
        end
        else m_read <= 1'b0;
    end
    // m_readdata
    logic m_read_dly; always_ff@(posedge clk) m_read_dly <= m_read;
    always_ff@(posedge clk) begin
        if(bitcnt > 4'd0 && bitcnt < 4'd9 && scl_falling)
            outdata <= (outdata << 1);
        else if(m_read_dly)
            outdata <= m_readdata;
    end
    // iic.sda_o
    always_ff@(posedge clk) begin
        if(bitcnt < 4'd9) begin
            if(state == S_TRANS_DATA) iic.sda_o = outdata[7];
            else                      iic.sda_o = 1'b1;
        end
        else begin
            case(state)
            S_IDLE: iic.sda_o = 1'b1;
            S_RECV_SADDR:
                if(m_writedata[7 : 1] == SLV_ADDR) iic.sda_o = 1'b0;
                else iic.sda_o = 1'b1;
            S_RECV_IADDR: iic.sda_o = 1'b0;
            S_RECV_DATA: iic.sda_o = 1'b0;
            S_TRANS_DATA: iic.sda_o = 1'b1;
            endcase
        end
    end
    //======== state machine ========
    always_ff@(posedge clk) begin
        if(rst) begin
            state <= S_IDLE; bitcnt <= '0; ia_bitcnt <= '0;
        end
        else begin
            state <= state_nxt;
            bitcnt <= bitcnt_nxt;
            ia_bitcnt <= ia_bitcnt_nxt;
        end
    end
    always_comb begin
        state_nxt = state;
        bitcnt_nxt = bitcnt;
        ia_bitcnt_nxt = ia_bitcnt;
        if(stop) state_nxt = S_IDLE;
        else if(start) begin
            state_nxt = S_RECV_SADDR;
            bitcnt_nxt = 1'b0;
        end
        else if(scl_falling) begin
            if(bitcnt < 4'd9) begin
                bitcnt_nxt = bitcnt + 1'b1;
                ia_bitcnt_nxt = ia_bitcnt + 1'b1;
            end
            else begin                // bitcnt == 9
                bitcnt_nxt = 4'd1;
                case(state)
                S_RECV_SADDR: begin
                    if(m_writedata[7 : 1] != SLV_ADDR)
                        state_nxt = S_IDLE;
                    else if(m_writedata[0])         // read
                            state_nxt = S_TRANS_DATA;
                    else begin                      // write
                        if(IADDR_WIDTH == 0)
                            state_nxt = S_RECV_DATA;
                        else begin
                            state_nxt = S_RECV_IADDR;
                            ia_bitcnt_nxt = 1'b0;
                        end
                    end
                end
                S_RECV_IADDR: begin
                    if(ia_bitcnt >= IADDR_WIDTH)
                        state_nxt = S_RECV_DATA;
                end
                S_TRANS_DATA: begin
                    if(sda) state_nxt = S_IDLE;     //nak
                end
                default: state_nxt = state;
                endcase
            end
        end
    end
endmodule

`endif
