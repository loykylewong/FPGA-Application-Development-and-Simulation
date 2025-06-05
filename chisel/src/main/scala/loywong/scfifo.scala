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

/**
 * Collection of native FIFO interfaces.
 */
object FifoIO {
    /**
     * Interface of fifo writer.
     * @param gen   Generator of data
     * @tparam T    Type of data
     */
    class WriterIO[+T <: Data]
    (gen: T = UInt(8.W)) extends Bundle {
        val data  = Output(gen)
        val write = Output(Bool())
        val full  = Input(Bool())
    }

    /**
     * Create an interface of fifo writer
     * @param gen   Generator of data
     * @tparam T    Type of data
     * @return      Interface created
     */
    def Writer[T <: Data](gen: T = UInt(8.W)) = {
        new WriterIO(gen)
    }

    /**
     * Create an interface of fifo writee (which is in FIFO)
     * @param gen   Generator of data
     * @tparam T    Type of data
     * @return      Interface created
     */
    def Writee[T <: Data](gen: T = UInt(8.W)) = {
        Flipped(new WriterIO(gen))
    }

    /**
     * Interface of fifo reader.
     * @param gen   Generator of data
     * @tparam T    Type of data
     */
    class ReaderIO[+T <: Data]
    (gen: T = UInt(8.W)) extends Bundle {
        val data  = Input(gen)
        val read  = Output(Bool())
        val empty = Input(Bool())
    }

    /**
     * Create an interface of fifo reader
     * @param gen   Generator of data
     * @tparam T    Type of data
     * @return      Interface created
     */
    def Reader[T <: Data](gen: T = UInt(8.W)) = {
        new ReaderIO(gen)
    }

    /**
     * Create an interface of fifo readee (which is in FIFO)
     * @param gen   Generator of data
     * @tparam T    Type of data
     * @return      Interface created
     */
    def Readee[T <: Data](gen: T = UInt(8.W)) = {
        Flipped(new ReaderIO(gen))
    }

    /**
     * Interface for providing counter information of FIFO
     * @param width             Width of Counter, must be >= the actual width
     *                          of those counters in FIFO
     * @param hasWriteReadCount True if `writeCnt` and `readCnt` are existed
     */
    class CounterIO(width: Int, hasWriteReadCount: Boolean = false) extends Bundle {
        val dataCnt  = Output(UInt(width.W))
        val writeCnt = if (hasWriteReadCount) Some(Output(UInt(width.W))) else None
        val readCnt  = if (hasWriteReadCount) Some(Output(UInt(width.W))) else None
    }

    /**
     * Create an interface of counter information provider (which is in FIFO)
     * @param width             Width of Counter, must be >= the actual width
     *                          of those counters in FIFO
     * @param hasWriteReadCount True if `writeCnt` and `readCnt` are existed
     * @return                  The interface created
     */
    def CntProvider(width: Int, hasWriteReadCount: Boolean = false) = {
        new CounterIO(width, hasWriteReadCount)
    }

    /**
     * Create an interface of counter information User
     * @param width             Width of Counter, must be >= the actual width
     *                          of those counters in FIFO
     * @param hasWriteReadCount True if `writeCnt` and `readCnt` are existed
     * @return                  The interface created
     */
    def CntUser(width: Int, hasWriteReadCount: Boolean = false) = {
        Flipped(new CounterIO(width, hasWriteReadCount))
    }
}

/**
 * Represent a hardware Single Clock FIFO module.
 * @param gen           Generator of data
 * @param addrWidth     Width of inner address, FIFO depth = 2**addrWidth - 1
 * @param hasDataCnt    True if `dataCnt` are needed
 * @param hasWrRdCnt    True if `writeCnt` and `readCnt` are needed
 * @tparam T            Type of data
 * @note    If `hasWrRdCnt` is true, `hasDataCnt` must also be true.
 */
