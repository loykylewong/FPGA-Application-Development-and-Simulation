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

package test_str_cordic_1

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers._
import loywong._
import loywong.util._
import loywongtest._
import org.apache.commons.math3.distribution.{UniformRealDistribution, UniformIntegerDistribution}

object SimSettings {
    val nBeats = 500
    val verbose: Boolean = nBeats <= 1000

    val randomValid = true
    val validInterval = 1.0   // if random, it's the poisson lambda
    val randomReady = true
    val readyInterval = 1.0   // if random, it's the poisson lambda

    val xyWidth = 12
    val zWidth = 12

    val userWidth = 8
}

import SimSettings._

class CordicIOBitsWithUser extends CordicIOStrBits(xyWidth, zWidth) with StrHasLast with StrHasUser {
    override val last = Bool()
    override val user = UInt(userWidth.W)
}

class CordicWrapperIOBits extends StrHasData with StrHasLast with StrHasUser {
    override val data = UInt((xyWidth.up8 * 2 + zWidth.up8).W)
    override val last = Bool()
    override val user = UInt(userWidth.up8.W)
}

class CordicWrapper(xyFW: Int, zFW: Int, coor: CordicCoordinates.Value, mode: CordicMode.Value, linStgStart: Int = 0) extends Module {
    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(new CordicWrapperIOBits))
        val ds = Irrevocable(new CordicWrapperIOBits)
    })

    val dut = Module(new Cordic(new CordicIOBitsWithUser, zWidth - 1, xyFW, zFW, coor, mode, linStgStart))

    io.us.bits.data.sliceByteWiseTo(dut.io.us.bits.z, dut.io.us.bits.y, dut.io.us.bits.x)
    io.us.bits.last <> dut.io.us.bits.last
    io.us.bits.user.sliceByteWiseTo(dut.io.us.bits.user)
    io.us.valid <> dut.io.us.valid
    io.us.ready <> dut.io.us.ready

    /**
     * birs for eliminate ready comb which may cause
     * "Unordered poke after peek" runtime error.
     */
    val brs = Module(new StrBirs(new CordicWrapperIOBits))

    brs.io.us.bits.data.catByteWiseFrom(dut.io.ds.bits.z, dut.io.ds.bits.y, dut.io.ds.bits.x)
    brs.io.us.bits.last <> dut.io.ds.bits.last
    brs.io.us.bits.user.catByteWiseFrom(dut.io.ds.bits.user)
    brs.io.us.valid <> dut.io.ds.valid
    brs.io.us.ready <> dut.io.ds.ready

    io.ds <> brs.io.ds
}

class test extends AnyFlatSpec with ChiselScalatestTester {

    val shouldUseVerilator =
        if (System.getProperty("os.name").toLowerCase.contains("win"))
            Seq.empty[firrtl2.annotations.Annotation]
        else
            Seq(VerilatorBackendAnnotation)

