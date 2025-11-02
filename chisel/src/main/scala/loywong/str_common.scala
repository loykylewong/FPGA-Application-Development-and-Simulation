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
import chisel3.experimental.requireIsChiselType
// import chisel3.experimental.prefix
import loywong.util._

/**
 * In down-stream port of StrDateWidthConverter, StrKeepRemover and some other
 * modules, use `id` associated with which byte as output in a beat?
 *  - LowestByte: Use the `id` input with the lowest output byte
 *  - HighestByte: Use the `id` input with the highest output byte
 */
object StrIdAssociation extends Enumeration {
    val LowestByte, HighestByte = Value
}
/**
 * In down-stream port of StrDateWidthConverter, StrKeepRemover and some other
 * modules, use `dest` associated with which byte as output in a beat?
 *  - LowestByte: Use the `dest` input with the lowest output byte
 *  - HighestByte: Use the `dest` input with the highest output byte
 */
object StrDestAssociation extends Enumeration {
    val LowestByte, HighestByte = Value
}

/**
 * In down-stream port of StrDateWidthConverter, StrKeepRemover and some other
 * modules, use `user` associated with which byte as output in a beat?
 *  - LowestByte: Use the `user` input with the lowest output byte
 *  - HighestByte: Use the `user` input with the highest output byte
 *  - SpreadInByte: Split `user` equally and associate each `user` bit slices
 *                  to each data bytes, require width of `user` in bits is
 *                  multiple of data width in bytes
 */
object StrUserAssociation extends Enumeration {
    val LowestByte, HighestByte, SpreadInBytes = Value
}

// Inherit this trait for stream bits (IrrevocableIO.bits) is recommended
trait StrBits extends Bundle

// Inherit this trait if data exist in stream bits
trait StrHasData extends StrBits {
    def data: Bits  // CAUTION: Use `lazy val` when overriding
}

// Inherit this trait if strb (and data) signal exist in stream bits
trait StrHasStrb extends StrHasData {
    def strb: UInt  // CAUTION: Use `lazy val` when overriding
    require(data.getWidth == strb.getWidth * 8,
        s"In Str Bits, data width must be 8x strb width, but got ${data.getWidth} and ${strb.getWidth}.")
}

// Inherit this trait if keep (and data) signal exist in stream bits
trait StrHasKeep extends StrHasData {
    def keep: UInt  // CAUTION: Use `lazy val` when overriding
    require(data.getWidth == keep.getWidth * 8,
        s"In Str Bits, data width must be 8x keep width, but got ${data.getWidth} and ${keep.getWidth}.")
}

// Inherit this trait if last signal exist in stream bits
trait StrHasLast extends StrBits {
    def last: Bool
}

// Inherit this trait if id signal exist in stream bits
trait StrHasId extends StrBits {
    val idAssociation: StrIdAssociation.Value = StrIdAssociation.LowestByte
    def id: UInt
}

// Inherit this trait if dest signal exist in stream bits
trait StrHasDest extends StrBits {
    val destAssociation: StrDestAssociation.Value = StrDestAssociation.LowestByte
    def dest: UInt
}

// Inherit this trait if user signal exist in stream bits
trait StrHasUser extends StrBits {
    val userAssociation: StrUserAssociation.Value = StrUserAssociation.SpreadInBytes
    def user: Bits
}

/**
 * Represents a hardware stream forward reg-slice with configurable data type.
 *
 * Can be used to break up combination data path for better timing.
 *
 * @note Notes:
 *       1. `ready` path can not be broken by this, use `str_birs` instead.
 *
 * @tparam T    Data type of payload (IrrevocableIO.bits)
 * @param gen   Data type generator for payload (e.g. UInt(8.W))
 * @param init  Initialization function for reset value of payload
 */
class StrFrs[+T <: Data]
(gen: T = Bool(), init: Option[() => T] = None) extends Module {
    requireIsChiselType(gen)
    override def desiredName = s"${super.desiredName}_${gen.typeName}"

    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(gen))
        val ds = Irrevocable(gen)
    })

    io.us.ready := io.ds.ready || !io.ds.valid

    val ds_valid = RegInit(false.B)
    ds_valid := MuxCase(ds_valid, Seq(
        io.us.fire  -> true.B,
        io.ds.ready -> false.B
    ))
    io.ds.valid := ds_valid

    val ds_bits = init match {
        case Some(f) => RegInit(f())
        case None    => RegInit(0.U.asTypeOf(gen))
    }
    when(io.us.fire) { ds_bits := io.us.bits }
    io.ds.bits := ds_bits
}

/**
 * Represents a hardware stream bi-direction reg-slice with configurable data
 * type.
 *
 * Can be used to break up combination data path and `ready` for better timing.
 *
 * @tparam T    Data type of payload (IrrevocableIO.bits)
 * @param gen   Data type generator for payload (e.g. UInt(8.W))
 * @param init  Initialization function for reset value of payload
 */
class StrBirs[T <: Data]
(gen: T = Bool(), init: Option[() => T] = None) extends Module {
    requireIsChiselType(gen)
    override def desiredName = s"${super.desiredName}_${gen.typeName}"

    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(gen))
        val ds = Irrevocable(gen)
    })

    val ush = io.us.fire
    val dsh = io.ds.fire

    val buffer = init match {
        case Some(f) => RegInit(VecInit(f(), f()))
        case None    => RegInit(VecInit(Seq.fill(2)(0.U.asTypeOf(gen))))
    }

    val wp = RegInit(0.U(1.W))
    val rp = RegInit(0.U(1.W))
    val dc = RegInit(0.U(2.W))

    io.us.ready := dc < 2.U(2.W)
    io.ds.valid := dc > 0.U(2.W)

    when(ush) { wp := ~wp }
    when(dsh) { rp := ~rp }

    switch( ush ## dsh ) {
        is("b10".U) { dc := dc + 1.U(2.W) }
        is("b01".U) { dc := dc - 1.U(2.W) }
    }

    when(ush) { buffer(wp) := io.us.bits }
    io.ds.bits := buffer(rp)
}

/**
 * Represents a hardware multi-upstream multi-downstream handshake logic module.
 *
 * Use this for synchronizing multiple upstreams and multiple downstreams.
 *
 * @note Notes:
 *       - This is a pure combination logic module.
 *       - Deadlock occurs if d.s. ready depends on u.s. valid.
 *       - Deadlock occurs if series 2 str_hscombs.
 *       - Follow a str_fifo or a reg-slice (str_firs or str_birs) can break
 *       up deadlock.
 * @param nUS   Number of upstream port(s)
 * @param nDS   Number of downstream port(s)
 */
class StrHsCombModule (nUS: Int = 2, nDS: Int = 2) extends Module {

    require(nUS > 0 && nDS > 0,
        s"In ${desiredName}, nUS and nDS must be > 0, got ${nUS} and ${nDS}.")

    override def desiredName = s"${super.desiredName}_${nUS}to${nDS}"

    val io = IO(new Bundle {
        val us_valid = Input(UInt(nUS.W))
        val us_ready = Output(UInt(nUS.W))
        val ds_valid = Output(UInt(nDS.W))
        val ds_ready = Input(UInt(nDS.W))
    })

