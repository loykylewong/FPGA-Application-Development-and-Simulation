/*
 * MIT License
 *
 * Copyright (c) 2025 loykylewong (loywong@gmail.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package loywong

import chisel3._
import chisel3.util._
// import scala.math
import java.io.{FileWriter, PrintWriter}
import scala.util.Try
import scala.util.Using

object MemoryInitFiles {
    /**
     * Generate a sine wave Seq
     *
     * @param length    Length of the Seq to be generated
     * @param dataWidth Width (bits) of each element in Seq
     * @param phase     Phase shift of generated sine wave
     * @param fullScale Dynamic range of generated sine wave, default full
     * @param cycles    Number of cycles of the sine wave
     * @param isSigned  True for 2's compliment data, false for binary offset data
     * @return The generated sine wave Seq
     */
    def SineWava(length: Int, dataWidth: Int, phase: Double = 0.0, fullScale: Double = 1.0, cycles: Double = 1.0, isSigned: Boolean = true): IndexedSeq[Long] = {
        val ampMax: Double = (1L << (dataWidth - 1)) - 1.0
        val ampDesire: Double = (1L << (dataWidth - 1)) * fullScale
        val amp = math.min(ampMax, ampDesire)
        val bias = if (isSigned) 0L else 1L << (dataWidth - 1)
        val omega = 2.0 * math.Pi * cycles / length
        (0 until length).map { i =>
            bias + math.round(amp * math.sin(omega * i + phase))
        }
    }

    /**
     * Generate a cosine wave Seq
     *
     * @param length    Length of the Seq to be generated
     * @param dataWidth Width (bits) of each element in Seq
     * @param phase     Phase shift of generated sine wave
     * @param fullScale Dynamic range of generated sine wave, default full
     * @param cycles    Number of cycles of the sine wave
     * @param isSigned  True for 2's compliment data, false for binary offset data
     * @return The generated cosine wave Seq
     */
    def CosineWave(length: Int, dataWidth: Int, phase: Double = 0.0, fullScale: Double = 1.0, cycles: Double = 1.0, isSigned: Boolean = true): IndexedSeq[Long] = {
        SineWava(length, dataWidth, phase + math.Pi / 2.0, fullScale, cycles, isSigned)
    }

    /**
     * Write memory initialize data file, which can be used by `$readmemh` system call in verilog
     *
     * @param fileName Path and name of the data file
     * @param data     Data Seq to be written in the file
     * @tparam T Type of data (element in Seq), must be Int or Long
     */
    def Write[T: Integral](fileName: String, data: Seq[T]): Try[Unit] = {
        Using(new PrintWriter(new FileWriter(fileName))) { writer =>
            data.foreach { d =>
                writer.println(f"${Integral[T].toLong(d)}%016x")
            }
        }
    }
}

/**
 * Collection of RAM IOs
 */
object RamIO {
    /**
     * Represent a hardware RAM IO of Single port Read and Write.
     * @param nWords    Number of Words (elements) in RAM
     * @param gen       Generator of Data
     * @tparam T        Type of Data
     */
    class RW[T <: Data](nWords: Long, gen: T) extends Bundle {
        require(nWords >= 2, "nWords must be >= 2 in RamIO.RW.")
        val addr = Input(UInt(log2Up(nWords).W))
        val we = Input(Bool())
        val din = Input(gen)
        val dout = Output(gen)
    }

    /**
     * Represent a hardware RAM IO of Single Port Read.
     * @param nWords    Number of Words (elements) in RAM
     * @param gen       Generator of Data
     * @tparam T        Type of Data
     */
    class R[T <: Data](nWords: Long, gen: T) extends Bundle {
        require(nWords >= 2, "nWords must be >= 2 in RamIO.R.")
        val addr = Input(UInt(log2Up(nWords).W))
        val dout = Output(gen)
    }

    /**
     * Represent a hardware RAM IO of Single Port Write.
     * @param nWords    Number of Words (elements) in RAM
     * @param gen       Generator of Data
     * @tparam T        Type of Data
     */
    class W[T <: Data](nWords: Long, gen: T) extends Bundle {
        require(nWords >= 2, "nWords must be >= 2 in RamIO.W.")
        val addr = Input(UInt(log2Up(nWords).W))
        val en = Input(Bool())
        val din = Input(gen)
    }

    /**
     * Represent a hardware RAM IO of Single port Read and Write with Clock.
     * @param nWords    Number of Words (elements) in RAM
     * @param gen       Generator of Data
     * @tparam T        Type of Data
     */
    class CRW[T <: Data](nWords: Long, gen: T) extends Bundle {
        require(nWords >= 2, "nWords must be >= 2 in RamIO.CRW.")
        val clock = Input(Clock())
        val addr = Input(UInt(log2Up(nWords).W))
        val we = Input(Bool())
        val din = Input(gen)
        val dout = Output(gen)
    }

    /**
     * Represent a hardware RAM IO of Single Port Read with Clock.
     * @param nWords    Number of Words (elements) in RAM
     * @param gen       Generator of Data
     * @tparam T        Type of Data
     */
    class CR[T <: Data](nWords: Long, gen: T) extends Bundle {
        require(nWords >= 2, "nWords must be >= 2 in RamIO.CR.")
        val clock = Input(Clock())
        val addr = Input(UInt(log2Up(nWords).W))
        val dout = Output(gen)
    }

    /**
     * Represent a hardware RAM IO of Single Port Write with Clock.
     * @param nWords    Number of Words (elements) in RAM
     * @param gen       Generator of Data
     * @tparam T        Type of Data
     */
    class CW[T <: Data](nWords: Long, gen: T) extends Bundle {
        require(nWords >= 2, "nWords must be >= 2 in RamIO.CW.")
        val clock = Input(Clock())
        val addr = Input(UInt(log2Up(nWords).W))
        val en = Input(Bool())
        val din = Input(gen)
    }
}

