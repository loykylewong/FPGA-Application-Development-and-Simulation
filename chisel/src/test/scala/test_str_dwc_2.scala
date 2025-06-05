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

// package test_str_data_width_converter_2
package test_str_dwc_2

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers._
import loywong._
import loywong.util._
import loywongtest._


object SimSettings {
    val nPkgs = 2
    object Us {
        val nBytesPerBeat = 6
        val nBeats = 400
        val randomValid = true
        val validInterval = 1.0   // if random, it's the poisson lambda
        val keepDensity = 0.8
        val strbDensity = 0.5
        val nRawBytes = nBytesPerBeat * nBeats
        val nKeepBytes = math.round(keepDensity * nRawBytes).toInt
        val dataWidth = nBytesPerBeat * 8
        val strbWidth = nBytesPerBeat
        val keepWidth = nBytesPerBeat
        val idWidth = 4
        val destWidth = 8
        // val userUnitWidth = 4
        // val userWidth = userUnitWidth * nBytesPerBeat
        val userWidth = 16
        class Bits extends StrHasStrb with StrHasKeep with StrHasLast with StrHasId with StrHasDest with StrHasUser {
            override lazy val data: UInt = UInt(dataWidth.W)
            override lazy val strb: UInt = UInt(strbWidth.W)
            override lazy val keep: UInt = UInt(keepWidth.W)
            override val last: Bool = Bool()
            override val id: UInt = UInt(idWidth.W)
            override val dest: UInt = UInt(destWidth.W)
            override val user: UInt = UInt(userWidth.W)
            override val userAssociation: StrUserAssociation.Value = StrUserAssociation.LowestByte
        }
    }
    
    object Ds {
        val nBytesPerBeat = 4
        val nBeats = 600
        val randomReady = true
        val readyInterval = 1.0   // if random, it's the poisson lambda
        val nRawBytes = nBytesPerBeat * nBeats
        val dataWidth = nBytesPerBeat * 8
        val strbWidth = nBytesPerBeat
        val keepWidth = nBytesPerBeat
        val idWidth = 4
        val destWidth = 8
        // val userUnitWidth = 4
        // val userWidth = userUnitWidth * nBytesPerBeat
        val userWidth = 16
        class Bits extends StrHasStrb with StrHasKeep with StrHasLast with StrHasId with StrHasDest with StrHasUser {
            override lazy val data: UInt = UInt(dataWidth.W)
            override lazy val strb: UInt = UInt(strbWidth.W)
            override lazy val keep: UInt = UInt(keepWidth.W)
            override val last: Bool = Bool()
            override val id: UInt = UInt(idWidth.W)
            override val dest: UInt = UInt(destWidth.W)
            override val user: UInt = UInt(userWidth.W)
            override val userAssociation: StrUserAssociation.Value = StrUserAssociation.LowestByte
        }
    }
    require(Us.nRawBytes == Ds.nRawBytes)
}

class StrDutWrapper extends Module {
    import SimSettings._
    
    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(new Us.Bits))
        val ds = Irrevocable(new Ds.Bits)
    })

    //==== actual DUT ====
    val dut = Module(new StrDataWidthConverter(new Us.Bits, new Ds.Bits/*, userAssociation = StrUserAssociation.LowestByte*/))

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
          | Test Stream Data Width Converter with:
          |  * keep, DWC does not deal with it
          |  * strb, associated with bytes
          |  * last, associated with highest byte
          |  * id, associated with lowest byte
          |  * dest, associated with lowest byte
          |  * user, associated with lowest byte
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
                val snk = new StrTestSink(dut.clock, dut.io.ds)
                snk.setThrottle(Ds.randomReady, Ds.readyInterval)

                dut.reset.poke(true.asBool)
                dut.clock.step(1)
                dut.reset.poke(false.asBool)
                dut.clock.step(1)
                
                var totalErr = 0
                var lastClock = 0L
                for(p <- 0 until nPkgs) {
                    
                    val txBytes = src.randomBytes(Us.nKeepBytes)
                    val txBStrbs = src.randomBStrbs(Us.nKeepBytes, 1.0)
                    // val txBUsers = src.randomBUsers(Us.nKeepBytes)
                    val (txData, txStrb, txKeep, _) = src.convertBytesToBeats(Us.nBeats, txBytes, txBStrbs)
                    val usMinBeatsUnit = LCM(Us.nBytesPerBeat, Ds.nBytesPerBeat) / Us.nBytesPerBeat
                    val txIds = src.randomIds(Us.nBeats, immutablePeriod = usMinBeatsUnit)
                    val txDests = src.randomDests(Us.nBeats, immutablePeriod = usMinBeatsUnit)
                    val txUsers = src.randomUsers(Us.nBeats, immutablePeriod = usMinBeatsUnit)
                    
                    val txThr = src.sendBeats(genLastAtLastBeat = true, txData, txStrb, txKeep, txIds, txDests, txUsers)
                    val rxThr = snk.recvBeatsToLast()
                    
                    txThr.join()
                    rxThr.join()
                    
                    dut.clock.step()
                    
                    // ---- use StrMonitorSignals.printSignals ----
                    for (i <- 0L until math.max(src.totalClocks, snk.totalClocks)) {
                        val srcStr = src.signalStringOfClock(i)
                        val snkStr = snk.signalStringOfClock(i)
                        if (srcStr(0) != ' ' || snkStr(0) != ' ') {
                            val clkInc = i - lastClock
                            println(f"clk+${clkInc}%02d=${i}%04d: pkg${p}%02d: ${srcStr} --> ${snkStr}")
                            lastClock = i
                        }
                    }
                    println("------------------------------------------------")
                    
                    // ---- check bytes ----
                    val byteErrCnt = snk.checkByteSeq(txBytes)
                    val bStrbErrCnt = snk.checkBStrbSeq(txBStrbs)
                    val bIdErrCnt = snk.checkBIdSeq(src.bIdSeq)
                    val bDestErrCnt = snk.checkBDestSeq(src.bDestSeq)
                    val bUserErrCnt = snk.checkBUserSeq(src.bUserSeq)
                    println(s"Error Bytes  in Pkg${p}: ${byteErrCnt}")
                    println(s"Error BStrbs in Pkg${p}: ${bStrbErrCnt}")
                    println(s"Error BIds   in Pkg${p}: ${bIdErrCnt}")
                    println(s"Error BDests in Pkg${p}: ${bDestErrCnt}")
                    println(s"Error BUsers in Pkg${p}: ${bUserErrCnt}")
                    println("------------------------------------------------")
                    totalErr += (byteErrCnt + bStrbErrCnt + bIdErrCnt + bDestErrCnt + bUserErrCnt)
                    snk.byteSeq should be(txBytes)
                    snk.bStrbSeq should be(txBStrbs)
                    snk.bIdSeq should be(src.bIdSeq)
                    snk.bDestSeq should be(src.bDestSeq)
                    snk.bUserSeq should be(src.bUserSeq)
                }
                println(s"\u001b[1mTotal Error: ${totalErr}\u001b[0m")
                totalErr should be (0)
                println("================================================")
                Thread.sleep(1000)
            }
        }
    }
}