    val ds_valid = Wire(Vec(nDS, Bool()))
    val dre = Wire(Vec(nDS, UInt(nDS.W)))
    for(i:Int <- 0 until nDS) {
        dre(i) := io.ds_ready | (1.U(nDS.W) << i).asUInt
        ds_valid(i) := (io.us_valid ## dre(i)).andR
    }
    io.ds_valid := ds_valid.asUInt

    val us_ready = Wire(Vec(nUS, Bool()))
    val uve = Wire(Vec(nUS, UInt(nUS.W)))
    for(i:Int <- 0 until nUS) {
        uve(i) := io.us_valid | (1.U(nUS.W) << i).asUInt
        us_ready(i) := (io.ds_ready ## uve(i)).andR
    }
    io.us_ready := us_ready.asUInt
}

/**
 * A utility class for ease of connecting StrHsCombModule.
 * @param nUS   Number of upstream port(s)
 * @param nDS   Number of downstream port(s)
 * @note Notes:
 *       - The StrHsCombModule is a pure combination logic module.
 *       - Deadlock may occur if d.s. ready depends on u.s. valid.
 *       - Deadlock may occur if series 2 StrHsCombs.
 *       - Follow a str_fifo or a reg-slice (str_firs or str_birs) can break
 *       up deadlock.
 */
class StrHsComb (nUS: Int, nDS: Int) {
    val cb = Module(new StrHsCombModule(nUS, nDS))

    /**
     * Connect valid(s) of up-stream(s)
     *
     * @param valids Valid(s) of up-stream(s)
     * @example {{{
     *              hscmb.usValids(us0.io.ds.valid, us1.io.ds.valid, ...)
     *              // OR
     *              hscmb.usValids(usValidsSeq: _*)
     * }}}
     *
     */
    def usValids(valids: Bool*): Unit = {
        require(valids.length == nUS,
            s"In StrHsComb.usValids(), length of arg valids and nUS in StrHsComb not match.")
        cb.io.us_valid :=
                valids.foldLeft(0.U(nUS.W))((acc, v) => {
                    (acc << 1) | v
                })
    }

    /**
     * Connect ready(s) of up-stream(s)
     * @param readys    Ready(s) of up-stream(s)
     * @example {{{
     *              hscmb.usReadys(us0.io.ds.ready, us1.io.ds.ready, ...)
     *              // OR
     *              hscmb.usReadys(usReadysSeq: _*)
     * }}}
     */
    def usReadys(readys: Bool*): Unit = {
        require(readys.length == nUS,
            s"In StrHsComb.usReadys(), length of arg readys and nUS in StrHsComb not match.")
        readys.zipWithIndex.foreach{ case(r, i) => {
            r := cb.io.us_ready(nUS - 1 - i)
        }}
    }

    /**
     * Connect valid(s) of down-stream(s)
     * @param valids    Valid(s) of down-stream(s)
     * @example {{{
     *              hscmb.dsValids(ds0.io.us.valid, ds1.io.us.valid, ...)
     *              // OR
     *              hscmb.dsValids(dsValidsSeq: _*)
     * }}}
     *
     */
    def dsValids(valids: Bool*): Unit = {
        require(valids.length == nDS,
            s"In StrHsComb.dsValids(), length of arg valids and nDS in StrHsComb not match.")
        valids.zipWithIndex.foreach { case(v, i) => {
            v := cb.io.ds_valid(nDS - 1 - i)
        }}
    }

    /**
     * Connect ready(s) of down-stream(s)
     * @param readys    Ready(s) of down-stream(s)
     * @example {{{
     *              hscmb.dsReadys(ds0.io.us.ready, ds1.io.us.ready, ...)
     *              // OR
     *              hscmb.dsReadys(dsReadysSeq: _*)
     * }}}
     */
    def dsReadys(readys: Bool*): Unit = {
        require(readys.length == nDS,
            s"In StrHsComb.dsReadys(), length of arg readys and nDS in StrHsComb not match.")
        cb.io.ds_ready :=
                readys.foldLeft(0.U(nDS.W))((acc, r) => {
                    (acc << 1 | r)
                })
    }

}

object StrHsComb {
    /**
     * Create an instance of StrHsComb, in which a StrHsCombModule is
     * instantiated.
     *
     * @param nUS Number of upstream port(s)
     * @param nDS Number of downstream port(s)
     * @note Notes:
     *       - The StrHsCombModule is a pure combination logic module.
     *       - Deadlock occurs if d.s. ready depends on u.s. valid.
     *       - Deadlock occurs if series 2 StrHsCombs.
     *       - Follow a str_fifo or a reg-slice (str_firs or str_birs) can break
     *         up deadlock.
     */
    def apply(nUS: Int, nDS: Int): StrHsComb = {
        new StrHsComb(nUS, nDS)
    }
}

/**
 * Represent a hardware module for detecting gapping between packages.
 */
class StrPkgGapping extends Module {
    val io = IO(new Bundle {
        val valid = Input(Bool())
        val ready = Input(Bool())
        val last = Input(Bool())
        val gapping = Output(Bool())
    })
    val shake = WireDefault(io.valid && io.ready)
    val gapped = RegEnable(io.last, true.B, shake)
    io.gapping := shake && io.last || gapped && (!shake)
}

object StrPkgGapping {
    /**
     * Create an instance of StrPkgGapping, and connect IOs.
     * @param valid valid signal of stream to be detected.
     * @param ready ready signal of stream to be detected.
     * @param last  last signal of stream to be detected.
     * @return      output gapping signal.
     */
    def apply[T <: IrrevocableIO[StrHasLast]](str: T): Bool = {
        val strPkgGapping = Module(new StrPkgGapping)
        strPkgGapping.io.valid := str.valid
        strPkgGapping.io.ready := str.ready
        strPkgGapping.io.last := str.bits.last
        strPkgGapping.io.gapping
    }
}

/**
 * Represents a hardware stream pipeline module.
 *
 * Use this for matching path latency with others.
 *
 * @note Notes:
 *       1. If the latencies can not to be or can hardly be predetermined,
 *          str_fifo and str_hscomb are recommended for matching latencies.
 * @param nStage    Number of pipeline stages
 * @param gen       Data type generator for payload
 * @param init      Initialization function for reset value of payload
 * @tparam T        Data type of payload
 */
class StrPipeStages[+T <: Data]
(nStage: Int = 4, gen: T = Bool(), init: Option[()=>T] = None) extends Module {

    requireIsChiselType(gen)
    require(nStage > 0, s"In ${desiredName}, arg nStage must > 0, got ${nStage}.")

    override def desiredName = s"${super.desiredName}_${gen.typeName}"

    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(gen))
        val ds = Irrevocable(gen)
    })

    val stages = Seq.fill(nStage)(Module(new StrFrs(gen, init)))

    stages.zipWithIndex.foreach{ case(stg, i) => {
        if(i == 0)          stg.io.us <> io.us
        else                stg.io.us <> stages(i-1).io.ds
        if(i == nStage - 1) io.ds <> stg.io.ds
    }}
}

class StrSinkToFifoWriter[+T <: Data](gen:T = UInt(8.W)) extends Module {
    requireIsChiselType(gen)
    override def desiredName = s"${super.desiredName}_${gen.typeName}"

    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(gen))
        val writer = FifoIO.Writer(gen)
    })
    io.us.ready := !io.writer.full
    io.writer.write := io.us.fire
    io.writer.data := io.us.bits
}

