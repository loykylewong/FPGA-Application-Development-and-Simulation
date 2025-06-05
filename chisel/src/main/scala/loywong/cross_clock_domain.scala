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
import chisel3.util.RegEnable
// import chisel3.util._

/**
 * Utility class for anti-metastable by using 2 or more synchronize stages
 * (flip-flops).
 * @param gen       Generator of data
 * @param nStages   Number of synchronize stages
 * @param init      Function for generating reset value(s), default generate
 *                  all 0s, set to None for generating no reset logic.
 * @tparam T        Type of data
 * @note            You may prefer to use the homonymous factory object.
 * @example {{{
 *              val ams_1 = new AntiMetastable(UInt(8.W))(
 *                                      Some(()=>{ 255.U(8.W) }))
 *              // Or using the factory
 *              // val ams_1 = AntiMetastable(UInt(8.W))(
 *              //                     Some(()=>{ 255.U(8.W) }))
 *              io.some_out := ams_1.input(io.some_in)
 * }}}
 */
class AntiMetastable[T <: Data](gen: T, nStages: Int = 2)
                               (init: Option[()=>T] = Some(()=>0.U.asTypeOf(gen))) {
    require(nStages >=1, "In AntiMetastable, nStages must be >= 1.")
    val stgs = init match {
        case Some(f) => RegInit(VecInit(Seq.fill(nStages)(f())))
        case None    => Reg(Vec(nStages, gen))
    }

    /**
     * Insert synchronize stages between input and output.
     * @param data  Input data signal
     * @tparam T    Type of data
     * @return      Output after the synchronize stages
     */
    def input[T <: Data](data: T) = {
        stgs.zipWithIndex.foreach{ case(stg, i) => {
            if(i == 0) stg := data
            else       stg := stgs(i - 1)
        }}
        stgs(nStages - 1)
    }
}

object AntiMetastable {
    /**
     * Instantiate a utility class for anti-metastable by using 2 or more
     * synchronize stages (flip-flops).
     * @param gen       Generator of data
     * @param init      Initialization function for resetting data
     * @param nStages   Number of synchronize stages
     * @tparam T        Type of data
     * @note            You may prefer to use the homonymous factory object.
     * @example {{{
     *              val ams_1 = AntiMetastable(UInt(8.W))(
     *                                  Some(()=>{ 255.U(8.W) }))
     *              io.some_out := ams_1.input(io.some_in)
     * }}}
     */
    def apply[T <: Data](gen: T, nStages: Int = 2)
                        (init: Option[()=>T] = Some(()=>0.U.asTypeOf(gen))) = {
        new AntiMetastable(gen, nStages)(init)
    }

    /**
     * Utility method for inserting a 2-synchronize-stage anti-metastable circuit.
     * @param data  Input data signal
     * @param init  Function to generate init value, generate all 0s by
     *              default, generate no reset logic if set to None
     * @tparam T    Type of data
     * @return      Output data after 2 synchronize stages
     * @note        No reset in inserted stages.
     */
    def _2ff[T <: Data](data: T)
                       (init: Option[()=>T] = Some(()=>0.U.asTypeOf(data))) = {
        val stgs = init match {
            case None    => Reg(Vec(2, data.cloneType))
            case Some(f) => RegInit(VecInit(Seq.fill(2)(f())))
        }
        stgs(0) := data
        stgs(1) := stgs(0)
        stgs(1)
    }

    /**
     * Utility method for inserting a 3-synchronize-stage anti-metastable circuit.
     * @param data  Input data signal
     * @param init  Function to generate init value, generate all 0s by
     *              default, generate no reset logic if set to None
     * @tparam T    Type of data
     * @return      Output data after 3 synchronize stages
     * @note        No reset in inserted stages.
     */
    def _3ff[T <: Data](data: T)
                       (init: Option[()=>T] = Some(()=>0.U.asTypeOf(data))) = {
        val stgs = init match {
            case None    => Reg(Vec(3, data.cloneType))
            case Some(f) => RegInit(VecInit(Seq.fill(3)(f())))
        }
        stgs(0) := data
        stgs(1) := stgs(0)
        stgs(2) := stgs(1)
        stgs(2)
    }
}