// Unfortunately, SyncReadMem.ReadFirst and WriteFirst seems not work.
//class SpRamRf[T <: Data](nWords: Int, gen: T) extends Module {
//    val io = IO(new RamIO.SRW(nWords, gen))
//    // It's recommended using chisel3.SyncReadMem directly in code,
//    // No need to wrap a module like this.
//    val mem = SyncReadMem(nWords, gen, SyncReadMem.ReadFirst)
//    io.dout := mem.read(io.addr)
//    when(io.we) {
//        mem.write(io.addr, io.din)
//    }
//}
//class SpRamWf[T <: Data](nWords: Int, gen: T) extends Module {
//    val io = IO(new RamIO.SRW(nWords, gen))
//    // It's recommended using chisel3.SyncReadMem directly in code,
//    // No need to wrap a module like this.
//    val mem = SyncReadMem(nWords, gen, SyncReadMem.WriteFirst)
//    io.dout := mem.read(io.addr)
//    when(io.we) {
//        mem.write(io.addr, io.din)
//    }
//}

/**
 * Represent a hardware Read First Simple Dual Port Synchronous Read RAM module,
 * when reading the word being written, read the old data.
 * @param nWords    Number of Words (elements) in RAM
 * @param dataWidth Data Width
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 */
class SdpRamRfInline(nWords: Long, dataWidth: Int, initFile: Option[String] = None) extends HasBlackBoxInline {
    require(nWords > 0 && dataWidth > 0)
    override def desiredName = s"${super.desiredName}_${nWords}x${dataWidth}b"

    val io = IO(new Bundle {
        val clock = Input(Clock())
        val waddr = Input(UInt(log2Up(nWords).W))
        val we    = Input(Bool())
        val din   = Input(UInt(dataWidth.W))
        val raddr = Input(UInt(log2Up(nWords).W))
        val qout  = Output(UInt(dataWidth.W))
    })
    setInline(s"${desiredName}.v",
        s"""
           |module ${desiredName} #(
           |    parameter DW = ${dataWidth}, WORDS = ${nWords}
           |)(
           |    input wire                         clock,
           |    input wire [$$clog2(WORDS) - 1 : 0] waddr,
           |    input wire                         we   ,
           |    input wire [DW - 1            : 0] din  ,
           |    input wire [$$clog2(WORDS) - 1 : 0] raddr,
           |    output reg [DW - 1            : 0] qout
           |);
           |    reg [DW - 1 : 0] ram[0 : WORDS - 1];
           |    ${if (initFile.isDefined) s"$$readmemh(\"${initFile.get}\", ram)" else ""}
           |    always@(posedge clock) begin
           |        if(we) ram[waddr] <= din;
           |        qout <= ram[raddr];
           |    end
           |endmodule
           |""".stripMargin
    )
}

/**
 * Represent a hardware Write First Simple Dual Port Synchronous Read RAM module,
 * when reading the word being written, read the new data.
 * @param nWords    Number of Words (elements) in RAM
 * @param dataWidth Data Width
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 */
class SdpRamWfInline(nWords: Long, dataWidth: Int, initFile: Option[String] = None) extends HasBlackBoxInline {
    require(nWords > 0 && dataWidth > 0)
    override def desiredName = s"${super.desiredName}_${nWords}x${dataWidth}b"

    val io = IO(new Bundle {
        val clock = Input(Clock())
        val waddr = Input(UInt(log2Up(nWords).W))
        val we    = Input(Bool())
        val din   = Input(UInt(dataWidth.W))
        val raddr = Input(UInt(log2Up(nWords).W))
        val qout  = Output(UInt(dataWidth.W))
    })
    setInline(s"${desiredName}.v",
        s"""
           |module ${desiredName} #(
           |    parameter DW = ${dataWidth}, WORDS = ${nWords}
           |)(
           |    input wire                         clock,
           |    input wire [$$clog2(WORDS) - 1 : 0] waddr,
           |    input wire                         we   ,
           |    input wire [DW - 1            : 0] din  ,
           |    input wire [$$clog2(WORDS) - 1 : 0] raddr,
           |    output reg [DW - 1            : 0] qout
           |);
           |    reg [DW - 1 : 0] ram[0 : WORDS - 1];
           |    ${if (initFile.isDefined) s"$$readmemh(\"${initFile.get}\", ram)" else ""}
           |    always@(posedge clock) begin
           |        if(we) begin
           |            ram[waddr] <= din;
           |        end
           |    end
           |    always@(posedge clock) begin
           |        if(we && raddr == waddr)
           |            qout <= din
           |        else
           |            qout <= ram[raddr]
           |    end
           |endmodule
           |""".stripMargin
    )
}

/**
 * Represent a hardware Simple Dual Port Asynchronous Read RAM module.
 * @param nWords    Number of Words (elements) in RAM
 * @param dataWidth Data Width
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 */
class SdpRamRaInline(nWords: Long, dataWidth: Int, initFile: Option[String] = None) extends HasBlackBoxInline {
    require(nWords > 0 && dataWidth > 0)
    override def desiredName = s"${super.desiredName}_${nWords}x${dataWidth}b"