object StrSinkToFifoWriter {
    def apply[T <: Data](fifoWriter: FifoIO.WriterIO[T]): IrrevocableIO[T] = {
        val sink2writer = Module(new StrSinkToFifoWriter(chiselTypeOf(fifoWriter.data)))
        sink2writer.io.writer <> fifoWriter
        sink2writer.io.us
    }
}

class StrSourceFromFifoReader[+T <: Data](gen:T = UInt(8.W)) extends Module {
    requireIsChiselType(gen)
    override def desiredName = s"${super.desiredName}_${gen.typeName}"

    val io = IO(new Bundle {
        val reader = FifoIO.Reader(gen)
        val ds = Irrevocable(gen)
    })
    io.reader.read := !io.reader.empty && (!io.ds.valid || io.ds.ready)
    io.ds.bits := io.reader.data
    val ds_valid = RegInit(false.B)
    ds_valid := MuxCase(ds_valid, Seq(
        io.reader.read -> true.B,
        io.ds.ready    -> false.B
    ))
    io.ds.valid := ds_valid
}

object StrSourceFromFifoReader {
    def apply[T <: Data](fifoReader: FifoIO.ReaderIO[T]): IrrevocableIO[T] = {
        val reader2source = Module(new StrSourceFromFifoReader(chiselTypeOf(fifoReader.data)))
        reader2source.io.reader <> fifoReader
        reader2source.io.ds
    }
}

/**
 * Represents a hardware stream FIFO with configurable depth and data type.
 *
 * This module implements a synchronous stream FIFO using BRAM(s).
 *
 * @note Notes:
 *       1. Using chisel3.util.Queue directly is recommended, since this class
 *          is using chisel3.util.Queue internally.
 *       2. nDepth must be a power of 2 for optimal BRAM utilization.
 * @example {{{
 *   val fifo = Module(new FIFO(nDepth=16, UInt(8.W)))
 * }}}
 * @tparam T Data type of FIFO elements
 * @param nDepth    Number of entries in the FIFO
 * @param gen       Data type generator (e.g. `UInt(8.W)`) for elements
 * @param hasFlush  Generate io.flush or not
 */
class StrFifo[T <: Data]
(gen:T, nDepth:Int, hasFlush:Boolean = false) extends Module {

    requireIsChiselType(gen, s"In ${desiredName}, gen must be a chisel type.")
    require(nDepth > 0, s"In ${desiredName}, arg nDepth must be > 0, got ${nDepth}.")

    override def desiredName = s"${super.desiredName}_${gen.typeName}"

    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(gen))
        val ds = Irrevocable(gen)
        val flush = if(hasFlush) Some(Input(Bool())) else None
    })

    // use chisel3.util.Queue!
    val fifo = Queue.irrevocable(
          enq            = io.us
        , entries        = nDepth
        , pipe           = true
        , flow           = false
        , useSyncReadMem = true
        , flush          = io.flush
    )

    io.ds <> fifo
}

/**
 * Represent a hardware Dual clock FIFO module with stream interface
 * @param gen           Generator of data
 * @param addrWidth     Address width of internal RAM, actual FIFO depth = 2^addrWidth-1
 * @param usHasDataCnt  True if `dataCnt` of upstream port is needed
 * @param dsHasDataCnt  True if `dataCnt` of downstream port is needed
 * @param usHasWrRdCnt  True if `writeCnt` and `readCnt` of upstream port are needed
 * @param dsHasWrRdCnt  True if `writeCnt` and `readCnt` of downstream port are needed
 * @tparam T            Type of data
 */
class StrDcFifo[T <: Data](gen: T,
                            addrWidth: Int,
                            usHasDataCnt: Boolean = false,
                            dsHasDataCnt: Boolean = false,
                            usHasWrRdCnt: Boolean = false,
                            dsHasWrRdCnt: Boolean = false
                           ) extends RawModule {

    require(addrWidth >= 1 && addrWidth < 64, s"In ${desiredName}, addrWidth must be in [1, 63]")
    require(!(!usHasDataCnt && usHasWrRdCnt), s"In ${desiredName}, when wrHasDataCnt == false, wrHasWrRdCnt is not allowed to be true!")
    require(!(!dsHasDataCnt && dsHasWrRdCnt), s"In ${desiredName}, when rdHasDataCnt == false, rdHasWrRdCnt is not allowed to be true!")
    requireIsChiselType(gen, s"In ${desiredName}, gen must be a chisel type.")

    override def desiredName = s"${super.desiredName}_${gen.typeName}"

    val io = IO(new Bundle {
        val usClock = Input(Clock())
        val dsClock = Input(Clock())
        val usReset = Input(Bool())
        val dsReset = Input(Bool())
        val us = Flipped(Irrevocable(gen))
        val ds = Irrevocable(gen)
        val usCnt =
            if(usHasDataCnt)
                Some(FifoIO.CntProvider(addrWidth, usHasWrRdCnt))
            else
                None
        val dsCnt =
            if(dsHasDataCnt)
                Some(FifoIO.CntProvider(addrWidth, dsHasWrRdCnt))
            else
                None
    })

    val dcfifo = Module(new DcFifo(gen, addrWidth,
        usHasDataCnt, dsHasDataCnt, usHasWrRdCnt, dsHasWrRdCnt))
    dcfifo.io.wrClock := io.usClock
    dcfifo.io.rdClock := io.dsClock
    dcfifo.io.wrReset := io.usReset
    dcfifo.io.rdReset := io.dsReset
    if(usHasDataCnt)
        dcfifo.io.wcnt.get <> io.usCnt.get
    if(dsHasDataCnt)
        dcfifo.io.rcnt.get <> io.dsCnt.get

    withClockAndReset(io.usClock, io.usReset) {
        val us = StrSinkToFifoWriter(dcfifo.io.w)
        io.us <> us
    }

    withClockAndReset(io.dsClock, io.dsReset) {
        val ds = StrSourceFromFifoReader(dcfifo.io.r)
        io.ds <> ds
    }
}

/**
 * Represent a hardware module for converting stream data width
 *
 * @param genUs             generator of up-stream bits of IrrevocableIO
 * @param genDs             generator of down-stream bits of IrrevocableIO
 * @tparam U                type of up-stream bits of IrrevocableIO
 * @tparam D                type of down-stream bits of IrrevocableIO
 * @note    It's the user's responsibility to make sure that `id` changing,
 *          `dest` changing and `last` assert only occurs on boundary of
 *          `LCM(us.dataBytes, ds.dataBytes)` bytes, if `userAssociation !=
 *          StrUserAssociation.SpreadInBytes`, so as `user`. Otherwise, `id`,
 *          `dest` and/or `user` may mess up, `last` may lost.
 */