object Edge2En {
    /**
     * Convert edges of "slow" signal to single cycle enable.
     * @param in        Input signal
     * @param initOnes  Reset synchronize stages to 1s if true
     * @param nStages   Number of synchronize stages
     * @return          (rising, falling, output)
     *                  rising : enable signal for rising edge
     *                  falling: enable signal for falling edge
     *                  output : input signal via synchronize stages
     * @example {{{
     *              (xx_rising, _, _) := Edge2En(xx)
     * }}}
     */
    def apply(in:Bool, initOnes:Boolean = false, nStages:Int = 2): (Bool, Bool, Bool) = {
        require(nStages >= 0, "In Edge2En, nStages must be >= 0.")
        val dly_init = if(initOnes) {
            // Fill(nStages + 1, 1.U(1.W))
            ~0.U((nStages + 1).W)
        } else {
            0.U((nStages + 1).W)
        }
        val dly = RegInit(dly_init.cloneType, dly_init)
        val rising = WireInit(false.B)
        val falling = WireInit(false.B)
        if(nStages == 0) {
            dly(0) := in
            rising  := "b01".U === dly(0) ## in
            falling := "b10".U === dly(0) ## in
        }
        else {
            dly := (dly << 1) | in.asUInt
            rising  := "b01".U === dly(nStages) ## dly(nStages - 1)
            falling := "b10".U === dly(nStages) ## dly(nStages - 1)
        }
        (rising, falling, dly(nStages))
    }
}

/*
/**
 * Utility class for cross clock domain trigger by toggle flip-flop and
 * synchronize stages.
 * @param fromClock Clock of the clock domain in which trigger signal sent
 * @param toClock   Clock of the clock domain in which trigger signal received
 * @param fromReset Reset in `fromClock` domain
 * @param toReset   Reset in `toClock` domain
 * @param nStages   Number of synchronize stages for anti-metastable between
 *                  clock domains
 * @note            You may prefer to use the homonymous factory object.
 * @example {{{
 *              val ccd_trig = new CcdTrigger(clk_a, clk_b)()
 *              withClock(clk_a) { when(xx_a) { ccd_trig.trigger() } }
 *              withClock(clk_b) { xx_b := ccd_trig.out() }
 *              // Or, use the factory
 *              // val ccd_trig = CcdTrigger(clk_a, clk_b)()
 *              // withClock(clk_a) { when(xx_a) { ccd_trig.trigger() } }
 *              // withClock(clk_b) { xx_b := ccd_trig.out() }
 * }}}
 */
class CcdTriggerInline(fromClock: Clock, toClock: Clock,
                 fromReset: Bool, toReset: Bool)
                (nStages: Int = 2) {
    require(nStages >=1, "nStages must be >= 1 in CcdTrigger")
    val toggle_a = withClockAndReset(fromClock, fromReset) {
        RegInit(false.B)
    }
    val toggle_b = withClockAndReset(toClock, toReset) {
        RegInit(0.U((nStages+1).W))
    }
    withClock(toClock) {
        toggle_b := (toggle_b << 1) | toggle_a
    }

    /**
     * Send a trigger signal, use in `fromClock` domain.
     */
    def trigger(en: Bool = true.B): Unit = {
        withClock(fromClock) {
            when(en) {
                toggle_a := !toggle_a
            }
        }
    }

    /**
     * Assigned to a wire for receiving trigger signal, use in `toClock`
     * domain. The wire assigned will be high for one clock period due to each
     * trigger signal sent from `fromClock`
     * domain.
     * @return Signal indicates trigger received.
     */
    def out(): Bool = {
        toggle_b(nStages, nStages - 1).xorR
    }
}

object CcdTriggerInline {
    /**
     * Create an instance of cross clock domain trigger.
     * @param fromClock Clock of the clock domain in which trigger signal sent
     * @param toClock   Clock of the clock domain in which trigger signal received
     * @param fromReset Reset in `fromClock` domain, optional, default false
     * @param toReset   Reset in `toClock` domain, optional, default false
     * @param nStages   Number of synchronize stages for anti-metastable between
     *                  clock domains
     * @return          Instance created
     * @note            You may prefer to use the homonymous factory object
     * @example {{{
     *              val ccd_trig = CcdTrigger(clk_a, clk_b)()
     *              withClock(clk_a) { when(xx_a) { ccd_trig.trigger() } }
     *              withClock(clk_b) { xx_b := ccd_trig.out() }
     * }}}
     */
    def apply(fromClock: Clock, toClock: Clock,
              fromReset: Bool, toReset: Bool)
             (nStages: Int = 2): CcdTrigger = {
        new CcdTriggerInline(fromClock, toClock, fromReset, toReset)(nStages)
    }
}
 */