    val io = IO(new Bundle {
        val clock = Input(Clock())
        val waddr = Input(UInt(log2Up(nWords).W))
        val we    = Input(Bool())
        val din   = Input(UInt(dataWidth.W))
        val raddr = Input(UInt(log2Up(nWords).W))
        val dout  = Output(UInt(dataWidth.W))
    })
    setInline(s"${desiredName}.v",
        s"""
           |module ${desiredName} #(   // asynchronous read
           |    parameter DW = ${dataWidth}, WORDS = ${nWords}
           |)(
           |    input wire                         clock,
           |    input wire [$$clog2(WORDS) - 1 : 0] waddr,
           |    input wire                         we   ,
           |    input wire [DW - 1            : 0] din  ,
           |    input wire [$$clog2(WORDS) - 1 : 0] raddr,
           |    output reg [DW - 1            : 0] dout
           |);
           |    reg [DW - 1 : 0] ram[0 : WORDS - 1];
           |    ${if (initFile.isDefined) s"$$readmemh(\"${initFile.get}\", ram)" else ""}
           |    always@(posedge clock) begin
           |        if(we) ram[waddr] <= din;
           |    end
           |    assign dout = ram[raddr];
           |endmodule
           |
           |""".stripMargin
    )
}

/**
 * Represent a hardware True Dual Port Synchronous Read RAM module.
 * @param nWords    Number of Words (elements) in RAM
 * @param dataWidth Data Width
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @note
 *       - Write First inner each port.
 *       - Read First between ports, but not guaranteed when inferred using
 *         blockRAM by FPGA synthesizer, it's the user's responsibilities to
 *         check the actual behavior or guarantee no simultaneously access to
 *         same address at both ports.
 */
class DpRamInline(nWords: Long, dataWidth: Int, initFile: Option[String] = None) extends HasBlackBoxInline {
    require(nWords > 0 && dataWidth > 0)
    override def desiredName = s"${super.desiredName}_${nWords}x${dataWidth}b"

    val io = IO(new Bundle {
        val clock  = Input(Clock())
        val addr_a = Input(UInt(log2Up(nWords).W))
        val wr_a   = Input(Bool())
        val din_a  = Input(UInt(dataWidth.W))
        val qout_a = Output(UInt(dataWidth.W))
        val addr_b = Input(UInt(log2Up(nWords).W))
        val wr_b   = Input(Bool())
        val din_b  = Input(UInt(dataWidth.W))
        val qout_b = Output(UInt(dataWidth.W))
    })
    setInline(s"${desiredName}.v",
        s"""
           |module ${desiredName} #(
           |    parameter DW = ${dataWidth}, WORDS = ${nWords}
           |)(
           |    input wire                         clock ,
           |    input wire [$$clog2(WORDS) - 1 : 0] addr_a,
           |    input wire                         wr_a  ,
           |    input wire [DW - 1            : 0] din_a ,
           |    output reg [DW - 1            : 0] qout_a,
           |    input wire [$$clog2(WORDS) - 1 : 0] addr_b,
           |    input wire                         wr_b  ,
           |    input wire [DW - 1            : 0] din_b ,
           |    output reg [DW - 1            : 0] qout_b
           |);
           |    reg [DW - 1 : 0] ram[0 : WORDS - 1];
           |    ${if (initFile.isDefined) s"$$readmemh(\"${initFile.get}\", ram)" else ""}
           |    always@(posedge clock) begin
           |        if(wr_a) begin
           |            ram[addr_a] <= din_a;
           |            qout_a <= din_a;
           |        end
           |        else qout_a <= ram[addr_a];
           |    end
           |    always@(posedge clock) begin
           |        if(wr_b) begin
           |            ram[addr_b] <= din_b;
           |            qout_b <= din_b;
           |        end
           |        else qout_b <= ram[addr_b];
           |    end
           |endmodule
           |""".stripMargin
    )
}

/**
 * Represent a hardware True Dual Clock Synchronous Read RAM module.
 * @param nWords    Number of Words (elements) in RAM
 * @param dataWidth Data Width
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @note
 *       - Write First inner each port.
 *       - Read First between ports, but not guaranteed when inferred using
 *         blockRAM by FPGA synthesizer, it's the user's responsibilities to
 *         check the actual behavior or guarantee no simultaneously access to
 *         same address at both ports.
 */
class DcRamInline(nWords: Long, dataWidth: Int, initFile: Option[String] = None) extends HasBlackBoxInline {
    require(nWords > 0 && dataWidth > 0)
    override def desiredName = s"${super.desiredName}_${nWords}x${dataWidth}b"

    val io = IO(new Bundle {
        val clock_a = Input(Clock())
        val addr_a  = Input(UInt(log2Up(nWords).W))
        val wr_a    = Input(Bool())
        val din_a   = Input(UInt(dataWidth.W))
        val qout_a  = Output(UInt(dataWidth.W))
        val clock_b = Input(Clock())
        val addr_b  = Input(UInt(log2Up(nWords).W))
        val wr_b    = Input(Bool())
        val din_b   = Input(UInt(dataWidth.W))
        val qout_b  = Output(UInt(dataWidth.W))
    })
    setInline(s"${desiredName}.v",
        s"""
           |module ${desiredName} #(
           |    parameter DW = ${dataWidth}, WORDS = ${nWords}
           |)(
           |    input wire                         clock_a ,
           |    input wire [$$clog2(WORDS) - 1 : 0] addr_a  ,
           |    input wire                         wr_a    ,
           |    input wire [DW - 1            : 0] din_a   ,
           |    output reg [DW - 1            : 0] qout_a  ,
           |    input wire                         clock_b ,
           |    input wire [$$clog2(WORDS) - 1 : 0] addr_b  ,
           |    input wire                         wr_b    ,
           |    input wire [DW - 1            : 0] din_b   ,
           |    output reg [DW - 1            : 0] qout_b
           |);
           |    reg [DW - 1 : 0] ram[0 : WORDS - 1];
           |    ${if (initFile.isDefined) s"$$readmemh(\"${initFile.get}\", ram)" else ""}
           |    always@(posedge clock_a) begin
           |        if(wr_a) begin
           |            ram[addr_a] <= din_a;
           |            qout_a <= din_a;
           |        end
           |        else qout_a <= ram[addr_a];
           |    end
           |    always@(posedge clock_b) begin
           |        if(wr_b) begin
           |            ram[addr_b] <= din_b;
           |            qout_b <= din_b;
           |        end
           |        else qout_b <= ram[addr_b];
           |    end
           |endmodule
           |""".stripMargin
    )
}