class StrDataWidthConverter[U <: StrHasData, D <: StrHasData](
       genUs: U, genDs: D) extends Module {

    requireIsChiselType(genUs)
    requireIsChiselType(genDs)

    // ---- check data width ----
    require(genUs.dataWidth % 8 == 0,
        s"In ${desiredName}, width of io.us.bits.data must be multiple of 8, got ${genUs.dataWidth}")
    require(genDs.dataWidth % 8 == 0,
        s"In ${desiredName}, width of io.ds.bits.data must be multiple of 8, got ${genDs.dataWidth}")

    // ---- check strb width ----
    require(!(genUs.hasStrb ^ genDs.hasStrb),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasStrb) "HAS" else "HAS NO"} strb signal, but " +
                s"io.ds.bits ${if (genDs.hasStrb) "HAS" else "HAS NO"} strb signal.")
    require(!genUs.hasStrb || genUs.strbWidth == genUs.dataBytesCeil,
        s"In ${desiredName}, width of io.us.strb (got ${genUs.strbWidth}) must be 1/8 width of io.us.data (got ${genUs.dataWidth}).")
    require(!genDs.hasStrb || genDs.strbWidth == genDs.dataBytesCeil,
        s"In ${desiredName}, width of io.ds.strb (got ${genDs.strbWidth}) must be 1/8 width of io.ds.data (got ${genDs.dataWidth}).")

    // ---- check keep width ----
    require(!(genUs.hasKeep ^ genDs.hasKeep),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasKeep) "HAS" else "HAS NO"} keep signal, but " +
                s"io.ds.bits ${if (genDs.hasKeep) "HAS" else "HAS NO"} keep signal.")
    require(!genUs.hasKeep || genUs.keepWidth == genUs.dataBytesCeil,
        s"In ${desiredName}, width of io.us.keep (got ${genUs.keepWidth}) must be 1/8 of width of io.us.data (got ${genUs.dataWidth}).")
    require(!genDs.hasKeep || genDs.keepWidth == genDs.dataBytesCeil,
        s"In ${desiredName}, width of io.ds.keep (got ${genDs.keepWidth}) must be 1/8 of width of io.ds.data (got ${genDs.dataWidth}).")

    // ---- check last matching ----
    require(!(genUs.hasLast ^ genDs.hasLast),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasLast) "HAS" else "HAS NO"} last signal, but " +
                s"io.ds.bits ${if (genDs.hasLast) "HAS" else "HAS NO"} last signal.")

    // ---- check id matching ----
    require(!(genUs.hasId ^ genDs.hasId),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasId) "HAS" else "HAS NO"} id signal, but " +
                s"io.ds.bits ${if (genDs.hasId) "HAS" else "HAS NO"} id signal.")
    require(genUs.idWidth == genDs.idWidth,
        s"In ${desiredName}, width of io.us.bits.id (got ${genUs.idWidth}) must be equal to io.ds.bits.id (got ${genDs.idWidth}).")

    // ---- check dest matching ----
    require(!(genUs.hasDest ^ genDs.hasDest),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasDest) "HAS" else "HAS NO"} id signal, but " +
                s"io.ds.bits ${if (genDs.hasDest) "HAS" else "HAS NO"} id signal.")
    require(genUs.destWidth == genDs.destWidth,
        s"In ${desiredName}, width of io.us.bits.id (got ${genUs.destWidth}) must be equal to io.ds.bits.id (got ${genDs.destWidth}).")

    // ---- check user matching ----
    require(!(genUs.hasUser ^ genDs.hasUser),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasUser) "HAS" else "HAS NO"} user signal, but " +
                s"io.ds.bits ${if (genDs.hasUser) "HAS" else "HAS NO"} user signal.")
    
    genDs match {
        case genDs: StrHasUser => {
            if (genDs.userAssociation == StrUserAssociation.SpreadInBytes) {
                require(genUs.userWidth % genUs.dataBytesCeil == 0,
                    s"In ${desiredName}, width of io.us.bits.user in bits must be multiple of width of io.us.bits.data in bytes when userAssociation == StrUserAssociation.SpreadInBytes.")
                require(genDs.userWidth % genDs.dataBytesCeil == 0,
                    s"In ${desiredName}, width of io.ds.bits.user in bits must be multiple of width of io.ds.bits.data in bytes when userAssociation == StrUserAssociation.SpreadInBytes.")
                require(genUs.userWidth / genUs.dataBytesCeil == genDs.userWidth / genDs.dataBytesCeil,
                    s"In ${desiredName}, number of user bits associated with each byte of data in io.us.bits and io.ds.bits must be equal" +
                            " when userAssociation == StrUserAssociation.SpreadInBytes.")
            }
            else {
                require(genUs.userWidth == genDs.userWidth,
                    s"In ${desiredName}, width of io.us.bits.user (got ${genUs.userWidth}) must be equal to io.ds.bits.user (got ${genDs.userWidth}).")
            }
        }
        case _ => {}
    }

    // ---- io ----
    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(genUs))
        val ds = Irrevocable(genDs)
    })

    // ---- parameters ----
    val nUsBytes = io.us.bits.dataWidth / 8
    val nDsBytes = io.ds.bits.dataWidth / 8
    val nBytesLcm = LCM(nUsBytes, nDsBytes)
    val nBytesMax = math.max(nUsBytes, nDsBytes)
    val nBufBytes =
        if (nBytesLcm >= 2 * nBytesMax) nBytesLcm
        else 2 * nBytesLcm
    val nUserUnitBits = io.us.bits.userBitsPerDataByte
    val ptrWidth = log2Up(nBufBytes)
    val cntWidth = log2Up(nBufBytes + 1)

    // ---- bufs ----
    val dataBuf = RegInit(VecInit.fill(nBufBytes)(0.U(8.W)))
    val strbBuf =
        if (!genUs.hasStrb) None
        else Some(RegInit(VecInit.fill(nBufBytes)(false.B)))
    val keepBuf =
        if (!genUs.hasKeep) None
        else Some(RegInit(VecInit.fill(nBufBytes)(false.B)))
    val lastBuf =
        if (!genUs.hasLast) None
        else Some(RegInit(VecInit.fill(nBufBytes)(false.B)))
    val idBuf =
        if (!genUs.hasId) None
        else Some(RegInit(VecInit.fill(nBufBytes)(0.U.asTypeOf(genUs.asInstanceOf[StrHasId].id))))
    val destBuf =
        if (!genUs.hasDest) None
        else Some(RegInit(VecInit.fill(nBufBytes)(0.U.asTypeOf(genUs.asInstanceOf[StrHasDest].dest))))
    val userBuf =
        if (!genUs.hasUser) None
        else {
            if (genDs.asInstanceOf[StrHasUser].userAssociation == StrUserAssociation.SpreadInBytes) {
                Some(RegInit(VecInit.fill(nBufBytes)(0.U(nUserUnitBits.W))))
            }
            else {
                Some(RegInit(VecInit.fill(nBufBytes)(0.U.asTypeOf(genUs.asInstanceOf[StrHasUser].user))))
            }
        }

    // ---- pointers ----
    val wPtr = RegInit(0.U(ptrWidth.W))
    val rPtr = RegInit(0.U(ptrWidth.W))
    val dCnt = RegInit(0.U(cntWidth.W))

    // ---- hand shakes ----
    val cap = WireDefault(nBufBytes.U(cntWidth.W))
    io.us.ready := cap - dCnt >= nUsBytes.U
    io.ds.valid := dCnt >= nDsBytes.U

    // ---- dcnt ----
    dCnt := MuxCase(dCnt, Seq(
        (io.us.fire && io.ds.fire) -> (dCnt - nDsBytes.U + nUsBytes.U),
        (io.us.fire              ) -> (dCnt              + nUsBytes.U),
        (io.ds.fire              ) -> (dCnt - nDsBytes.U             )
    ))

    // ---- write ----
    when(io.us.fire) {
        when(wPtr === cap - nUsBytes.U) {
            wPtr := 0.U(ptrWidth.W)
        }.otherwise {
            wPtr := wPtr + nUsBytes.U
        }
        for (i <- 0 until nUsBytes) {
            dataBuf(wPtr + i.asUInt) := io.us.bits.data(i * 8 + 7, i * 8)
            io.us.bits match {
                case bits: StrHasStrb => strbBuf.get(wPtr + i.asUInt) := bits.strb(i)
                case _ => {}
            }
            io.us.bits match {
                case bits: StrHasKeep => keepBuf.get(wPtr + i.asUInt) := bits.keep(i)
                case _ => {}
            }
            io.us.bits match {
                case bits: StrHasLast => lastBuf.get(wPtr + i.asUInt) := bits.last && i.asUInt === (nUsBytes - 1).asUInt
                case _ => {}
            }
            io.us.bits match {
                case bits: StrHasId => idBuf.get(wPtr + i.asUInt) := bits.id
                case _ => {}
            }
            io.us.bits match {
                case bits: StrHasDest => destBuf.get(wPtr + i.asUInt) := bits.dest
                case _ => {}
            }
            io.us.bits match {
                case bits: StrHasUser => {
                    if (genDs.asInstanceOf[StrHasUser].userAssociation == StrUserAssociation.SpreadInBytes) {
                        userBuf.get(wPtr + i.asUInt) := bits.user((i + 1) * nUserUnitBits - 1, i * nUserUnitBits)
                    }
                    else {
                        userBuf.get(wPtr + i.asUInt) := bits.user
                    }
                }
                case _ => {}
            }
        }
    }

    // ---- read ----
    val dsData = WireDefault(VecInit.fill(nDsBytes)(0.U(8.W)))
    val dsStrb =
        if (!genDs.hasStrb) None
        else Some(WireDefault(VecInit.fill(nDsBytes)(false.B)))
    val dsKeep =
        if (!genDs.hasKeep) None
        else Some(WireDefault(VecInit.fill(nDsBytes)(false.B)))
    val dsLast =
        if (!genDs.hasLast) None
        else Some(WireDefault(false.B))
    val dsId =
        if (!genDs.hasId) None
        else Some(WireDefault(0.U.asTypeOf(genDs.asInstanceOf[StrHasId].id)))
    val dsDest =
        if (!genDs.hasDest) None
        else Some(WireDefault(0.U.asTypeOf(genDs.asInstanceOf[StrHasDest].dest)))
    val dsUser =
        if (!genDs.hasUser) None
        else if (genDs.asInstanceOf[StrHasUser].userAssociation == StrUserAssociation.SpreadInBytes)
            Some(WireDefault(VecInit.fill(nDsBytes)(0.U(nUserUnitBits.W))))
        else
            Some(WireDefault(0.U.asTypeOf(genDs.asInstanceOf[StrHasUser].user)))
    when(io.ds.fire) {
        when(rPtr === cap - nDsBytes.U) {
            rPtr := 0.U(ptrWidth.W)
        }.otherwise {
            rPtr := rPtr + nDsBytes.U
        }
    }
    
    dsData.zipWithIndex.foreach {
        case (d, i) => d := dataBuf(rPtr + i.asUInt)
    }
    dsStrb.foreach { strb => strb.zipWithIndex.foreach{
        case (s, i) => s := strbBuf.get(rPtr + i.asUInt)
    }}
    dsKeep.foreach { keep => keep.zipWithIndex.foreach {
        case (k, i) => k := keepBuf.get(rPtr + i.asUInt)
    }}
    dsLast.foreach { last => last := lastBuf.get(rPtr + (nDsBytes - 1).U) }
    dsId.foreach { id => id := {
        if (genDs.asInstanceOf[StrHasId].idAssociation == StrIdAssociation.LowestByte)
            idBuf.get(rPtr)
        else
            idBuf.get(rPtr + (nDsBytes - 1).U)
    }}
    dsDest.foreach { dest => dest := {
        if (genDs.asInstanceOf[StrHasDest].destAssociation == StrDestAssociation.LowestByte)
            destBuf.get(rPtr)
        else
            destBuf.get(rPtr + (nDsBytes - 1).U)
    }}
    dsUser.foreach { user => {
        val userAssociation = genDs.asInstanceOf[StrHasUser].userAssociation
        if (userAssociation == StrUserAssociation.LowestByte) {
            user.asInstanceOf[UInt] := userBuf.get(rPtr)
        }
        else if (userAssociation == StrUserAssociation.HighestByte) {
            user.asInstanceOf[UInt] := userBuf.get(rPtr + (nDsBytes - 1).U)
        }
        else { //if(userAssociation == StrUserAssociation.SpreadInBytes) {
            user.asInstanceOf[Vec[UInt]].zipWithIndex.foreach {
                case (u, i) => u := userBuf.get(rPtr + i.asUInt)
            }
        }
    }}
    
    io.ds.bits.data := dsData.asUInt
    if (genDs.hasStrb) io.ds.bits.asInstanceOf[StrHasStrb].strb := dsStrb.get.asUInt
    if (genDs.hasKeep) io.ds.bits.asInstanceOf[StrHasKeep].keep := dsKeep.get.asUInt
    if (genDs.hasLast) io.ds.bits.asInstanceOf[StrHasLast].last := dsLast.get
    if (genDs.hasId) io.ds.bits.asInstanceOf[StrHasId].id := dsId.get
    if (genDs.hasDest) io.ds.bits.asInstanceOf[StrHasDest].dest := dsDest.get
    if (genDs.hasUser) io.ds.bits.asInstanceOf[StrHasUser].user := dsUser.get.asUInt
}