class ScFifo2[T <: Data](gen: T, addrWidth: Int,
                         hasDataCnt: Boolean = false,
                         hasWrRdCnt: Boolean = false) extends Module {
    require(!(!hasDataCnt && hasWrRdCnt), "In ScFifo2, when hasDataCnt == false, hasWrRdCnt is not allowed to be true!")
    override def desiredName = s"${super.desiredName}_${gen.typeName}"

    val io = IO(new Bundle {
        val w = FifoIO.Writee(gen)
        val r = FifoIO.Readee(gen)
        val c = if(hasDataCnt) Some(FifoIO.CntProvider(addrWidth, hasWrRdCnt)) else None
    })

    val m: Int = 1 << addrWidth
    val capacity: Int = m - 1
    val (wr_cnt, _) = Counter(io.w.write, m)
    val (rd_cnt, _) = Counter(io.r.read, m)
    val data_cnt = WireDefault(wr_cnt - rd_cnt)

    io.c.foreach(c => {
        c.dataCnt  := data_cnt
        c.readCnt.foreach(_ := rd_cnt)
        c.writeCnt.foreach(_ := wr_cnt)
    })
    io.w.full     := data_cnt === capacity.U
    io.r.empty    := data_cnt === 0.U

    val rd_dly = RegNext(io.r.read, false.B)

    val the_ram = SyncReadMem(m, gen)
    when(io.w.write) { the_ram.write(wr_cnt, io.w.data) }
    val qout_b = the_ram.read(rd_cnt)

    val qout_b_reg = RegEnable(qout_b, 0.U.asTypeOf(gen), rd_dly)
    io.r.data := Mux(rd_dly, qout_b, qout_b_reg)
}

object ScFifo2 {
    /**
     * Create an instance of Single Clock FIFO module.
     * @param gen           Generator of data
     * @param addrWidth     Width of inner address, FIFO depth = 2**addrWidth-1
     * @param hasDataCnt    True if `dataCnt` are needed
     * @param hasWrRdCnt    True if `writeCnt` and `readCnt` are needed
     * @tparam T            Type of data
     * @return              The instance created
     * @note    If `hasWrRdCnt` is true, `hasDataCnt` must also be true.
     * @example {{{
     *              val fifo = ScFifo2(UInt(8.W), 10, true)
     *              io.fifo_wr <> fifo.w
     *              io.fifo_rd <> fifo.c
     *              io.fifo_cnt <> fifo.c.get // c is Option[FifoIO.CounterIO]
     * }}}
     */
    def apply[T <: Data](gen: T, addrWidth: Int, hasDataCnt: Boolean = false, hasWrRdCnt: Boolean = false) = {
        Module(new ScFifo2(gen, addrWidth, hasDataCnt, hasWrRdCnt))
    }

    /**
     * Create an instance of Single Clock FIFO module, and make some
     * connections.
     * @param gen           Generator of data
     * @param addrWidth     Width of inner address, FIFO depth = 2**addrWidth-1
     * @param hasDataCnt    True if `dataCnt` are needed
     * @param hasWrRdCnt    True if `writeCnt` and `readCnt` are needed
     * @param wr            The FifoIO.Writer to be connected to FIFO
     * @tparam T            Type of data
     * @return              (readee, cnt) :
     *                      readee: the readee(FifoIO.Readee) of the FIFO
     *                      cnt   : the cnt(FifoIO.CntProvider) of the FIFO
     * @example {{{
     *              val (rd, cnt) = ScFifo2.withConnect(UInt(8.W), 10, true)(io.fifo_writer)
     *              io.fifo_reader <> rd
     *              io.fifo_cnt <> cnt.get  // cnt is Option[FifoIO.CounterIO]
     * }}}
     */
    def withConnect[T <: Data](gen: T, addrWidth: Int, hasDataCnt: Boolean = false, hasWrRdCnt: Boolean = false)(wr: FifoIO.WriterIO[T]) = {
        val scfifo2 = Module(new ScFifo2(gen, addrWidth, hasDataCnt, hasWrRdCnt))
        scfifo2.io.w <> wr
        (scfifo2.io.r, scfifo2.io.c)
    }
}

package examples {
    /**
     * A scfifo2 example for emitting verilog.
     */
    class scfifo2_example extends Module {
        val dType = UInt(8.W)
        val addrWidth = 10
        val hasDataCnt = true
        val hasWrRdCnt = true
        val io = IO(new Bundle {
            val w = FifoIO.Writee(dType)
            val r = FifoIO.Readee(dType)
            val c = if (hasDataCnt) Some(FifoIO.CntProvider(addrWidth, hasWrRdCnt)) else None
        })
        val (r, c) = ScFifo2.withConnect(dType, addrWidth, hasDataCnt, hasWrRdCnt)(io.w)
        io.r <> r
        if (hasDataCnt) {
            io.c.get <> c.get
        }
    }
}