/**
 * A Read First version of SyncReadMem.
 *
 * @param nWords    Number of words in RAM
 * @param gen       Generator of data
 * @param clock     [implicit] Clock of the RAM
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of data
 * @note You may prefer to use the homonymous factory object
 * @example {{{
 *              val ram_rf = new SyncReadMemReadFirst
 *                               (256, UInt(32.W))(clock)
 *              // Or use the factory method
 *              // val ram_rf = SyncReadMemReadFirst
 *              //              (256, UInt(32.W))(clock)
 *              io.rdata := ram_rf.read(io.raddr)
 *              ram_rf.write(io.waddr, io.wdata, io.wen)
 * }}}
 */
class SyncReadMemReadFirst[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None)(implicit val clock: Clock) {
    private val sdpramrf = Module(new SdpRamRfInline(nWords, gen.getWidth, initFile))
    sdpramrf.io.clock := clock

    /**
     * The read operation
     * @param addr  Address of the read operation
     * @return      Result of the read operation
     */
    def read(addr: UInt): T = {
        sdpramrf.io.raddr := addr
        sdpramrf.io.qout.asTypeOf(gen)
    }

    /**
     * The write operation
     * @param addr  Address of the write operation
     * @param data  Data to be written
     * @param en    Enable of the write operation
     */
    def write(addr: UInt, data: T, en: Bool): Unit = {
        sdpramrf.io.waddr := addr
        sdpramrf.io.we    := en
        sdpramrf.io.din   := data.asUInt
    }
}

object SyncReadMemReadFirst {
    /**
     * Create a Synchronous Read Memory (Read-First) instance.
     * @param nWords    Number of words in RAM
     * @param gen       Generator of data
     * @param clock     [implicit] Clock of the SyncReadMemReadFirst instance
     * @param initFile  Hex data file for initializing RAM by internally using
     *                  verilog system call `$readmemh()`, default `None` for no
     *                  initializing.
     * @tparam T        Type of data
     * @return          The instance created.
     * @example {{{
     *              val ram_rf = SyncReadMemReadFirst
     *                           (256, UInt(32.W))(clock)
     *              io.rdata := ram_rf.read(io.raddr)
     *              ram_rf.write(io.waddr, io.wdata, io.wen)
     * }}}
     */
    def apply[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None)(implicit clock: Clock): SyncReadMemReadFirst[T] = {
        new SyncReadMemReadFirst(nWords, gen, initFile)
    }
}

/**
 * A Write First version of SyncReadMem.
 * @param nWords    Number of words in RAM
 * @param gen       Generator of data
 * @param clock     [implicit] Clock of the RAM
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of data
 * @note You may prefer to use the homonymous factory object
 * @example {{{
 *              val ram_wf = new SyncReadMemWriteFirst
 *                               (256, UInt(32.W))(clock)
 *              // Or use the factory method
 *              // val ram_wf = SyncReadMemWriteFirst
 *              //              (256, UInt(32.W))(clock)
 *              io.rdata := ram_wf.read(io.raddr)
 *              ram_wf.write(io.waddr, io.wdata, io.wen)
 * }}}
 */
class SyncReadMemWriteFirst[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None)(implicit val clock: Clock) {
    private val sdpramwf = Module(new SdpRamWfInline(nWords, gen.getWidth, initFile))
    sdpramwf.io.clock := clock

    /**
     * The read operation
     * @param addr  Address of the read operation
     * @return      Result of the read operation
     */
    def read(addr: UInt): T = {
        sdpramwf.io.raddr := addr
        sdpramwf.io.qout.asTypeOf(gen)
    }

    /**
     * The write operation
     * @param addr  Address of the write operation
     * @param data  Data to be written
     * @param en    Enable of the write operation
     */
    def write(addr: UInt, data: T, en: Bool): Unit = {
        sdpramwf.io.waddr := addr
        sdpramwf.io.we    := en
        sdpramwf.io.din   := data.asUInt
    }
}

object SyncReadMemWriteFirst {
    /**
     * Create a Synchronous Read Memory (Write-First) instance.
     * @param nWords    Number of words in RAM
     * @param gen       Generator of data
     * @param clock     [implicit] Clock of the SyncReadMemWriteFirst instance
     * @param initFile  Hex data file for initializing RAM by internally using
     *                  verilog system call `$readmemh()`, default `None` for no
     *                  initializing.
     * @tparam T        Type of data
     * @return          The instance created.
     * @example {{{
     *              val ram_wf = SyncReadMemWriteFirst
     *                           (256, UInt(32.W))(clock)
     *              io.rdata := ram_wf.read(io.raddr)
     *              ram_wf.write(io.waddr, io.wdata, io.wen)
     * }}}
     */
    def apply[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None)(implicit clock: Clock): SyncReadMemWriteFirst[T] = {
        new SyncReadMemWriteFirst(nWords, gen, initFile)
    }
}

/**
 * An Asynchronous Read Memory.
 * @param nWords    Number of words in RAM
 * @param gen       Generator of data
 * @param clock     [implicit] Clock of the RAM
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of data
 * @note You may prefer to use the homonymous factory object
 * @example {{{
 *              val ram_ra = new AsyncReadMem
 *                               (256, UInt(32.W))(clock)
 *              // Or use the factory method
 *              // val ram_ra = AsyncReadMem
 *              //              (256, UInt(32.W))(clock)
 *              io.rdata := ram_ra.read(io.raddr)
 *              ram_ra.write(io.waddr, io.wdata, io.wen)
 * }}}
 */