/**
 * Represent a hardware keep remover and data width convert module.
 *
 * "keep remove" : remove byte(s) with the corresponding keep bit(s) is low.
 *
 * example: {{{
 *     clock               /^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^
 *     us.bits.data[23:16]  X  D1 XXXXXXX  D2 X  D5 X...
 *     us.bits.data[15: 8]  XXXXXXXXXXXXXXXXXXX  D4 X...
 *     us.bits.data[ 7: 0]  X  D0 XXXXXXXXXXXXX  D3 X...
 *     us.bits.keep[ 2: 0]  X  5  X  0  X  4  X  7  X...
 *     ds.bits.data[15: 8]  XXXXXXX  D1 XXXXXXXXXXXXX  D3 X  D5 X
 *     ds.bits.data[ 7: 0]  XXXXXXX  D0 XXXXXXXXXXXXX  D2 X  D4 X
 * }}}
 *
 * @param genUs             generator of up-stream bits of IrrevocableIO
 * @param genDs             generator of down-stream bits of IrrevocableIO
 * @tparam U                type of up-stream bits of IrrevocableIO
 * @tparam D                type of down-stream bits of IrrevocableIO
 * @note    CAUTION:
 *          It's the user's responsibility to make sure that `id` changing,
 *          `dest` changing and `last` assert only occurs on boundary of
 *          `LCM(us.dataBytes, ds.dataBytes)` bytes, if `userAssociation !=
 *          StrUserAssociation.SpreadInBytes`, so as `user`. Otherwise, `id`,
 *          `dest` and/or `user` may mess up, `last` may lost.
 */
