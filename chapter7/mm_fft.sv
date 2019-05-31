`include "../common.sv"
`include "../chapter4/memory.sv"
`include "../chapter6/mm_intercon.sv"

`timescale 1ns/100ps
`default_nettype none

module TestMmFFT;
    import SimSrcGen::*;
    localparam FFTM = 8, LEN = 2**FFTM;
    logic clk, rst;
    initial GenClk(clk, 80, 100);
    initial GenRst(clk, rst, 2, 2);
    typedef struct {
        logic signed [15:0] re;
        logic signed [15:0] im;
    } Cplx;
    Cplx x[LEN]; 
    initial begin
        for(int n = 0; n < LEN; n++) begin
            x[n].re = n < LEN / 2 ? 16'sd10000 : -16'sd10000;
            x[n].im = 16'sd0;
        end
    end
    PicoMmIf #(FFTM+2) dataIf(clk, rst);
    PicoMmIf #(1) ctrlIf(clk, rst);
    logic irq, irq_ack = '0;
    MmFFT #( FFTM, 16 ) theMmFFT(
        ctrlIf, dataIf, irq, irq_ack);
    initial begin
        repeat(10) @(posedge clk);
        // write data
        for(int n = 0; n < LEN; n++) begin
            dataIf.Write(n*2,   x[n].re);
            dataIf.Write(n*2+1, x[n].im);
        end
        // start transform
        ctrlIf.Write(0, 0); // fft & scale
        // wait irq & clear
        do @(posedge clk);
        while(~irq);
        irq_ack <= 1'b1;
        @(posedge clk) irq_ack <= 1'b0;
        // read data
        for(int n = 0; n < LEN; n++) begin
            dataIf.Read(2*LEN + n*2);
            @(posedge clk) x[n].re <= dataIf.rddata;
            dataIf.Read(2*LEN + n*2+1);
            @(posedge clk) x[n].im <= dataIf.rddata;
        end
        // write data for inverse fft
        for(int n = 0; n < LEN; n++) begin
            dataIf.Write(n*2,   x[n].re);
            dataIf.Write(n*2+1, x[n].im);
        end
        // start transform
        ctrlIf.Write(0, 3); // ifft & no scale
        // wait irq & clear
        do @(posedge clk);
        while(~irq);
        irq_ack <= 1'b1;
        @(posedge clk) irq_ack <= 1'b0;
        // read data
        for(int n = 0; n < LEN; n++) begin
            dataIf.Read(2*LEN + n*2);
            @(posedge clk) x[n].re <= dataIf.rddata;
            dataIf.Read(2*LEN + n*2+1);
            @(posedge clk) x[n].im <= dataIf.rddata;
        end
        // end sim
        repeat(100) @(posedge clk);
        $stop;
    end
endmodule

module FFTCoefRom #( parameter DW = 16, AW = 7, RI = "Real" )(
    input wire clk,
    input wire [AW-1:0] addr,
    output logic signed [DW-1:0] qout
);
    logic signed [DW-1:0] ram[0 : 2**AW - 1];
    initial begin
        for(int k = 0; k < 2**AW; k++) begin
            if(RI == "Real")
                ram[k] = $cos(3.1415926536 * k / 2**AW) * (2**(DW-1) - 1);
            else
                ram[k] = $sin(3.1415926536 * k / 2**AW) * (2**(DW-1) - 1);
        end
    end
    always_ff@(posedge clk) qout <= ram[addr];
endmodule

// sc: control only one address
//      write 0: start fft with scale
//      write 1: start fft without scale
//      write 2: start ifft with scale
//      write 3: start ifft without scale
//      read: M = (Log2(LEN))
// sd: access data ram, eg: M=8, L=256:
//       0  ~  511: normal order access
//          x[i]_real <--> addr = i * 2
//          x[i]_imag <--> addr = i * 2 + 1
//      512 ~ 1023: bit reversed order access
//          x[i]_real <--> addr = br(i) * 2 + 512
//          x[i]_imag <--> addr = br(i) * 2 + 513
module MmFFT #( parameter M = 8, DW = 16 )(
    PicoMmIf.slave sc,
    PicoMmIf.slave sd,    // addr width = M+2
    output logic irq,
    input wire irq_ack
);
    assign sc.rddata = M;
    localparam N = 2**M, MW = $clog2(M);
    localparam NW = M;
    let BitReverse(in) = {<<{in}};
    //====== arithmatic ctrl registers ======
    logic [1:0] mode, mode_nxt;
    logic busy, busy_nxt;
    logic [MW-1:0] step, step_nxt;
    logic [NW-1:0] grp, grp_nxt, grpLen, grpLen_nxt;
    logic [NW-1:0] i, i_nxt, j, j_nxt, k, k_nxt;
    logic [1:0] cyc, cyc_nxt;
    //====== ram and rom connection ======
    // fft calc core
    logic fft_wr;
    logic [M-1:0] fft_addr;
    logic signed [DW-1:0] fft_real_d, fft_imag_d;
    // pico mm
    logic sd_real_wr, sd_imag_wr;
    logic [M-1:0] sd_addr;
    logic signed [DW-1:0] sd_real_d, sd_imag_d;
    // data ram
    wire data_real_wr = busy? fft_wr : sd_real_wr;
    wire data_imag_wr = busy? fft_wr : sd_imag_wr;
    wire signed [DW-1:0] data_real_d = busy? fft_real_d : sd_real_d;
    wire signed [DW-1:0] data_imag_d = busy? fft_imag_d : sd_imag_d;
    wire [M-1:0] data_addr = busy? fft_addr : sd_addr;
    logic signed [DW-1:0] data_real_q, data_imag_q;
    // coef rom
    logic [M-2:0] coef_addr;
    logic signed [DW-1:0] coef_real_q, coef_imag_qi;
    wire signed [DW-1:0] coef_imag_q = mode[1]? 1'sb0 - coef_imag_qi : coef_imag_qi;
    SpRamRf #(DW, 2**M) realDataRam (
        sc.clk, data_addr, data_real_wr,
        data_real_d, data_real_q );
    SpRamRf #(DW, 2**M) imagDataRam (
        sc.clk, data_addr, data_imag_wr,
        data_imag_d, data_imag_q );
    FFTCoefRom #(DW, M - 1, "Real") realCoefRom (
        sc.clk, coef_addr, coef_real_q );
    FFTCoefRom #(DW, M - 1, "Imag") imagCoefRom (
        sc.clk, coef_addr, coef_imag_qi );
    //====== PicoMM slave ======
    assign sd_real_wr = sd.write & (~sd.addr[0]);
    assign sd_imag_wr = sd.write & (sd.addr[0]);
    assign sd_addr = sd.addr[M+1] ? BitReverse(sd.addr[M:1]) : sd.addr[M:1];
    assign sd_real_d = sd.wrdata;
    assign sd_imag_d = sd.wrdata;
    logic sd_addr_reg;
    always_ff@(posedge sc.clk) sd_addr_reg <= sd.addr[0];
    always_comb sd.rddata = 32'(sd_addr_reg ? data_imag_q : data_real_q);
    // ====== irq ======
    always@(posedge sc.clk) begin
        if(sc.rst) irq <= 1'b0;
        else if(busy_nxt == 1'b0 && busy == 1'b1) irq <= 1'b1;
        else if(irq_ack) irq <= 1'b0;
    end
    //====== FFT arithmatic fsm ======
    always_ff@(posedge sc.clk) begin
        if(sc.rst) begin
            mode   <= 2'b0; busy <= 1'b0; step <= 1'b0;
            grpLen <= 1'b0; grp  <= 1'b0; i    <= 1'b0;
            j      <= 1'b0; k    <= 1'b0; cyc  <= 1'b0;
        end
        else begin
            mode <= mode_nxt; busy   <= busy_nxt  ;
            step <= step_nxt; grpLen <= grpLen_nxt;
            grp  <= grp_nxt ; i      <= i_nxt     ;
            j    <= j_nxt   ; k      <= k_nxt     ;
            cyc  <= cyc_nxt ;
        end
    end
    always_comb begin
        mode_nxt   = mode  ; busy_nxt = busy; step_nxt = step;
        grpLen_nxt = grpLen; grp_nxt  = grp ; i_nxt    = i   ;
        j_nxt      = j     ; k_nxt    = k   ; cyc_nxt  = cyc ;
        if(busy == 1'b0) begin  // idle
            if(sc.write) begin  // start
                mode_nxt   = sc.wrdata[1 : 0];
                busy_nxt   = 1'b1;
                step_nxt   = 1'b0;
                grpLen_nxt = 1'b1 << (M - 1);
                grp_nxt    = 1'b0;
                i_nxt      = 1'b0;
                j_nxt      = 1'b1 << (M - 1);
                k_nxt      = 1'b0;
                cyc_nxt    = 1'b0;
            end
        end
        else begin // busy
            if(cyc < 3'h3) cyc_nxt = cyc + 2'b1; // cyc loop
            else if(i < grp + grpLen - 1) begin  // i loop
                i_nxt   = i + 1'b1;
                j_nxt   = j + 1'b1;
                k_nxt   = k + (1'b1 << step);
                cyc_nxt = 1'b0;
            end
            else if(grp < N - (grpLen << 1)) begin // grp loop
                grp_nxt = grp + (grpLen << 1);
                i_nxt   = grp_nxt;
                j_nxt   = grp_nxt + grpLen;
                k_nxt   = 1'b0;
                cyc_nxt = 1'b0;
            end
            else if(step < M - 1'b1) begin // step loop
                step_nxt   = step + 1'b1;
                grpLen_nxt = grpLen >> 1;
                grp_nxt    = 1'b0;
                i_nxt      = 1'b0;
                j_nxt      = grpLen_nxt;
                k_nxt      = 1'b0;
                cyc_nxt    = 1'b0;
            end
            else busy_nxt = 1'b0; // finish!
        end
    end
    //====== calculation ======
    function automatic signed [DW-1:0] trim_add(input signed [DW-1:0] x, y);
        logic signed [DW : 0] full_add = x + y;
        trim_add = mode[0]? full_add : full_add >>> 1;
    endfunction
    function automatic signed [DW-1:0] trim_sub(input signed [DW-1:0] x, y);
        logic signed [DW : 0] full_sub = x - y;
        trim_sub = mode[0]? full_sub : full_sub >>> 1;
    endfunction
    `DEF_FP_MUL(mul, 1, DW-1, 1, DW-1, DW-1);
