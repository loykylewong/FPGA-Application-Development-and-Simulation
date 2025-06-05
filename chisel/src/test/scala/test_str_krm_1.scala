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

// package test_str_keep_remover_1
package test_str_krm_1

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers._
import loywong._
import loywong.util._
import loywongtest._


object SimSettings {
    val nPkgs = 4
    object Us {
        val nBytesPerBeat = 8
        val nBeats = 600
        val randomValid = false
        val validInterval = 0.0   // if random, it's the poisson lambda
        val keepDensity = 0.7
        val nRawBytes = nBytesPerBeat * nBeats
        val nKeepBytes = math.round(keepDensity * nRawBytes).toInt
        val dataWidth = nBytesPerBeat * 8
        val strbWidth = nBytesPerBeat
        val keepWidth = nBytesPerBeat
        val idWidth = 4
        val destWidth = 8
        val userUnitWidth = 4
        val userWidth = userUnitWidth * nBytesPerBeat
        class Bits extends StrHasStrb with StrHasKeep with StrHasLast with StrHasId with StrHasDest with StrHasUser {
            override lazy val data: UInt = UInt(dataWidth.W)
            override lazy val strb: UInt = UInt(strbWidth.W)
            override lazy val keep: UInt = UInt(keepWidth.W)
            override val last: Bool = Bool()
            override val id: UInt = UInt(idWidth.W)
            override val dest: UInt = UInt(destWidth.W)
            override val user: UInt = UInt(userWidth.W)
        }
    }
    
    object Ds {
        val nBytesPerBeat = 6
        // val nBeats = 1000
        val randomReady = false
        val readyInterval = 0.0   // if random, it's the poisson lambda
        // val nRawBytes = nBytesPerBeat * nBeats
        val dataWidth = nBytesPerBeat * 8
        val strbWidth = nBytesPerBeat
        val keepWidth = nBytesPerBeat
        val idWidth = 4
        val destWidth = 8
        val userUnitWidth = 4
        val userWidth = userUnitWidth * nBytesPerBeat
        class Bits extends StrHasStrb /*with StrHasKeep*/ with StrHasLast with StrHasId with StrHasDest with StrHasUser {
            override lazy val data: UInt = UInt(dataWidth.W)
            override lazy val strb: UInt = UInt(strbWidth.W)
            // override lazy val keep: UInt = UInt(keepWidth.W)
            override val last: Bool = Bool()
            override val id: UInt = UInt(idWidth.W)
            override val dest: UInt = UInt(destWidth.W)
            override val user: UInt = UInt(userWidth.W)
        }
    }
}

class StrDutWrapper extends Module {
    import SimSettings._
    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(new Us.Bits))
        val ds = Irrevocable(new Ds.Bits)
    })

    //==== actual DUT ====
    val dut = Module(new StrKeepRemover(new Us.Bits, new Ds.Bits))

    /**
     * birs for eliminate ready comb which may cause
     * "Unordered poke after peek" runtime error.
     */
    val birs = Module(new StrBirs(new Ds.Bits))

    io.us <> dut.io.us
    dut.io.ds <> birs.io.us
    // birs.io.us.bits.data := dut.io.ds.bits.data | 1.U   // make some troubles
    // birs.io.us.bits.strb := dut.io.ds.bits.strb | 1.U   // make some troubles
    // birs.io.us.bits.keep := dut.io.ds.bits.keep | 1.U   // make some troubles
    // birs.io.us.bits.user := dut.io.ds.bits.user | 1.U   // make some troubles
    birs.io.ds <> io.ds
}

class test extends AnyFlatSpec with ChiselScalatestTester {
    import SimSettings._
    println(
        """
          |========================================
          | Test Stream Keep Remover with:
          |  * keep in us, no keep in ds
          |  * strb, associated with bytes
          |  * last, associated with highest byte
          |  * id, associated with lowest byte
          |  * dest, associated with lowest byte
          |  * user, associated with bytes
          |----------------------------------------""".stripMargin)