class StrKeepRemover[U <: StrHasKeep, D <: StrHasData](
        genUs: U, genDs: D) extends Module {

    requireIsChiselType(genUs)
    requireIsChiselType(genDs)
    
    // ---- check data width ----
    require(genDs.dataWidth % 8 == 0,
        s"In ${desiredName}, width of io.ds.bits.data must be multiple of 8, got ${genDs.dataWidth}")
    
    // ---- check strb ----
    require(!(genUs.hasStrb ^ genDs.hasStrb),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasStrb) "HAS" else "HAS NO"} strb signal, but " +
                s"io.ds.bits ${if (genDs.hasStrb) "HAS" else "HAS NO"} strb signal.")
        
    // ---- check last ----
    require(!(genUs.hasLast ^ genDs.hasLast),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasLast) "HAS" else "HAS NO"} last signal, but " +
                s"io.ds.bits ${if (genDs.hasLast) "HAS" else "HAS NO"} last signal.")
    
    // ---- check id ----
    require(!(genUs.hasId ^ genDs.hasId),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasId) "HAS" else "HAS NO"} id signal, but " +
                s"io.ds.bits ${if (genDs.hasId) "HAS" else "HAS NO"} id signal.")
    require(genUs.idWidth == genDs.idWidth,
        s"In ${desiredName}, width of io.us.bits.id (got ${genUs.idWidth}) must be equal to io.ds.bits.id (got ${genDs.idWidth}).")
    
    // ---- check dest matching ----
    require(!(genUs.hasDest ^ genDs.hasDest),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasDest) "HAS" else "HAS NO"} id signal, but " +
                s"io.ds.bits ${if (genDs.hasDest) "HAS" else "HAS NO"} id signal.")
    require(genUs.destWidth == genDs.destWidth,
        s"In ${desiredName}, width of io.us.bits.id (got ${genUs.destWidth}) must be equal to io.ds.bits.id (got ${genDs.destWidth}).")
    
    // ---- check user matching ----
    require(!(genUs.hasUser ^ genDs.hasUser),
        s"In ${desiredName}, io.us.bits ${if (genUs.hasUser) "HAS" else "HAS NO"} user signal, but " +
                s"io.ds.bits ${if (genDs.hasUser) "HAS" else "HAS NO"} user signal.")
    genDs match {
        case genDs: StrHasUser => {
            if (genDs.userAssociation == StrUserAssociation.SpreadInBytes) {
                require(genUs.userWidth % genUs.dataBytesCeil == 0,
                    s"In ${desiredName}, width of io.us.bits.user in bits must be multiple of width of io.us.bits.data in bytes when userAssociation == StrUserAssociation.SpreadInBytes.")
                require(genDs.userWidth % genDs.dataBytesCeil == 0,
                    s"In ${desiredName}, width of io.ds.bits.user in bits must be multiple of width of io.ds.bits.data in bytes when userAssociation == StrUserAssociation.SpreadInBytes.")
                require(genUs.userWidth / genUs.dataBytesCeil == genDs.userWidth / genDs.dataBytesCeil,
                    s"In ${desiredName}, number of user bits associated with each byte of data in io.us.bits and io.ds.bits must be equal" +
                            " when userAssociation == StrUserAssociation.SpreadInBytes.")
            }
            else {
                require(genUs.userWidth == genDs.userWidth,
                    s"In ${desiredName}, width of io.us.bits.user (got ${genUs.userWidth}) must be equal to io.ds.bits.user (got ${genDs.userWidth}).")
            }
        }
        case _ => {}
    }
    
    override def desiredName: String = s"${super.desiredName}_${genUs.typeName}_to_${genDs.typeName}"

    val usBytes = genUs.dataWidth / 8
    val dsBytes = genDs.dataWidth / 8

    val bufSize = 2 * math.max(usBytes, dsBytes)
    val nUserUnitBits = genUs.userBitsPerDataByte
    val ptrWidth = log2Up(bufSize)
    val cntWidth = log2Up(bufSize + 1)

    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(genUs))
        val ds = Irrevocable(genDs)
    })

    // ---- bufs ----
    val dataBuf = RegInit(VecInit(Seq.fill(bufSize)(0.U(8.W))))
    val strbBuf =
        if (!genUs.hasStrb) None
        else Some(RegInit(VecInit.fill(bufSize)(false.B)))
    val lastBuf =
        if (!genUs.hasLast) None
        else Some(RegInit(VecInit.fill(bufSize)(false.B)))
    val idBuf =
        if (!genUs.hasId) None
        else Some(RegInit(VecInit.fill(bufSize)(0.U.asTypeOf(genUs.asInstanceOf[StrHasId].id))))
    val destBuf =
        if (!genUs.hasDest) None
        else Some(RegInit(VecInit.fill(bufSize)(0.U.asTypeOf(genUs.asInstanceOf[StrHasDest].dest))))
    val userBuf =
        if (!genUs.hasUser) None
        else {
            if (genDs.asInstanceOf[StrHasUser].userAssociation == StrUserAssociation.SpreadInBytes) {
                Some(RegInit(VecInit.fill(bufSize)(0.U(nUserUnitBits.W))))
            }
            else {
                Some(RegInit(VecInit.fill(bufSize)(0.U.asTypeOf(genUs.asInstanceOf[StrHasUser].user))))
            }
        }
        
    // ---- pointers ----
    val wPtr = RegInit(0.U(ptrWidth.W))
    val rPtr = RegInit(0.U(ptrWidth.W))
    val dCnt = RegInit(0.U(cntWidth.W))
    
    // ---- hand shakes ----
    val cap = WireDefault(bufSize.U(cntWidth.W))
    io.us.ready := (cap - dCnt) >= usBytes.U
    io.ds.valid := dCnt >= dsBytes.U

    // ---- wptr map ----
    // most significant high bit in keep, for mark last when last assert
    val lastOneIdx = usBytes.U - 1.U - PriorityEncoder(io.us.bits.keep.asBools.reverse)
    // shift of wr ptr for each byte in us
    val wPtrShift = Wire(Vec(usBytes + 1, UInt(ptrWidth.W))).suggestName("wptr_shifts")
    // wr_ptr + shifts regardless of wrapping
    val wPtrRaw = Wire(Vec(usBytes + 1, UInt((ptrWidth + 1).W))).suggestName("wptr_raw")
    // wr_ptr + shifts considered wrapping
    val wPtrWrap = Wire(Vec(usBytes + 1, UInt(ptrWidth.W))).suggestName("wptr_wrap")
    // actual wr_ptr for each byte in us
    val wPtrMap = Wire(Vec(usBytes + 1, UInt(ptrWidth.W))).suggestName("wptr_map")
    dontTouch(wPtrShift)
    dontTouch(wPtrMap)
    wPtrShift.zipWithIndex.foreach {
        case (s, i) => /*prefix(s"loop_$i")*/ {
            if (i == 0) {
                s := 0.U
            }
            else {
                // s := io.us.bits.keep(i - 1, 0).asBools.map(_.asUInt).reduce(_ +& _)
                s := PopCount(io.us.bits.keep(i - 1, 0))
            }
        }
    }
    wPtrMap.zipWithIndex.foreach {
        case (p, i) => /*prefix(s"loop_$i")*/ {
            wPtrRaw(i) := wPtr +& wPtrShift(i)
            wPtrWrap(i) := wPtr +& wPtrShift(i) - bufSize.U
            p := Mux(wPtrRaw(i) >= bufSize.U, wPtrWrap(i), wPtrRaw(i))
        }
    }
    
    // ---- dcnt ----
    dCnt := MuxCase(dCnt, Seq(
        (io.us.fire && io.ds.fire) -> (dCnt - dsBytes.U + wPtrShift(usBytes)),
        (io.us.fire              ) -> (dCnt             + wPtrShift(usBytes)),
        (io.ds.fire              ) -> (dCnt - dsBytes.U                     )
    ))
    
    // ---- write ----
    when(io.us.fire) {
        wPtr := wPtrMap(usBytes)
        for (i <- 0 until usBytes) {
            when(io.us.bits.keep(i)) {
                dataBuf(wPtrMap(i)) := io.us.bits.data(i * 8 + 7, i * 8)
                io.us.bits match {
                    case bits: StrHasStrb => strbBuf.get(wPtrMap(i)) := bits.strb(i)
                    case _ => {}
                }
                io.us.bits match {
                    case bits: StrHasLast => lastBuf.get(wPtrMap(i)) := bits.last && (i.asUInt === lastOneIdx)
                    case _ => {}
                }
                io.us.bits match {
                    case bits: StrHasId => idBuf.get(wPtrMap(i)) := bits.id
                    case _ => {}
                }
                io.us.bits match {
                    case bits: StrHasDest => destBuf.get(wPtrMap(i)) := bits.dest
                    case _ => {}
                }
                io.us.bits match {
                    case bits: StrHasUser => {
                        if (genDs.asInstanceOf[StrHasUser].userAssociation == StrUserAssociation.SpreadInBytes) {
                            userBuf.get(wPtrMap(i)) := bits.user((i + 1) * nUserUnitBits - 1, i * nUserUnitBits)
                        }
                        else {
                            userBuf.get(wPtrMap(i)) := bits.user
                        }
                    }
                    case _ => {}
                }
            }
        }
    }

    // ---- rptr map ----
    val rPtrRaw = Wire(Vec(dsBytes, UInt((ptrWidth + 1).W))).suggestName("rptr_raw")
    val rPtrWrap = Wire(Vec(dsBytes, UInt(ptrWidth.W))).suggestName("rptr_wrap")
    val rPtrMap = Wire(Vec(dsBytes, UInt(ptrWidth.W))).suggestName("rptr_map")
    dontTouch(rPtrMap)
    rPtrMap.zipWithIndex.foreach {
        case (p, i) => /*prefix(s"loop_$i")*/ {
            rPtrRaw(i) := rPtr +& i.asUInt
            rPtrWrap(i) := rPtr +& i.asUInt - bufSize.U
            p := Mux(rPtrRaw(i) >= bufSize.U,
                rPtrWrap(i),
                rPtrRaw(i)
            )
        }
    }
    
    // ---- read ----
    val rWrap = WireInit(rPtr +& dsBytes.U >= bufSize.U)
    when(io.ds.fire) {
        rPtr := Mux(rWrap,
            rPtr +& dsBytes.U - bufSize.U,
            rPtr +& dsBytes.U
        )
    }

    val dsData = Wire(Vec(dsBytes, UInt(8.W)))
    val dsStrb =
        if (!genDs.hasStrb) None
        else Some(Wire(Vec(dsBytes, Bool())))
    val dsLast =
        if (!genDs.hasLast) None
        else Some(Wire(Bool()))
    val dsId =
        if (!genDs.hasId) None
        else Some(Wire(genDs.asInstanceOf[StrHasId].id.cloneType))
    val dsDest =
        if (!genDs.hasDest) None
        else Some(Wire(genDs.asInstanceOf[StrHasDest].dest.cloneType))
    val dsUser =
        if (!genDs.hasUser) None
        else if (genDs.asInstanceOf[StrHasUser].userAssociation == StrUserAssociation.SpreadInBytes)
            Some(Wire(Vec(dsBytes, UInt(nUserUnitBits.W))))
        else
            Some(Wire(genDs.asInstanceOf[StrHasUser].user.cloneType))
    
    dsData.zipWithIndex.foreach {
        case (d, i) => d := dataBuf(rPtrMap(i))
    }
    dsStrb.foreach{ strb => strb.zipWithIndex.foreach {
        case (s, i) => s := strbBuf.get(rPtrMap(i))
    }}
    dsLast.foreach { last => last := lastBuf.get(rPtrMap(dsBytes - 1))}
    dsId.foreach { id => id := {
        if (genDs.asInstanceOf[StrHasId].idAssociation == StrIdAssociation.LowestByte)
            idBuf.get(rPtrMap(0))
        else
            idBuf.get(rPtrMap(dsBytes - 1))
    }}
    dsDest.foreach { dest => dest := {
        if (genDs.asInstanceOf[StrHasDest].destAssociation == StrDestAssociation.LowestByte)
            destBuf.get(rPtrMap(0))
        else
            destBuf.get(rPtrMap(dsBytes - 1))
    }}
    dsUser.foreach { user => {
        val userAssociation = genDs.asInstanceOf[StrHasUser].userAssociation
        if (userAssociation == StrUserAssociation.LowestByte) {
            user.asInstanceOf[UInt] := userBuf.get(rPtrMap(0))
        }
        else if (userAssociation == StrUserAssociation.HighestByte) {
            user.asInstanceOf[UInt] := userBuf.get(rPtrMap(dsBytes - 1))
        }
        else { //if(userAssociation == StrUserAssociation.SpreadInBytes) {
            user.asInstanceOf[Vec[UInt]].zipWithIndex.foreach {
                case (u, i) => u := userBuf.get(rPtrMap(i))
            }
        }
    }}
    
    io.ds.bits.data := dsData.asUInt
    if (genDs.hasStrb) io.ds.bits.asInstanceOf[StrHasStrb].strb := dsStrb.get.asUInt
    if (genDs.hasKeep) io.ds.bits.asInstanceOf[StrHasKeep].keep := ~0.U(genDs.keepWidth.W)
    if (genDs.hasLast) io.ds.bits.asInstanceOf[StrHasLast].last := dsLast.get
    if (genDs.hasId) io.ds.bits.asInstanceOf[StrHasId].id := dsId.get
    if (genDs.hasDest) io.ds.bits.asInstanceOf[StrHasDest].dest := dsDest.get
    if (genDs.hasUser) io.ds.bits.asInstanceOf[StrHasUser].user := dsUser.get.asUInt
}