    "DUT Cordic Linear Rotation" should "Pass" in {
        /**
         * Functions for this test:
         *  - x := x
         *  - y := y + x * z
         *  - z := 0
         *
         * Domains of this test:
         * - x_i: (-1, 1)
         * - y_i: (-2, 2)
         * - z_i: (-2, 2)
         * - x_o: (-1, 1)
         * - y_o: (-4, 4)
         * - z_o: = 0
         */
        val xyFracWidth = xyWidth - 3
        val zFracWidth = zWidth - 2
        val xyLsb = math.pow(2.0, -xyFracWidth)
        val zLsb = math.pow(2.0, -zFracWidth)

        test(
            new CordicWrapper(xyFracWidth, zFracWidth, CordicCoordinates.Linear, CordicMode.Rotation)
        ).withAnnotations(
            shouldUseVerilator/* ++ Seq(WriteVcdAnnotation)*/
        ) {
            dut => {

                println(
                    s"""
                      |========================================================
                      | Test CORDIC Linear Rotation with ${nBeats} data ...""".stripMargin)
                
                val src = new StrTestSource(dut.clock, dut.io.us)
                src.setThrottle(randomValid, validInterval)

                val snk = new StrTestSink(dut.clock, dut.io.ds)
                snk.setThrottle(randomReady, readyInterval)

                val xRand = new UniformRealDistribution(
                    -1.0 + 16 * xyLsb, 1.0 - 16 * xyLsb
                )

                val yRand = new UniformRealDistribution(
                    -2.0 + 16 * xyLsb, 2.0 - 16 * xyLsb
                )

                val zRand = new UniformRealDistribution(
                    -2.0 + 16 * zLsb, 2.0 - 16 * zLsb
                )

                val xinSeq = Seq.fill(nBeats)(xRand.sample())
                val yinSeq = Seq.fill(nBeats)(yRand.sample())
                val zinSeq = Seq.fill(nBeats)(zRand.sample())

                val xoutRefSeq = xinSeq
                val youtRefSeq = (0 until nBeats).map(i => {
                    yinSeq(i) + xinSeq(i) * zinSeq(i)
                })
                val zoutRefSeq = Seq.fill(nBeats)(0.0)
                
                val txDataSeq = (0 until nBeats).map(i => {
                    CatByteWise(true, Seq(zWidth, xyWidth, xyWidth),
                        zinSeq(i).toFixPoint(zWidth, zFracWidth).toBigInt,
                        yinSeq(i).toFixPoint(xyWidth, xyFracWidth).toBigInt,
                        xinSeq(i).toFixPoint(xyWidth, xyFracWidth).toBigInt,
                    )
                })
                
                val txUserSeq = src.randomUsers(nBeats)

                val txThr = src.sendBeats(genLastAtLastBeat = true, dataSeq = txDataSeq, userSeq = txUserSeq)
                val rxThr = snk.recvBeatsToLast()

                txThr.join()
                rxThr.join()

                val outSeq = snk.dataSeq.map(d => d.bitSlicesByteWise(zWidth, xyWidth, xyWidth))
                val xoutSeq = outSeq.map(o => o(2).asFixPoint(xyWidth, xyFracWidth))
                val youtSeq = outSeq.map(o => o(1).asFixPoint(xyWidth, xyFracWidth))
                val zoutSeq = outSeq.map(o => o(0).asFixPoint(zWidth, zFracWidth))

                if(verbose) {
                    println("--------------------------------------------------------")
                    var lastClock = 0L
                    for (i <- 0L until math.max(src.totalClocks, snk.totalClocks)) {
                        val srcStr = src.signalStringOfClock(i)
                        val snkStr = snk.signalStringOfClock(i)
                        if (srcStr(0) != ' ' || snkStr(0) != ' ') {
                            val clkInc = i - lastClock
                            println(f"clk+${clkInc}%02d=${i}%04d: ${srcStr} --> ${snkStr}")
                            lastClock = i
                        }
                    }
                    println("--------------------------------------------------------")
                    for (i <- 0 until nBeats) {
                        print(f"beat_${i}%04d: ")
                        print(f"(${xinSeq(i)}%6.3f, ${yinSeq(i)}%6.3f, ${zinSeq(i)}%6.3f) --> ")
                        println(f"(${xoutRefSeq(i)}%6.3f, ${youtRefSeq(i)}%6.3f, ${zoutRefSeq(i)}%6.3f)")
                        print("                                    ")
                        println(f"got (${xoutSeq(i)}%6.3f, ${youtSeq(i)}%6.3f, ${zoutSeq(i)}%6.3f)")
                        println()
                    }
                }

                println("--------------------------------------------------------")
                val xerr = elemWiseDiff(xoutSeq, xoutRefSeq)
                val yerr = elemWiseDiff(youtSeq, youtRefSeq)
                val zerr = elemWiseDiff(zoutSeq, zoutRefSeq)
                val (xm, xmi, xr) = maxAndRms(xerr)
                val (ym, ymi, yr) = maxAndRms(yerr)
                val (zm, zmi, zr) = maxAndRms(zerr)
                val (xmLsb, xrLsb) = (xm / xyLsb, xr / xyLsb)
                val (ymLsb, yrLsb) = (ym / xyLsb, yr / xyLsb)
                val (zmLsb, zrLsb) = (zm / zLsb, zr / zLsb)

                println(f"Error of x: Max Abs = ${xm}%8.6f(${xmLsb}%4.2fLSB, @${xmi}%03d), Std Dev = ${xr}%8.6f(${xrLsb}%4.2fLSB)")
                println(f"Error of y: Max Abs = ${ym}%8.6f(${ymLsb}%4.2fLSB, @${ymi}%03d), Std Dev = ${yr}%8.6f(${yrLsb}%4.2fLSB)")
                println(f"Error of z: Max Abs = ${zm}%8.6f(${zmLsb}%4.2fLSB, @${zmi}%03d), Std Dev = ${zr}%8.6f(${zrLsb}%4.2fLSB)")

                val inMaxAbsLimit = (xmLsb < 2 && ymLsb < 20 && zmLsb < 10)
                inMaxAbsLimit should be (true)
                val inStdDevLimit = (xrLsb < 1 && yrLsb < 4 && zrLsb < 2)
                inStdDevLimit should be (true)

                println("--------------------------------------------------------")
                println(s"\u001b[1mErrors Meets Spec: ${if (inMaxAbsLimit && inStdDevLimit) "YES" else "NO"}\u001b[0m")
                println("========================================================")
                Thread.sleep(1000)
            }
        }
    }
    