/**
 * Represent a hardware Cross Clock Domain Trigger module.
 * @param nStages   Number of synchronize stages for anti-metastable
 */
class CcdTrigger(nStages: Int = 2) extends RawModule {
    val io = IO(new Bundle {
        val fromClock  = Input(Clock())
        val toClock    = Input(Clock())
        val fromReset  = Input(Bool())
        val toReset    = Input(Bool())
        val triggerIn  = Input(Bool())
        val triggerOut = Output(Bool())
    })
    require(nStages >=1, "In CcdTrigger, nStages must be >= 1.")

    val toggle_a = withClockAndReset(io.fromClock, io.fromReset) {
        RegInit(false.B)
    }
    val toggle_b = withClockAndReset(io.toClock, io.toReset) {
        RegInit(0.U((nStages+1).W))
    }
    withClock(io.toClock) {
        toggle_b := (toggle_b << 1) | toggle_a
    }

    withClock(io.fromClock) {
        when(io.triggerIn) {
            toggle_a := !toggle_a
        }
    }
    io.triggerOut := toggle_b(nStages, nStages - 1).xorR
}

object CcdTrigger {
    /**
     * Create an instance of class CcdTrigger and make connections.
     * @param fromClock Clock of clock domain in which trigger signal sent
     * @param toClock   Clock of clock domain in which trigger signal received
     * @param fromReset Reset of `fromClock` domain
     * @param toReset   Reset of `toClock` domain
     * @param triggerIn Trigger signal input
     * @param nStages   Number of synchronize stages for anti-metastable
     * @return          Trigger signal output
     * @example {{{
     *              val trig_out = CcdTrigger(clk_a, clk_b, rst_a, rst_b)(
     *                                        trig_in)
     * }}}
     */
    def apply(fromClock: Clock, toClock: Clock,
              fromReset: Bool, toReset: Bool)(triggerIn: Bool, nStages: Int = 2): Bool = {
        val ccd_trigger = Module(new CcdTrigger(nStages))
        ccd_trigger.io.fromClock := fromClock
        ccd_trigger.io.toClock := toClock
        ccd_trigger.io.fromReset := fromReset
        ccd_trigger.io.toReset := toReset
        ccd_trigger.io.triggerIn := triggerIn
        ccd_trigger.io.triggerOut
    }
}

/*
/**
 * Utility class for transferring counting status between clock domains.
 * @param fromClock Clock of the clock domain in which status transferred
 * @param toClock   Clock of the clock domain in which status received
 * @param fromReset Reset in `fromClock` domain
 * @param toReset   Reset in `toClock` domain
 * @param width     Width in bits of the counter
 */
class CcdCounter(fromClock: Clock, toClock: Clock,
                 fromReset: Bool, toReset: Bool)
                (width: Int){
    require(width >= 1, "In CcdCounter, width must be >= 1.")

    private val cnt_a = withClockAndReset(fromClock, fromReset) {
        RegInit(0.U(width.W))
    }
    private val gray = withClockAndReset(fromClock, fromReset) {
        RegInit(0.U(width.W))
    }
    private val gray_sync = withClockAndReset(toClock, toReset) {
        val gray_ams = AntiMetastable(UInt(width.W))()
        gray_ams.input(gray)
    }
    private val bin_next = cnt_a + 1.U(width.W)
    private val gray_next = if(width > 1) bin_next ^ (bin_next >> 1).asUInt
                            else bin_next

    /**
     * Increase the counter by one step, use in `fromClock` domain.
     */
    def inc(en: Bool = true.B): Unit = {
        withClock(fromClock) {
            when(en) {
                cnt_a := bin_next
                gray := gray_next
            }
        }
    }

    /**
     * Assign to wire for getting the counter value, use in `fromClock` domain.
     * @return Counter value in `fromClock` domain.
     */
    def cnt_from(): UInt = {
        cnt_a
    }

    /**
     * Assign to wire for getting the counter value, use in `toClock` domain.
     * @return Counter value in `toClock` domain.
     */
    def cnt_to(): UInt = {
        (0 until width).foldLeft(0.U) { (acc, i) => {
            acc | ((gray_sync >> i).xorR << i)
        }}
    }
}