package examples {
    class str_frs_example extends Module {
        class bits extends StrHasData with StrHasLast {
            val last = Bool()
            lazy val data = SInt(8.W)
        }

        val us = IO(Flipped(Irrevocable(new bits))).suggestName("s0a_abc_axis1b_def")
        val ds = IO(Irrevocable(new bits)).suggestName("m0a_abc_axis1b_def")

        val frs = Module(new StrFrs(new bits))
        us <> frs.io.us
        frs.io.ds <> ds
    }

    class str_birs_example extends RawModule {
        class bits extends StrHasData with StrHasLast {
            val last = Bool()
            lazy val data = SInt(8.W)
        }

        val io = FlatIO(new Bundle {
            val aclk = Input(Clock())
            val areset_n = Input(Bool())
            val us = Flipped(Irrevocable(new bits))
            val ds = Irrevocable(new bits)
        })

        withClockAndReset(io.aclk, !io.areset_n) {
            val firs = Module(new StrBirs(new bits, Some(() => {
                val b = Wire(new bits)
                b.last := false.B
                b.data := "h15".U(8.W).asSInt
                b
            })))
            io.us <> firs.io.us
            firs.io.ds <> io.ds
        }
    }

    class hscomb1_example extends Module {
        class usbits extends StrHasData with StrHasLast {
            val last = Bool()
            lazy val data = SInt(8.W)
        }

        class dsbits extends StrHasData with StrHasLast {
            val last = Bool()
            lazy val data = SInt(8.W)
        }

        val io = FlatIO(new Bundle {
            val us0 = Flipped(Irrevocable(new usbits))
            val us1 = Flipped(Irrevocable(new usbits))
            val ds0 = Irrevocable(new dsbits)
            val ds1 = Irrevocable(new dsbits)
        })

        io.us0 <> io.ds0
        io.us1 <> io.ds1

        val cb = Module(new StrHsCombModule(2, 2))
        cb.io.us_valid := io.us1.valid ## io.us0.valid
        io.us0.ready := cb.io.us_ready(0)
        io.us1.ready := cb.io.us_ready(1)
        io.ds0.valid := cb.io.ds_valid(0)
        io.ds1.valid := cb.io.ds_valid(1)
        cb.io.ds_ready := io.ds1.ready ## io.ds0.ready

        io.ds0.bits.data <> -io.us0.bits.data
        io.ds1.bits.data <> -io.us1.bits.data
    }

    class hscomb2_example extends Module {
        class usbits extends StrHasData with StrHasLast {
            val last = Bool()
            lazy val data = SInt(8.W)
        }

        class dsbits extends StrHasData with StrHasLast {
            val last = Bool()
            lazy val data = SInt(8.W)
        }

        val io = FlatIO(new Bundle {
            val us0 = Flipped(Irrevocable(new usbits))
            val us1 = Flipped(Irrevocable(new usbits))
            val ds0 = Irrevocable(new dsbits)
            val ds1 = Irrevocable(new dsbits)
        })

        io.us0 <> io.ds0
        io.us1 <> io.ds1

        val cb = StrHsComb(2, 2)
        cb.usValids(io.us1.valid, io.us0.valid)
        cb.usReadys(io.us1.ready, io.us0.ready)
        cb.dsValids(io.ds1.valid, io.ds0.valid)
        cb.dsReadys(io.ds1.ready, io.ds0.ready)

        io.ds0.bits.data <> -io.us0.bits.data
        io.ds1.bits.data <> -io.us1.bits.data
    }

    class str_dcfifo_example extends RawModule {
        class pl extends StrHasData with StrHasLast {
            val last = Bool()
            lazy val data = UInt(8.W)
        }
        val aw = 4
        val wr_has_dcnt = true
        val rd_has_dcnt = true
        val wr_has_rwcnt = false
        val rd_has_rwcnt = false
        val io = FlatIO(new Bundle {
            val clk_us = Input(Clock())
            val clk_ds = Input(Clock())
            val rst_us = Input(Bool())
            val rst_ds = Input(Bool())
            val us = Flipped(Irrevocable(new pl))
            val ds = Irrevocable(new pl)
            val cnt_us = if(wr_has_dcnt) Some(FifoIO.CntProvider(aw, wr_has_rwcnt)) else None
            val cnt_ds = if(rd_has_dcnt) Some(FifoIO.CntProvider(aw, rd_has_rwcnt)) else None
        })

        val str_dcfifo = Module(new StrDcFifo(new pl, aw, wr_has_dcnt, rd_has_dcnt, wr_has_rwcnt, rd_has_rwcnt))

        str_dcfifo.io.usClock := io.clk_us
        str_dcfifo.io.dsClock := io.clk_ds
        str_dcfifo.io.usReset := io.rst_us
        str_dcfifo.io.dsReset := io.rst_ds

        str_dcfifo.io.us <> io.us
        str_dcfifo.io.ds <> io.ds

        if(wr_has_dcnt)
            str_dcfifo.io.usCnt.get <> io.cnt_us.get
        if(rd_has_dcnt)
            str_dcfifo.io.dsCnt.get <> io.cnt_ds.get
    }

    class str_dwc_example extends Module {
        val usBytes = 6
        val dsBytes = 4
        val idWidth = 4
        val destWidth = 6
        val userUnitWidth = 2
        val idAsso = StrIdAssociation.LowestByte
        val destAsso = StrDestAssociation.LowestByte
        val userAsso = StrUserAssociation.SpreadInBytes
        class UsBits extends StrHasStrb with StrHasKeep with StrHasLast with StrHasId with StrHasDest with StrHasUser {
            lazy val data: UInt = UInt((usBytes * 8).W)
            lazy val strb: UInt = UInt(usBytes.W)
            lazy val keep: UInt = UInt(usBytes.W)
            val last: Bool = Bool()
            val id: UInt = UInt(idWidth.W)
            val dest: UInt = UInt(destWidth.W)
            val user: UInt = UInt((userUnitWidth * usBytes).W)
        }
        class DsBits extends StrHasStrb with StrHasKeep with StrHasLast with StrHasId with StrHasDest with StrHasUser {
            lazy val data: UInt = UInt((dsBytes * 8).W)
            lazy val strb: UInt = UInt(dsBytes.W)
            lazy val keep: UInt = UInt(dsBytes.W)
            val last: Bool = Bool()
            val id: UInt = UInt(idWidth.W)
            val dest: UInt = UInt(destWidth.W)
            val user: UInt = UInt((userUnitWidth * dsBytes).W)
            override val idAssociation = idAsso
            override val destAssociation = destAsso
            override val userAssociation = userAsso
        }
        val io = IO(new Bundle {
            val us = Flipped(Irrevocable(new UsBits))
            val ds = Irrevocable(new DsBits)
        })
        val dwc = Module(new StrDataWidthConverter(new UsBits, new DsBits/*, idAsso, destAsso, userAsso*/))
        io.us <> dwc.io.us
        dwc.io.ds <> io.ds
    }

    class str_keep_remover_example extends Module {
        val usBytes = 8
        val dsBytes = 8
        class usBits extends StrHasKeep with StrHasLast {
            lazy val data: UInt = UInt((usBytes * 8).W)
            lazy val keep: UInt = UInt(usBytes.W)
            val last: Bool = Bool()
        }
        class dsBits extends StrHasKeep with StrHasLast {
            lazy val data: UInt = UInt((dsBytes * 8).W)
            lazy val keep: UInt = UInt(dsBytes.W)
            val last: Bool = Bool()
        }
        val io = IO(new Bundle {
            val us = Flipped(Irrevocable(new usBits))
            val ds = Irrevocable(new dsBits)
        })

        val theKeepRemover = Module(new StrKeepRemover(new usBits, new dsBits))

        theKeepRemover.io.us <> io.us
        theKeepRemover.io.ds <> io.ds
    }
}