class AsyncReadMem[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None)(implicit val clock: Clock) {
    private val sdpramra = Module(new SdpRamRaInline(nWords, gen.getWidth, initFile))
    sdpramra.io.clock := clock

    /**
     * The read operation
     * @param addr  Address of the read operation
     * @return      Result of the read operation
     */
    def read(addr: UInt): T = {
        sdpramra.io.raddr := addr
        sdpramra.io.dout.asTypeOf(gen)
    }

    /**
     * The write operation
     * @param addr  Address of the write operation
     * @param data  Data to be written
     * @param en    Enable of the write operation
     */
    def write(addr: UInt, data: T, en: Bool): Unit = {
        sdpramra.io.waddr := addr
        sdpramra.io.we    := en
        sdpramra.io.din   := data.asUInt
    }
}

object AsyncReadMem {
    /**
     * Create an Asynchronous Read Memory instance.
     * @param nWords    Number of words in RAM
     * @param gen       Generator of data
     * @param clock     [implicit] Clock of the AsyncReadMem instance
     * @param initFile  Hex data file for initializing RAM by internally using
     *                  verilog system call `$readmemh()`, default `None` for no
     *                  initializing.
     * @tparam T        Type of data
     * @return          The instance created.
     * @example {{{
     *              val ram_ra = AsyncReadMem
     *                           (256, UInt(32.W))(clock)
     *              io.rdata := ram_ra.read(io.raddr)
     *              ram_ra.write(io.waddr, io.wdata, io.wen)
     * }}}
     */
    def apply[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None)(implicit clock: Clock): AsyncReadMem[T] = {
        new AsyncReadMem(nWords, gen, initFile)
    }
}

/**
 * A True Dual Port Synchronous Read Mem.
 * @param nWords    Number of words in RAM
 * @param gen       Generator of data
 * @param clock     [implicit] Clock of the RAM
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of data
 * @note
 *       - You may prefer to use the homonymous factory object.
 *       - Write First inner each port.
 *       - Read First between ports, but not guaranteed when inferred using
 *         blockRAM by FPGA synthesizer, it's the user's responsibilities to
 *         check the actual behavior or guarantee no simultaneously access to
 *         same address at both ports.
 * @example {{{
 *              val dpram = new DualPortSyncReadMem
 *                              (256, UInt(32.W))(clock)
 *              // Or use the factory method
 *              // val dpram = DualPortSyncReadMem
 *              //             (256, UInt(32.W))(clock)
 *              io.port_a.rdata := dpram.access_a(
 *                                   io.port_a.addr,
 *                                   io.port_a.wdata,
 *                                   io.port_a.wen )
 *              io.port_b.rdata := dpram.access_b(
 *                                   io.port_b.addr,
 *                                   io.port_b.wdata,
 *                                   io.port_b.wen )
 * }}}
 */
class DualPortSyncReadMem[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None)(implicit val clock: Clock) {
    private val dpram = Module(new DpRamInline(nWords, gen.getWidth, initFile))
    dpram.io.clock := clock

    /**
     * The access operation of port a
     * @param addr  Address of the operation (both read and write)
     * @param data  Data to be written
     * @param wen   Write enable
     * @return      Data read out
     */
    def access_a(addr: UInt, data: T, wen: Bool): T = {
        dpram.io.addr_a := addr
        dpram.io.wr_a   := wen
        dpram.io.din_a  := data.asUInt
        dpram.io.qout_a.asTypeOf(gen)
    }
    /**
     * The access operation of port b
     * @param addr  Address of the operation (both read and write)
     * @param data  Data to be written
     * @param wen   Write enable
     * @return      Data read out
     */
    def access_b(addr: UInt, data: T, wen: Bool): T = {
        dpram.io.addr_b := addr
        dpram.io.wr_b   := wen
        dpram.io.din_b  := data.asUInt
        dpram.io.qout_b.asTypeOf(gen)
    }
}

object DualPortSyncReadMem {
    /**
     * Create a True Dual Port Synchronous Read Memory instance.
     * @param nWords    Number of words in RAM
     * @param gen       Generator of data
     * @param clock     [implicit] Clock of the DualPortSyncReadMem instance
     * @param initFile  Hex data file for initializing RAM by internally using
     *                  verilog system call `$readmemh()`, default `None` for no
     *                  initializing.
     * @tparam T        Type of data
     * @return          The instance created.
     * @note
     *       - Write First inner each port.
     *       - Read First between ports, but not guaranteed when inferred using
     *         blockRAM by FPGA synthesizer, it's the user's responsibilities to
     *         check the actual behavior or guarantee no simultaneously access to
     *         same address at both ports.
     * @example {{{
     *              val dpram = DualPortSyncReadMem
     *                          (256, UInt(32.W))(clock)
     *              io.port_a.rdata := dpram.access_a(
     *                                   io.port_a.addr,
     *                                   io.port_a.wdata,
     *                                   io.port_a.wen )
     *              io.port_b.rdata := dpram.access_b(
     *                                   io.port_b.addr,
     *                                   io.port_b.wdata,
     *                                   io.port_b.wen )
     * }}}
     */
    def apply[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None)(implicit clock: Clock): DualPortSyncReadMem[T] = {
        new DualPortSyncReadMem(nWords, gen, initFile)
    }
}