object CcdCounter {
    /**
     * Create an instance of Cross Clock Domain Counter.
     * @param fromClock Clock of the clock domain in which status transferred
     * @param toClock   Clock of the clock domain in which status received
     * @param fromReset Reset in `fromClock` domain
     * @param toReset   Reset in `toClock` domain
     * @param width     Width in bits of the counter
     * @return          The instance created
     */
    def apply(fromClock: Clock, toClock: Clock,
              fromReset: Bool, toReset: Bool)
             (width: Int) = {
        new CcdCounter(fromClock, toClock, fromReset, toReset)(width)
    }
}
*/

/**
 * Represent a hardware Cross Clock Domain Counter module.
 * @param width Width in bits of the counter
 */
class CcdCounterModule(width: Int) extends RawModule {
    require(width >= 1, "In CcdCounterModule, width must be >= 1.")
    override def desiredName: String = super.desiredName + s"_${width}b"

    val io = IO(new Bundle {
        val fromClock = Input(Clock())
        val toClock   = Input(Clock())
        val fromReset = Input(Bool())
        val toReset   = Input(Bool())
        val inc_from  = Input(Bool())
        val cnt_from  = Output(UInt(width.W))
        val cnt_to    = Output(UInt(width.W))
    })

    private val cnt_from = withClockAndReset(io.fromClock, io.fromReset) {
        RegInit(0.U(width.W))
    }
    private val gray = withClockAndReset(io.fromClock, io.fromReset) {
        RegInit(0.U(width.W))
    }
    private val gray_sync = withClockAndReset(io.toClock, io.toReset) {
        AntiMetastable._2ff(gray)()
    }
    private val bin_next = cnt_from + 1.U(width.W)
    private val gray_next =
        if(width > 1) bin_next ^ (bin_next >> 1).asUInt
        else bin_next

    withClock(io.fromClock) {
        when(io.inc_from) {
            cnt_from := bin_next
            gray     := gray_next
        }
    }

    io.cnt_from := cnt_from
    io.cnt_to :=
        (0 until width).foldLeft(0.U) {
            (acc, i) => {
                acc | ((gray_sync >> i).xorR << i)
            }
        }
}

/**
 * A wrapper class of CcdCounterModule for ease of use
 * @param fromClock Clock of clock domain in which the counter increase
 * @param toClock   Clock of clock domain in which the counter value received
 * @param fromReset Reset of `fromClock` domain
 * @param toReset   Reset of `toClock` domain
 * @param width     Width in bits of the counter
 * @param incCond   The condition of counter increasing
 */
class CcdCounter(fromClock: Clock, toClock: Clock,
                 fromReset: Bool, toReset: Bool)(
                 width: Int, incCond: Bool) {
    require(width > 0, "In CcdCounter, width must be >= 1.")

    val ccd_cnt = Module(new CcdCounterModule(width))
    ccd_cnt.io.fromClock := fromClock
    ccd_cnt.io.toClock := toClock
    ccd_cnt.io.fromReset := fromReset
    ccd_cnt.io.toReset := toReset
    ccd_cnt.io.inc_from := incCond

    /**
     * Get the counter value in `fromClock` domain
     *
     * @return The counter value
     */
    def cnt_from() = {
        ccd_cnt.io.cnt_from
    }

    /**
     * Get the counter value in `toClock` domain
     *
     * @return The counter value
     */
    def cnt_to() = {
        ccd_cnt.io.cnt_to
    }
}

object CcdCounter {
    /**
     * Create an instance of CcdCounter, with a CcdCounterModule in it and make
     * some connections.
     * @param fromClock Clock of clock domain in which the counter increase
     * @param toClock   Clock of clock domain in which the counter value received
     * @param fromReset Reset of `fromClock` domain
     * @param toReset   Reset of `toClock` domain
     * @param width     Width in bits of the counter
     * @param incCond   The condition of counter increasing
     * @return          The instance created
     */
    def apply(fromClock: Clock, toClock: Clock, fromReset: Bool, toReset: Bool)(width: Int, incCond: Bool) = {
        new CcdCounter(fromClock, toClock, fromReset, toReset)(width, incCond)
    }
}

