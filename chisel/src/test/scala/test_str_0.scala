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

package test_str_0

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
        val nBytesPerBeat = 4
        val nBeats = 500
        val randomValid = true
        val validInterval = 1.0   // if random, it's the poisson lambda
        // val keepDensity = 0.7
        val nRawBytes = nBytesPerBeat * nBeats
        // val nKeepBytes = math.round(keepDensity * nRawBytes).toInt
        val dataWidth = nBytesPerBeat * 8
        val strbWidth = nBytesPerBeat
        val keepWidth = nBytesPerBeat
        // val idWidth = 4
        // val destWidth = 8
        // val userUnitWidth = 4
        // val userWidth = userUnitWidth * nBytesPerBeat
        class Bits extends StrHasData with StrHasLast {
            override lazy val data: UInt = UInt(dataWidth.W)
            override val last: Bool = Bool()
        }
    }
    object Ds {
        val nBytesPerBeat = 4
        val nBeats = 500
        val randomReady = true
        val readyInterval = 1.0   // if random, it's the poisson lambda
        val nRawBytes = nBytesPerBeat * nBeats
        val dataWidth = nBytesPerBeat * 8
        val strbWidth = nBytesPerBeat
        val keepWidth = nBytesPerBeat
        // val idWidth = 4
        // val destWidth = 8
        // val userUnitWidth = 4
        // val userWidth = userUnitWidth * nBytesPerBeat
        class Bits extends StrHasData with StrHasLast {
            override lazy val data: UInt = UInt(dataWidth.W)
            override val last: Bool = Bool()
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
    val dut = Module(new StrFifo(new Us.Bits, 8))

    /**
     * birs for eliminate ready comb which may cause
     * "Unordered poke after peek" runtime error.
     */
    val birs = Module(new StrBirs(new Ds.Bits))

    io.us <> dut.io.us
    dut.io.ds <> birs.io.us
    // birs.io.us.bits.data := dut.io.ds.bits.data | 1.U  // make some troubles
    birs.io.ds <> io.ds
}

class test extends AnyFlatSpec with ChiselScalatestTester {
    import SimSettings._
    println()
    println("==============================")
    println("Test Basic Stream Component...")
    println("------------------------------")
    
    "DUT" should "pass" in {
        test(new StrDutWrapper)/*.withAnnotations(Seq(VerilatorBackendAnnotation))*/ {
            dut => {

                // --- test something else ...
                val a = GCD(16, 14)
                val bs: Seq[Byte] = Seq(
                    0x01.toByte,
                    0xff.toByte,
                    0x02.toByte,
                    0xfe.toByte,
                    0x03.toByte,
                    0xfd.toByte,
                    0x04.toByte,
                    0xfc.toByte,
                    0x05.toByte,
                    0xfb.toByte,
                    0x06.toByte
                )
                var u8 = 0
                u8 = bs.asU8(0)
                u8 = bs.asU8(1)
                var s8 = 0
                s8 = bs.asS8(0)
                s8 = bs.asS8(1)
                var u16 = 0
                u16 = bs.asU16(0)
                u16 = bs.asU16(1)
                u16 = bs.asU16(0, true)
                u16 = bs.asU16(1, true)
                var s16 = 0
                s16 = bs.asS16(0)
                s16 = bs.asS16(1)
                s16 = bs.asS16(0, true)
                s16 = bs.asS16(1, true)
                var u32 = 0L
                u32 = bs.asU32(0)
                u32 = bs.asU32(1)
                u32 = bs.asU32(0, true)
                u32 = bs.asU32(1, true)
                var s32 = 0
                s32 = bs.asS32(0)
                s32 = bs.asS32(1)
                s32 = bs.asS32(0, true)
                s32 = bs.asS32(1, true)
                var u64 = BigInt(0)
                u64 = bs.asU64(0)
                u64 = bs.asU64(1)
                u64 = bs.asU64(0, true)
                u64 = bs.asU64(1, true)
                var s64 = 0L
                s64 = bs.asS64(0)
                s64 = bs.asS64(1)
                s64 = bs.asS64(0, true)
                s64 = bs.asS64(1, true)
                var u80 = BigInt(0)
                u80 = bs.asUInt(0, 80)
                u80 = bs.asUInt(1, 80)
                u80 = bs.asUInt(0, 80, true)
                u80 = bs.asUInt(1, 80, true)
                var s80 = BigInt(0)
                s80 = bs.asSInt(0, 80)
                s80 = bs.asSInt(1, 80)
                s80 = bs.asSInt(0, 80, true)
                s80 = bs.asSInt(1, 80, true)
                // ----
                
                val src = new StrTestSource(dut.clock, dut.io.us)
                src.setThrottle(Us.randomValid, Us.validInterval)
                val snk = new StrTestSink(dut.clock, dut.io.ds)
                src.setThrottle(Ds.randomReady, Ds.readyInterval)

                dut.reset.poke(true.asBool)
                dut.clock.step(1)
                dut.reset.poke(false.asBool)
                dut.clock.step(1)
                
                var totalErr = 0
                var lastClock = 0L
                for(p <- 0 until nPkgs) {
                    
                    val data = src.randomData(Us.nBeats)
                    val txThr = src.sendBeats(dut.io.us.bits.hasLast, data)
                    
                    val rxThr =
                        if (dut.io.ds.bits.hasLast)
                            snk.recvBeatsToLast()
                        else
                            snk.recvBeats(Ds.nBeats)
                    
                    txThr.join()
                    rxThr.join()
                    
                    dut.clock.step(1)
                    
                    // var errCnt = 0
                    // for(i <- 0 until SimSettings.dsBeats) {
                    //     print(f"[#${i}%04d] tx gapped ${txGaps(i)}%3d cycles, sent  :")
                    //     for(j <- 0 until SimSettings.usBytesPerBeat) {
                    //         val bi = i * SimSettings.usBytesPerBeat + j
                    //         print(f" ${txBytes(bi)}%02x")
                    //     }
                    //     println()
                    //     print(f"[#${i}%04d] rx gapped ${rxGaps(i)}%3d cycles, recved:")
                    //     for(j <- 0 until SimSettings.dsBytesPerBeat) {
                    //         val bi = i * SimSettings.dsBytesPerBeat + j
                    //         print(f" ${recvBytes(bi)}%02x")
                    //     }
                    //     println()
                    //     print(f"[#${i}%04d]                  rx data ref:")
                    //     for(j <- 0 until SimSettings.dsBytesPerBeat) {
                    //         val bi = i * SimSettings.dsBytesPerBeat + j
                    //         print(f" ${rxBytesRef(bi)}%02x")
                    //     }
                    //     println()
                    //     println()
                    // }
                    
                    // ---- use StrMonitorSignals.printSignals ----
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
                    val errCnt = snk.checkDataSeq(src.dataSeq)
                    println(s"Error Beats in Pkg${p}: ${errCnt}")
                    println("------------------------------------------------")
                    totalErr += errCnt
                    
                    snk.dataSeq should be(src.dataSeq)
                }
                println(s"\u001b[1mTotal Error: ${totalErr}\u001b[0m")
                totalErr should be (0)
                println("================================================")
                Thread.sleep(1000)
            }
        }
    }
}