/**
 * A True Dual Clock Synchronous Read Mem
 * @param nWords    Number of words in RAM
 * @param gen       Generator of data
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of data
 * @note
 *       - You may prefer to use the homonymous factory object.
 *       - Write First inner each port.
 * @example {{{
 *              val dcram = new DualClockSyncReadMem(256, UInt(32.W))
 *              // Or use the factory method
 *              // val dpram = DualPortSyncReadMem(256, UInt(32.W))
 *              io.port_a.rdata := dcram.access_a(
 *                                   io.port_a.clock,
 *                                   io.port_a.addr,
 *                                   io.port_a.wdata,
 *                                   io.port_a.wen  )
 *              io.port_b.rdata := dcram.access_b(
 *                                   io.port_b.clock,
 *                                   io.port_b.addr,
 *                                   io.port_b.wdata,
 *                                   io.port_b.wen  )
 * }}}
 */
class DualClockSyncReadMem[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None) {
    private val dcram = Module(new DcRamInline(nWords, gen.getWidth, initFile))

    /**
     * The access operation of port a
     * @param clock Clock of port a
     * @param addr  Address of the operation (both read and write)
     * @param data  Data to be written
     * @param wen   Write enable
     * @return      Data read out
     */
    def access_a(clock: Clock, addr: UInt, data: T, wen: Bool): T = {
        dcram.io.clock_a := clock
        dcram.io.addr_a  := addr
        dcram.io.din_a   := data.asUInt
        dcram.io.wr_a    := wen
        dcram.io.qout_a.asTypeOf(gen)
    }
    /**
     * The access operation of port b
     * @param clock Clock of port b
     * @param addr  Address of the operation (both read and write)
     * @param data  Data to be written
     * @param wen   Write enable
     * @return      Data read out
     */
    def access_b(clock: Clock, addr: UInt, data: T, wen: Bool): T = {
        dcram.io.clock_b := clock
        dcram.io.addr_b  := addr
        dcram.io.din_b   := data.asUInt
        dcram.io.wr_b    := wen
        dcram.io.qout_b.asTypeOf(gen)
    }
}

object DualClockSyncReadMem {
    /**
     * Create a True Dual Clock Synchronous Read Memory instance.
     * @param nWords    Number of words in RAM
     * @param gen       Generator of data
     * @param initFile  Hex data file for initializing RAM by internally using
     *                  verilog system call `$readmemh()`, default `None` for no
     *                  initializing.
     * @tparam T        Type of data
     * @return          The instance created.
     * @note
     *       - Write First inner each port.
     * @example {{{
     *              val dcram = DualClockSyncReadMem(256, UInt(32.W))(clock)
     *              io.port_a.rdata := dcram.access_a(
     *                                   io.port_a.clock,
     *                                   io.port_a.addr ,
     *                                   io.port_a.wdata,
     *                                   io.port_a.wen  )
     *              io.port_b.rdata := dcram.access_b(
     *                                   io.port_b.clock,
     *                                   io.port_b.addr ,
     *                                   io.port_b.wdata,
     *                                   io.port_b.wen  )
     * }}}
     */
    def apply[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None): DualClockSyncReadMem[T] = {
        new DualClockSyncReadMem(nWords, gen, initFile)
    }
}

/**
 * Represent a hardware module of Single Port RAM, with the behavior of reading
 * when writing is Undefined.
 * @param nWords    Number of Words (elements) in RAM
 * @param gen       Generator of Data
 * @tparam T        Type of Data
 * @note
 *  - Normally, you should use chisel3.SyncReadMem directly in your
 *    module, instead of using this.
 *  - Use chisel3.util.experimental.loadMemoryFromFileInline() if initializing
 *    is needed.
 */
class SpRam[T <: Data](nWords: Long, gen: T) extends Module {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new RamIO.RW(nWords, gen))
    // It's recommended using chisel3.SyncReadMem directly in code,
    // No need to wrap a module like this.
    val mem = SyncReadMem(nWords, gen, SyncReadMem.Undefined)
    io.dout := mem.read(io.addr)
    when(io.we) {
        mem.write(io.addr, io.din)
    }
}

/**
 * Represent a hardware module of Single Port RAM, with the behavior of reading
 * when writing is Read First.
 * @param nWords    Number of Words (elements) in RAM
 * @param gen       Generator of Data
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of Data
 * @note Normally, you should use SyncReadMemReadFirst directly in your
 *       module, instead of using this.
 */
class SpRamRf[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None) extends Module {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new RamIO.RW(nWords, gen))
    val spramrf = SyncReadMemReadFirst(nWords, gen, initFile)(clock)
    io.dout := spramrf.read(io.addr)
    spramrf.write(io.addr, io.din, io.we)
}

/**
 * Represent a hardware module of Single Port RAM, with the behavior of reading
 * when writing is Write First.
 * @param nWords    Number of Words (elements) in RAM
 * @param gen       Generator of Data
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of Data
 * @note Normally, you should use SyncReadMemWriteFirst directly in your
 *       module, instead of using this.
 */
class SpRamWf[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None) extends Module {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new RamIO.RW(nWords, gen))
    val spramwf = SyncReadMemWriteFirst(nWords, gen, initFile)(clock)
    io.dout := spramwf.read(io.addr)
    spramwf.write(io.addr, io.din, io.we)
}

/**
 * Represent a hardware module of Single Port Asynchronous Read RAM.
 * @param nWords    Number of Words (elements) in RAM
 * @param gen       Generator of Data
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of Data
 * @note Normally, you should use AsyncReadMem directly in your module,
 *       instead of using this.
 */
class SpRamRa[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None) extends Module {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new RamIO.RW(nWords, gen))
    val spramra = AsyncReadMem(nWords, gen, initFile)(clock)
    io.dout := spramra.read(io.addr)
    spramra.write(io.addr, io.din, io.we)
}