//    function signed [DW-1:0] mul(input signed [DW-1:0] x, y);
//        mul = ((2*DW)'(x) * (2*DW)'(y)) >>> (DW-1);
//    endfunction
    logic signed [DW-1:0] j_real, j_imag;
    wire signed [DW-1:0] sub_real = trim_sub(data_real_q, j_real);
    wire signed [DW-1:0] sub_imag = trim_sub(data_imag_q, j_imag);
    wire signed [DW-1:0] mprr = mul(sub_real, coef_real_q);
    wire signed [DW-1:0] mpii = mul(sub_imag, coef_imag_q);
    wire signed [DW-1:0] mpri = mul(sub_real, coef_imag_q);
    wire signed [DW-1:0] mpir = mul(sub_imag, coef_real_q);
    always_ff@(posedge sc.clk) begin
        if(sc.rst) begin j_real <= 1'b0; j_imag <= 1'b0; end
        if(cyc==3'h1) begin // store j
            j_real <= data_real_q;
            j_imag <= data_imag_q;
        end
    end
    always_comb begin
        case(cyc)
            3'h0: begin // read x[j]
                fft_addr   = j   ; fft_wr     = 1'b0;
                coef_addr  = k   ;
                fft_real_d = 1'b0; fft_imag_d = 1'b0;
            end
            3'h1: begin // read x[i]
                fft_addr   = i   ;     fft_wr = 1'b0;
                coef_addr  = k   ;
                fft_real_d = 1'b0; fft_imag_d = 1'b0;
            end
            3'h2: begin // write x[i]
                fft_addr   = i; fft_wr = 1'b1;
                coef_addr  = k;
                fft_real_d = trim_add(data_real_q, j_real);
                fft_imag_d = trim_add(data_imag_q, j_imag);
            end
            3'h3: begin // write x[j]
                fft_addr = j; fft_wr = 1'b1;
                coef_addr = k;
                // sub_real * coef_real_q - sub_imag * coef_imag_q;
                fft_real_d = mprr - mpii;
                // sub_real * coef_imag_q + sub_imag * coef_real_q;
                fft_imag_d = mpri + mpir;
            end
            default: begin
                fft_addr   = i   ; fft_wr     = 1'b0;
                coef_addr  = k   ;
                fft_real_d = 1'b0; fft_imag_d = 1'b0;
            end
        endcase
    end
endmodule