/**
 * Represent a hardware Dual Clock Fifo with native fifo interfaces.
 * @param gen           Generator of data
 * @param addrWidth     Width in bits of the inner address,
 *                      fifo depth = 2**addrWidth - 1
 * @param wrHasDataCnt  Set to true if data count is needed in write side
 * @param rdHasDataCnt  Set to true if data count is needed in read side
 * @param wrHasWrRdCnt  Set to true if write count and read count are needed
 *                      in write side
 * @param rdHasWrRdCnt  Set to true if write count and read count are needed
 *                      in read side
 * @tparam T            Type of data
 */
class DcFifo[T <: Data](gen: T, addrWidth: Int,
                        wrHasDataCnt: Boolean = false,
                        rdHasDataCnt: Boolean = false,
                        wrHasWrRdCnt: Boolean = false,
                        rdHasWrRdCnt: Boolean = false) extends RawModule {
    require(addrWidth >= 1 && addrWidth < 64, "In DcFifo, addrWidth must be in [1, 63]")
    require(!(!wrHasDataCnt && wrHasWrRdCnt), "In DcFifo, when wrHasDataCnt == false, wrHasWrRdCnt is not allowed to be true!")
    require(!(!rdHasDataCnt && rdHasWrRdCnt), "In DcFifo, when rdHasDataCnt == false, rdHasWrRdCnt is not allowed to be true!")

    override def desiredName: String = super.desiredName + s"_${(1<<addrWidth)}_x_${gen.typeName}"

    val io = IO(new Bundle {
        val wrClock = Input(Clock())
        val rdClock = Input(Clock())
        val wrReset = Input(Bool())
        val rdReset = Input(Bool())
        val w = FifoIO.Writee(gen)
        val wcnt = if(wrHasDataCnt) Some(FifoIO.CntProvider(addrWidth, wrHasWrRdCnt))
                   else None
        val r = FifoIO.Readee(gen)
        val rcnt = if(rdHasDataCnt) Some(FifoIO.CntProvider(addrWidth, rdHasWrRdCnt))
                   else None
    })
    val m: BigInt = 1 << addrWidth
    val capacity: BigInt = m - 1

    val ccd_wr_cnt = CcdCounter(io.wrClock, io.rdClock,
                                io.wrReset, io.rdReset)(addrWidth, io.w.write)
    val ccd_rd_cnt = CcdCounter(io.rdClock, io.wrClock,
                                io.rdReset, io.wrReset)(addrWidth, io.r.read)

    val sdc_ram = SyncReadMem(m, gen)
    when(io.w.write) { sdc_ram.write(ccd_wr_cnt.cnt_from(), io.w.data, io.wrClock) }
    val qout_b = sdc_ram.read(ccd_rd_cnt.cnt_from(), io.rdClock)

    withClockAndReset(io.rdClock, io.rdReset) {
        val rd_dly = RegNext(io.r.read, false.B)
        val qout_b_reg = RegEnable(qout_b, 0.U.asTypeOf(gen), rd_dly)
        io.r.data := Mux(rd_dly, qout_b, qout_b_reg)
    }

    val w_data_cnt = ccd_wr_cnt.cnt_from() - ccd_rd_cnt.cnt_to()
    io.w.full     := w_data_cnt === capacity.U
    val r_data_cnt = ccd_wr_cnt.cnt_to() - ccd_rd_cnt.cnt_from()
    io.r.empty    := r_data_cnt === 0.U

    io.wcnt.foreach(wc => {
        wc.dataCnt := w_data_cnt
        wc.writeCnt.foreach(_ := ccd_wr_cnt.cnt_from())
        wc.readCnt.foreach(_ := ccd_rd_cnt.cnt_to())
    })
    io.rcnt.foreach(rc => {
        rc.dataCnt := r_data_cnt
        rc.writeCnt.foreach(_ := ccd_wr_cnt.cnt_to())
        rc.readCnt.foreach(_ := ccd_rd_cnt.cnt_from())
    })
}