/**
 * Represent a hardware module of Simple Dual Port Synchronous Read RAM,
 * with the behavior of reading when writing is Undefined.
 * @param nWords    Number of Words (elements) in RAM
 * @param gen       Generator of Data
 * @tparam T        Type of Data
 * @note
 *  - Normally, you should use chisel3.SyncReadMem directly in your
 *    module, instead of using this.
 *  - Use chisel3.util.experimental.loadMemoryFromFileInline() if initializing
 *    is needed.
 */
class SdpRam[T <: Data](nWords: Long, gen: T) extends Module {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new Bundle {
        val r = new RamIO.R(nWords, gen)
        val w = new RamIO.W(nWords, gen)
    })
    val sdpram = SyncReadMem(nWords, gen)
    io.r.dout := sdpram.read(io.r.addr)
    when(io.w.en) {
        sdpram.write(io.w.addr, io.w.din)
    }
}

/**
 * Represent a hardware module of Simple Dual Port Synchronous Read RAM,
 * with the behavior of reading when writing is Read First.
 * @param nWords    Number of Words (elements) in RAM
 * @param gen       Generator of Data
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of Data
 * @note Normally, you should use SyncReadMemReadFirst directly in your module,
 *       instead of using this.
 */
class SdpRamRf[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None) extends Module {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new Bundle {
        val w = new RamIO.W(nWords, gen)
        val r = new RamIO.R(nWords, gen)
    })
    val sdpramrf = SyncReadMemReadFirst(nWords, gen, initFile)(clock)
    io.r.dout := sdpramrf.read(io.r.addr)
    sdpramrf.write(io.w.addr, io.w.din, io.w.en)
}

/**
 * Represent a hardware module of Simple Dual Port Synchronous Read RAM,
 * with the behavior of reading when writing is Write First.
 * @param nWords    Number of Words (elements) in RAM
 * @param gen       Generator of Data
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of Data
 * @note Normally, you should use SyncReadMemWriteFirst directly in your module,
 *       instead of using this.
 */
class SdpRamWf[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None) extends Module {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new Bundle {
        val w = new RamIO.W(nWords, gen)
        val r = new RamIO.R(nWords, gen)
    })
    val sdpramwf = SyncReadMemWriteFirst(nWords, gen, initFile)(clock)
    io.r.dout := sdpramwf.read(io.r.addr)
    sdpramwf.write(io.w.addr, io.w.din, io.w.en)
}

/**
 * Represent a hardware module of Simple Dual Port Asynchronous Read RAM.
 * @param nWords    Number of Words (elements) in RAM
 * @param gen       Generator of Data
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of Data
 * @note Normally, you should use AsyncReadMem directly in your module,
 *       instead of using this.
 */
class SdpRamRa[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None) extends Module {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new Bundle {
        val w = new RamIO.W(nWords, gen)
        val r = new RamIO.R(nWords, gen)
    })
    val sdpramra = AsyncReadMem(nWords, gen, initFile)(clock)
    io.r.dout := sdpramra.read(io.r.addr)
    sdpramra.write(io.w.addr, io.w.din, io.w.en)
}

/**
 * Represent a hardware module of True Dual Port Synchronous Read RAM.
 * @param nWords    Number of Words (elements) in RAM
 * @param gen       Generator of Data
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of Data
 * @note
 *       - Normally, you should use DualPortSyncReadMem directly in your module,
 *         instead of using this.
 *       - Write First inner each port.
 *       - Read First between ports, but not guaranteed when inferred using
 *         blockRAM by FPGA synthesizer, it's the user's responsibilities to
 *         check the actual behavior or guarantee no simultaneously access to
 *         same address at both ports.
 */
class DpRam[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None) extends Module {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new Bundle {
        val a = new RamIO.RW(nWords, gen)
        val b = new RamIO.RW(nWords, gen)
    })
    val dpram = DualPortSyncReadMem(nWords, gen, initFile)(clock)
    io.a.dout := dpram.access_a(io.a.addr, io.a.din, io.a.we)
    io.b.dout := dpram.access_b(io.b.addr, io.b.din, io.b.we)
}

/**
 * Represent a hardware module of Simple Dual Clock Synchronous Read RAM.
 * @param nWords    Number of Words in RAM
 * @param gen       Generator of Data
 * @tparam T        Type of Data
 * @note
 *  - Normally, you should use chisel3.SyncReadMem directly in your module,
 *    instead of using this.
 *  - Use chisel3.util.experimental.loadMemoryFromFileInline() if initializing
 *    is needed.
 */
class SdcRam[T <: Data](nWords: Long, gen: T) extends RawModule {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new Bundle {
        val a = new RamIO.CR(nWords, gen)
        val b = new RamIO.CW(nWords, gen)
    })
    val sdcram = SyncReadMem(nWords, gen)
    io.a.dout := sdcram.read(io.a.addr, io.a.clock)
    when(io.b.en) {
        sdcram.write(io.b.addr, io.b.din, io.b.clock)
    }
}

/**
 * Represent a hardware module of True Dual Clock Synchronous Read RAM.
 * @param nWords    Number of Words (elements) in RAM
 * @param gen       Generator of Data
 * @param initFile  Hex data file for initializing RAM by internally using
 *                  verilog system call `$readmemh()`, default `None` for no
 *                  initializing.
 * @tparam T        Type of Data
 * @note
 *  - Normally, you should use DualClockSyncReadMem directly in your
 *    module, instead of using this.
 *  - Write First inner each port.
 */
class DcRam[T <: Data](nWords: Long, gen: T, initFile: Option[String] = None) extends RawModule {
    require(nWords > 0)
    override def desiredName = s"${super.desiredName}_${nWords}_x_${gen.typeName}"