    val shouldUseVerilator =
        if (System.getProperty("os.name").toLowerCase.contains("win"))
            Seq.empty[firrtl2.annotations.Annotation]
        else
            Seq(VerilatorBackendAnnotation)

    "DUT" should "pass" in {
        test(new StrDutWrapper).withAnnotations(
            shouldUseVerilator/* ++ Seq(WriteVcdAnnotation)*/
        ) {
            dut => {

                val src = new StrTestSource(dut.clock, dut.io.us)
                src.setThrottle(Us.randomValid, Us.validInterval)
                dut.clock.setTimeout(10000) // for lower random keep density

                val snk = new StrTestSink(dut.clock, dut.io.ds)
                snk.setThrottle(Ds.randomReady, Ds.readyInterval)

                dut.reset.poke(true.asBool)
                dut.clock.step(1)
                dut.reset.poke(false.asBool)
                dut.clock.step(1)
                
                var totalErr = 0
                for (p <- 0 until nPkgs) {
                    // ---- use random data ----
                    val txBytes = src.randomBytes(Us.nKeepBytes)
                    val txBStrbs = src.randomBStrbs(Us.nKeepBytes, 0.5)
                    val txBUsers = src.randomBUsers(Us.nKeepBytes)
                    val (txData, txStrbs, txKeeps, txUsers) = src.convertBytesToBeats(Us.nBeats, txBytes, txBStrbs, txBUsers)
                    val txIds = src.randomIds(Us.nBeats, immutablePeriod = Us.nBeats)
                    val txDests = src.randomDests(Us.nBeats, immutablePeriod = Us.nBeats)
                    
                    val txThr = src.sendBeats(genLastAtLastBeat = true, txData, txStrbs, txKeeps, txIds, txDests, txUsers)
                    val rxThr = snk.recvBeatsToLast()
                    
                    txThr.join()
                    rxThr.join()
                    
                    dut.clock.step(1)
                    
                    // ---- use StrMonitorSignals.printSignals ----
                    var lastClock = 0L
                    for (i <- 0L until math.max(src.totalClocks, snk.totalClocks)) {
                        val srcStr = src.signalStringOfClock(i)
                        val snkStr = snk.signalStringOfClock(i)
                        if (srcStr(0) != ' ' || snkStr(0) != ' ') {
                            val clkInc = i - lastClock
                            println(f"clk+${clkInc}%02d=${i}%04d: Pkg${p}%02d: ${srcStr} --> ${snkStr}")
                            lastClock = i
                        }
                    }
                    println("------------------------------------------------")
                    
                    // ---- check bytes ----
                    val byteErrCnt = snk.checkByteSeq(txBytes)
                    val bStrbErrCnt = snk.checkBStrbSeq(txBStrbs)
                    val bIdErrCnt = snk.checkBIdSeq(src.bIdSeq)
                    val bDestErrCnt = snk.checkBDestSeq(src.bDestSeq)
                    val bUserErrCnt = snk.checkBUserSeq(txBUsers)
                    println(s"In Pkg${p} Error Bytes : ${byteErrCnt}")
                    println(s"In Pkg${p} Error BStrbs: ${bStrbErrCnt}")
                    println(s"In Pkg${p} Error BId   : ${bIdErrCnt}")
                    println(s"In Pkg${p} Error BDest : ${bDestErrCnt}")
                    println(s"In Pkg${p} Error BUsers: ${bUserErrCnt}")
                    println("------------------------------------------------")
                    totalErr += (byteErrCnt + bStrbErrCnt + bIdErrCnt + bDestErrCnt + bUserErrCnt)
                    snk.byteSeq should be(txBytes)
                    snk.bStrbSeq should be(txBStrbs)
                    snk.bIdSeq should be(src.bIdSeq)
                    snk.bDestSeq should be(src.bDestSeq)
                    snk.bUserSeq should be(txBUsers)
                }
                println(s"\u001b[1mTotal Error: ${totalErr}\u001b[0m")
                totalErr should be (0)
                println("================================================")
                Thread.sleep(1000)
            }
        }
    }
}