/*
object DcFifo {
    /**
     * Create an instance of DcFifo.
     *
     * @param gen          Generator of data
     * @param addrWidth    Width in bits of the inner address,
     *                     fifo depth = 2**addrWidth - 1
     * @param wrHasDataCnt Set to true if data count is needed in write side
     * @param rdHasDataCnt Set to true if data count is needed in read side
     * @param wrHasWrRdCnt Set to true if write count and read count are needed
     *                     in write side
     * @param rdHasWrRdCnt Set to true if write count and read count are needed
     *                     in read side
     * @tparam T Type of data
     * @return The instance created
     * @example {{{
     *              val dcfifo = DcFifo(UInt(32.W), 10, true, true)
     *              dcfifo.wrClock := clk_wr
     *              dcfifo.rdClock := clk_rd
     *              dcfifo.wrReset := rst_wr
     *              dcfifo.rdReset := rst_rd
     *              io.fifo_wr <> dcfifo.w
     *              io.fifo_rd <> dcfifo.r
     *              io.fifo_wrcnt <> dcfifo.wcnt.get
     *              io.fifo_rdcnt <> dcfifo.rcnt.get
     * }}}
     */
    def apply[T <: Data](gen: T, addrWidth: Int,
                         wrHasDataCnt: Boolean = false, rdHasDataCnt: Boolean = false,
                         wrHasWrRdCnt: Boolean = false, rdHasWrRdCnt: Boolean = false): DcFifo[T] = {
        Module(new DcFifo(gen, addrWidth,
            wrHasDataCnt, rdHasDataCnt,
            wrHasWrRdCnt, rdHasWrRdCnt))
    }
}
 */

package examples {
    class anti_metastable_example extends Module {
        val io = IO(new Bundle {
            val in0 = Input(UInt(8.W))
            val out0 = Output(UInt(8.W))
            val in1 = Input(UInt(4.W))
            val out1 = Output(UInt(4.W))
        })
        val ams = AntiMetastable(UInt(8.W), 3)()
        io.out0 := ams.input(io.in0)
        io.out1 := AntiMetastable._2ff(io.in1)(
            Some(() => {
                ~0.U.asTypeOf(io.in1)
            })
        )
    }

    class edge2en_example extends Module {
        val io = IO(new Bundle {
            val in = Input(Bool())
            val out = Output(Bool())
            val rising = Output(Bool())
            val falling = Output(Bool())
        })
        val (r, f, o) = Edge2En(io.in, true)
        io.rising := r
        io.falling := f
        io.out := o
    }

    class ccd_trigger_example extends RawModule {
        val io = IO(new Bundle {
            val clk_a = Input(Clock())
            val clk_b = Input(Clock())
            val rst_a = Input(Bool())
            val rst_b = Input(Bool())
            val trig_in = Input(Bool())
            val trig_out = Output(Bool())
        })
        io.trig_out := CcdTrigger(io.clk_a, io.clk_b, io.rst_a, io.rst_b)(io.trig_in)
    }

    class ccd_counter_example extends RawModule {
        val io = IO(new Bundle {
            val clk_a = Input(Clock())
            val clk_b = Input(Clock())
            val rst_a = Input(Bool())
            val rst_b = Input(Bool())
            val inc_a = Input(Bool())
            val cnt_a = Output(UInt(8.W))
            val cnt_b = Output(UInt(8.W))
        })
        val ccdcnt = CcdCounter(io.clk_a, io.clk_b, io.rst_a, io.rst_b)(8, io.inc_a)
        io.cnt_a := ccdcnt.cnt_from()
        io.cnt_b := ccdcnt.cnt_to()
    }

    class dcfifo_example extends RawModule {
        val dType = UInt(32.W)
        val aw = 10
        val w_has_dc = true
        val r_has_dc = true
        val w_has_wrc = false
        val r_has_wrc = false
        val io = FlatIO(new Bundle {
            val clk_wr = Input(Clock())
            val clk_rd = Input(Clock())
            val reset_wr = Input(Bool())
            val reset_rd = Input(Bool())
            val w = FifoIO.Writee(dType)
            val wc = if (w_has_dc) Some(FifoIO.CntProvider(aw, w_has_wrc)) else None
            val r = FifoIO.Readee(dType)
            val rc = if (r_has_dc) Some(FifoIO.CntProvider(aw, r_has_wrc)) else None
        })
        val dcfifo = Module(new DcFifo(dType, aw, w_has_dc, r_has_dc, w_has_wrc, r_has_wrc))
        io.clk_wr <> dcfifo.io.wrClock
        io.clk_rd <> dcfifo.io.rdClock
        io.reset_wr <> dcfifo.io.wrReset
        io.reset_rd <> dcfifo.io.rdReset
        io.w <> dcfifo.io.w
        io.r <> dcfifo.io.r
        if (w_has_dc)
            io.wc.get <> dcfifo.io.wcnt.get
        if (r_has_dc)
            io.rc.get <> dcfifo.io.rcnt.get
    }
}