    val io = IO(new Bundle {
        val a = new RamIO.CRW(nWords, gen)
        val b = new RamIO.CRW(nWords, gen)
    })
    val dcram = DualClockSyncReadMem(nWords, gen, initFile)
    io.a.dout := dcram.access_a(io.a.clock, io.a.addr, io.a.din, io.a.we)
    io.b.dout := dcram.access_b(io.b.clock, io.b.addr, io.b.din, io.b.we)
}

package examples {
    /**
     * A Single Port RAM example for emitting verilog directly,
     * with the behavior of reading when writing is Undefined.
     */
    class spram_example extends Module {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new RamIO.RW(nWords, dType))
        val ram = Module(new SpRam(nWords, dType))
        io <> ram.io
    }

    /**
     * A Single Port RAM example for emitting verilog directly,
     * with the behavior of reading when writing is Undefined,
     * with initializing.
     */
    class spram_with_init_example extends Module {
        val nWords = 256
        val width = 8
        val dType = UInt(width.W)
        val io = IO(new RamIO.RW(nWords, dType))
        val ram = Module(new SpRam(nWords, dType))
        io <> ram.io

        val fn: String = s"${desiredName}_meminit_sine${nWords}x${width}bit.dat"
        val fnWithPath: String = s"${ProjectInfo.BuildInfo.targetVerilogDir}/${fn}"
        MemoryInitFiles.Write(fnWithPath, MemoryInitFiles.SineWava(nWords, width))
        chisel3.util.experimental.loadMemoryFromFileInline(ram.mem, fn)
    }

    /**
     * A Single Port RAM example for emitting verilog directly,
     * with the behavior of reading when writing is Read First.
     */
    class spramrf_example extends Module {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new RamIO.RW(nWords, dType))
        val ram = Module(new SpRamRf(nWords, dType))
        io <> ram.io
    }

    /**
     * A Single Port RAM example for emitting verilog directly,
     * with the behavior of reading when writing is Read First,
     * with initializing.
     */
    class spramrf_with_init_example extends Module {
        val nWords = 256
        val width = 8
        val dType = UInt(width.W)

        val fn = s"${desiredName}_meminit_sine${nWords}x${width}bit.dat"
        val fnWithPath = s"${ProjectInfo.BuildInfo.targetVerilogDir}/${fn}"
        MemoryInitFiles.Write(fnWithPath, MemoryInitFiles.CosineWave(nWords, width, isSigned = false))

        val io = IO(new RamIO.RW(nWords, dType))
        val ram = Module(new SpRamRf(nWords, dType, Some(fn)))
        io <> ram.io
    }

    /**
     * A Single Port RAM example for emitting verilog directly,
     * with the behavior of reading when writing is Write First.
     */
    class spramwf_example extends Module {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new RamIO.RW(nWords, dType))
        val ram = Module(new SpRamWf(nWords, dType))
        io <> ram.io
    }

    /**
     * A Single Port Asynchronous Read RAM example for emitting verilog
     * directly.
     */
    class spramra_example extends Module {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new RamIO.RW(nWords, dType))
        val ram = Module(new SpRamRa(nWords, dType))
        io <> ram.io
    }

    /**
     * A Simple Dual Port RAM example for emitting verilog directly,
     * with the behavior of reading when writing is Undefined.
     */
    class sdpram_example extends Module {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new Bundle {
            val r = new RamIO.R(nWords, dType)
            val w = new RamIO.W(nWords, dType)
        })
        val ram = Module(new SdpRam(nWords, dType))
        io <> ram.io
    }

    /**
     * A Simple Dual Port RAM example for emitting verilog directly,
     * with the behavior of reading when writing is Read First.
     */
    class sdpramrf_example extends Module {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new Bundle {
            val r = new RamIO.R(nWords, dType)
            val w = new RamIO.W(nWords, dType)
        })
        val ram = Module(new SdpRamRf(nWords, dType))
        io <> ram.io
    }

    /**
     * A Simple Dual Port RAM example for emitting verilog directly,
     * with the behavior of reading when writing is Write First.
     */
    class sdpramwf_example extends Module {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new Bundle {
            val r = new RamIO.R(nWords, dType)
            val w = new RamIO.W(nWords, dType)
        })
        val ram = Module(new SdpRamWf(nWords, dType))
        io <> ram.io
    }

    /**
     * A Simple Dual Port Asynchronous Read RAM example for emitting verilog
     * directly.
     */
    class sdpramra_example extends Module {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new Bundle {
            val r = new RamIO.R(nWords, dType)
            val w = new RamIO.W(nWords, dType)
        })
        val ram = Module(new SdpRamRa(nWords, dType))
        io <> ram.io
    }

    /**
     * A True Dual Port Synchronous Read RAM example for emitting verilog
     * directly.
     */
    class dpram_example extends Module {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new Bundle {
            val a = new RamIO.RW(nWords, dType)
            val b = new RamIO.RW(nWords, dType)
        })
        val ram = Module(new DpRam(nWords, dType))
        io <> ram.io
    }

    /**
     * A Simple Dual Clock Synchronous Read RAM example for emitting verilog
     * directly.
     */
    class sdcram_example extends RawModule {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new Bundle {
            val a = new RamIO.CR(nWords, dType)
            val b = new RamIO.CW(nWords, dType)
        })
        val ram = Module(new SdcRam(nWords, dType))
        io <> ram.io
    }

    /**
     * A True Dual Clock Synchronous Read RAM example for emitting verilog
     * directly.
     */
    class dcram_example extends RawModule {
        val nWords = 256
        val dType = UInt(8.W)
        val io = IO(new Bundle {
            val a = new RamIO.CRW(nWords, dType)
            val b = new RamIO.CRW(nWords, dType)
        })
        val ram = Module(new DcRam(nWords, dType))
        io <> ram.io
    }
}