    "DUT Cordic Linear Vectoring" should "PASS" in {
        /**
         * Functions for this test:
         *  - x := x
         *  - y := 0
         *  - z := z + y / x
         *
         * Domains of this test:
         * - x_i: (-1, 1), except [-1/8, 1/8]
         * - y_i: (-1, 1)
         * - z_i: (-8, 8)
         * - x_o: (-1, 1)
         * - y_o = 0
         * - z_o: (-16, 16)
         */
        val xyFracWidth = xyWidth - 3
        val zFracWidth = zWidth - 5
        val xyLsb = math.pow(2.0, -xyFracWidth)
        val zLsb = math.pow(2.0, -zFracWidth)
        
        test(
            // stage Idx start from -2, for extend z range from abs(y/x) < 2 to abs(y/x) < 8,
            // meanwhile, x & y width must cover max{x_in, y_in} * 2^2, x_out, y_out}
            new CordicWrapper(xyFracWidth, zFracWidth, CordicCoordinates.Linear, CordicMode.Vectoring, -2)
        ).withAnnotations(
            shouldUseVerilator/* ++ Seq(WriteVcdAnnotation)*/
        ) {
            dut => {
                
                println(
                    s"""
                      |========================================================
                      | Test CORDIC Linear Vectoring with ${nBeats} data ...""".stripMargin)
                
                val src = new StrTestSource(dut.clock, dut.io.us)
                src.setThrottle(randomValid, validInterval)
                
                val snk = new StrTestSink(dut.clock, dut.io.ds)
                snk.setThrottle(randomReady, readyInterval)

                val xAbsRand = new UniformRealDistribution(
                    1.0 / 8, 1.0 - 16 * xyLsb
                )
                val xSignRand = new UniformIntegerDistribution(0, 1)

                val yRand = new UniformRealDistribution(
                    -1.0 + 16 * xyLsb, 1.0 - 16 * xyLsb
                )

                val zRand = new UniformRealDistribution(
                    -8.0 + 16 * zLsb, 8.0 - 16 * zLsb
                )

                val xinSeq = Seq.fill(nBeats)(xAbsRand.sample() * (if (xSignRand.sample() == 1) 1.0 else -1.0))
                val yinSeq = Seq.fill(nBeats)(yRand.sample())
                val zinSeq = Seq.fill(nBeats)(zRand.sample())
                
                val xoutRefSeq = xinSeq.map(_.abs)
                val youtRefSeq = Seq.fill(nBeats)(0.0)
                val zoutRefSeq = (0 until nBeats).map(i => {
                    zinSeq(i) + yinSeq(i) / xinSeq(i)
                })
                
                val txDataSeq = (0 until nBeats).map(i => {
                    CatByteWise(true, Seq(zWidth, xyWidth, xyWidth),
                        zinSeq(i).toFixPoint(zWidth, zFracWidth).toBigInt,
                        yinSeq(i).toFixPoint(xyWidth, xyFracWidth).toBigInt,
                        xinSeq(i).toFixPoint(xyWidth, xyFracWidth).toBigInt,
                    )
                })
                
                val txUserSeq = src.randomUsers(nBeats)
                
                val txThr = src.sendBeats(genLastAtLastBeat = true, dataSeq = txDataSeq, userSeq = txUserSeq)
                val rxThr = snk.recvBeatsToLast()
                
                txThr.join()
                rxThr.join()
                
                val outSeq = snk.dataSeq.map(d => d.bitSlicesByteWise(zWidth, xyWidth, xyWidth))
                val xoutSeq = outSeq.map(o => o(2).asFixPoint(xyWidth, xyFracWidth))
                val youtSeq = outSeq.map(o => o(1).asFixPoint(xyWidth, xyFracWidth))
                val zoutSeq = outSeq.map(o => o(0).asFixPoint(zWidth, zFracWidth))

                if(verbose) {
                    println("--------------------------------------------------------")
                    var lastClock = 0L
                    for (i <- 0L until math.max(src.totalClocks, snk.totalClocks)) {
                        val srcStr = src.signalStringOfClock(i)
                        val snkStr = snk.signalStringOfClock(i)
                        if (srcStr(0) != ' ' || snkStr(0) != ' ') {
                            val clkInc = i - lastClock
                            println(f"clk+${clkInc}%02d=${i}%04d: ${srcStr} --> ${snkStr}")
                            lastClock = i
                        }
                    }
                    println("--------------------------------------------------------")
                    for (i <- 0 until nBeats) {
                        print(f"beat_${i}%04d: ")
                        print(f"(${xinSeq(i)}%6.3f, ${yinSeq(i)}%6.3f, ${zinSeq(i)}%6.3f) --> ")
                        println(f"(${xoutRefSeq(i)}%6.3f, ${youtRefSeq(i)}%6.3f, ${zoutRefSeq(i)}%7.3f)")
                        print("                                    ")
                        println(f"got (${xoutSeq(i)}%6.3f, ${youtSeq(i)}%6.3f, ${zoutSeq(i)}%7.3f)")
                        println()
                    }
                }

                println("--------------------------------------------------------")
                val xerr = elemWiseDiff(xoutSeq, xoutRefSeq)
                val yerr = elemWiseDiff(youtSeq, youtRefSeq)
                val zerr = elemWiseDiff(zoutSeq, zoutRefSeq)
                val (xm, xmi, xr) = maxAndRms(xerr)
                val (ym, ymi, yr) = maxAndRms(yerr)
                val (zm, zmi, zr) = maxAndRms(zerr)
                val (xmLsb, xrLsb) = (xm / xyLsb, xr / xyLsb)
                val (ymLsb, yrLsb) = (ym / xyLsb, yr / xyLsb)
                val (zmLsb, zrLsb) = (zm / zLsb, zr / zLsb)
                
                println(f"Error of x: Max Abs = ${xm}%8.6f(${xmLsb}%4.2fLSB, @${xmi}%03d), Std Dev = ${xr}%8.6f(${xrLsb}%4.2fLSB)")
                println(f"Error of y: Max Abs = ${ym}%8.6f(${ymLsb}%4.2fLSB, @${ymi}%03d), Std Dev = ${yr}%8.6f(${yrLsb}%4.2fLSB)")
                println(f"Error of z: Max Abs = ${zm}%8.6f(${zmLsb}%4.2fLSB, @${zmi}%03d), Std Dev = ${zr}%8.6f(${zrLsb}%4.2fLSB)")

                val inMaxAbsLimit = (xmLsb < 2 && ymLsb < 10 && zmLsb < 20)
                inMaxAbsLimit should be (true)
                val inStdDevLimit = (xrLsb < 1 && yrLsb < 2 && zrLsb < 4)
                inStdDevLimit should be (true)

                println("--------------------------------------------------------")
                println(s"\u001b[1mErrors Meets Spec: ${if (inMaxAbsLimit && inStdDevLimit) "YES" else "NO"}\u001b[0m")
                println("========================================================")
                Thread.sleep(1000)
            }
        }
    }
}