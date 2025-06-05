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

// package test_str_data_width_converter_0
package test_str_dwc_0

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
        val nBytesPerBeat = 7
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
        val nBytesPerBeat = 5
        val nBeats = 700
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
    val dut = Module(new StrDataWidthConverter(new Us.Bits, new Ds.Bits))

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
    println(
        """
          |=============================================
          | Test Stream Keep Remover with data and last
          |---------------------------------------------""".stripMargin)
    
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
                for (p <- 0 until nPkgs) {
                    
                    val txBytes = src.randomBytes(Us.nRawBytes)
                    val (data, _, _, _) = src.convertBytesToBeats(0, txBytes)
                    val txThr = src.sendBeats(dut.io.us.bits.hasLast, data)
                    val rxThr = {
                        if (dut.io.ds.bits.hasLast) {
                            snk.recvBeatsToLast()
                        } else {
                            snk.recvBeats(Ds.nBeats)
                        }
                    }
                    
                    txThr.join()
                    rxThr.join()
                    
                    dut.clock.step()
                    
                    // var errCnt = 0
                    // var i = 0;
                    // val txDHW = SimSettings.usBytesPerBeat * 2
                    // val txKHW = if(dut.io.us.bits.strKeepWidth > 0) (SimSettings.usBytesPerBeat - 1) / 4 + 1 else 0
                    // val rxDHW = SimSettings.dsBytesPerBeat * 2
                    // val rxKHW = if(dut.io.ds.bits.strKeepWidth > 0) (SimSettings.dsBytesPerBeat - 1) / 4 + 1 else 0
                    // val txFormat = f"%%3d %%0${txDHW}x" + {
                    //     if (dut.io.us.bits.strKeepWidth > 0) f" %%0${txKHW}x"
                    //     else ""
                    // } + {
                    //     if (dut.io.us.bits.strHasLast) f" %%1d"
                    //     else ""
                    // }
                    // val rxFormat = f"%%3d %%0${rxDHW}x" + {
                    //     if (dut.io.ds.bits.strKeepWidth > 0) f" %%0${rxKHW}x"
                    //     else ""
                    // } + {
                    //     if (dut.io.ds.bits.strHasLast) f" %%1d"
                    //     else ""
                    // }
                    // println("------------------------------------------------")
                    // println("#beat: gap data" +
                    //         s"${if (dut.io.us.bits.strKeepWidth > 0) " keep" else ""}" +
                    //         s"${if (dut.io.us.bits.strHasLast) " last" else ""}" +
                    //         " --> gap data" +
                    //         s"${if (dut.io.ds.bits.strKeepWidth > 0) " keep" else ""}" +
                    //         s"${if (dut.io.ds.bits.strHasLast) " last" else ""}")
                    // println("------------------------------------------------")
                    // for (i <- 0 until math.max(sentData.length, recvData.length)) {
                    //     print(f"#${i}%04d: ")
                    //     if (i < sentData.length) {
                    //         if(dut.io.us.bits.strKeepWidth > 0) {
                    //             if(dut.io.us.bits.strHasLast) {
                    //                 print(txFormat.format(txGaps(i), sentData(i), sentKeep(i), if (sentLast(i)) 1 else 0))
                    //             } else {
                    //                 print(txFormat.format(txGaps(i), sentData(i), sentKeep(i)))
                    //             }
                    //         } else {
                    //             if(dut.io.us.bits.strHasLast) {
                    //                 print(txFormat.format(txGaps(i), sentData(i), if (sentLast(i)) 1 else 0))
                    //             } else {
                    //                 print(txFormat.format(txGaps(i), sentData(i)))
                    //             }
                    //         }
                    //     }
                    //     else {
                    //         print("      ")
                    //         (0 until txDHW + txKHW).foreach((i) => {
                    //             print(" ")
                    //         })
                    //     }
                    //     print(" --> ")
                    //     if (i < recvData.length) {
                    //         if(dut.io.ds.bits.strKeepWidth > 0) {
                    //             if(dut.io.ds.bits.strHasLast) {
                    //                 print(rxFormat.format(rxGaps(i), recvData(i), recvKeep(i), if (recvLast(i)) 1 else 0))
                    //             } else {
                    //                 print(rxFormat.format(rxGaps(i), recvData(i), recvKeep(i)))
                    //             }
                    //         } else {
                    //             if(dut.io.ds.bits.strHasLast) {
                    //                 print(rxFormat.format(rxGaps(i), recvData(i), if (recvLast(i)) 1 else 0))
                    //             } else {
                    //                 print(rxFormat.format(rxGaps(i), recvData(i)))
                    //             }
                    //         }
                    //     }
                    //     else {
                    //         print("       ")
                    //         (0 until rxDHW + rxKHW).foreach((i) => {
                    //             print(" ")
                    //         })
                    //     }
                    //     println()
                    // }
                    // println("------------------------------------------------")
                    
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
                    val errCnt = snk.checkByteSeq(txBytes)
                    println(s"Error Bytes in Pkg${p}: ${errCnt}")
                    println("------------------------------------------------")
                    totalErr += errCnt
                    
                    snk.byteSeq should be(txBytes)
                }
                println(s"\u001b[1mTotal Error: ${totalErr}\u001b[0m")
                totalErr should be (0)
                println("================================================")
                Thread.sleep(1000)
            }
        }
    }
}
