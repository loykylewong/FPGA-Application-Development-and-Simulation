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

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers._
import loywong._

class test_accumulator extends AnyFlatSpec with ChiselScalatestTester {
    println()
    println("====================")
    println("Test Accumulator...")
    println("--------------------")

    "DUT" should "pass" in {
        val modu = 100
        test(new Accumulator(modu)).withAnnotations(Seq(WriteVcdAnnotation)) {
            dut => {
                dut.clock.step()
                dut.reset.poke(true.B)
                dut.clock.step()
                dut.reset.poke(false.B)
                
                var x = 0
                // ---- step 15 x 20 ----
                var step = 15
                dut.io.step.poke(step.S)
                dut.io.en.poke(true)
                for(i <- 0 until 20) {
                    dut.clock.step()
                    x += step
                    val y = math.floorMod(x, modu)
                    if(y + step >= modu)
                        dut.io.wrapUp.expect(true)
                    else
                        dut.io.wrapUp.expect(false)
                    dut.io.wrapDown.expect(false)
                    dut.io.accu.expect(y.U)
                }
                // ---- disable ----
                dut.io.en.poke(false)
                dut.clock.step(20)
                dut.io.accu.expect(math.floorMod(x, modu).U)
                        // ---- step -20 x 20 ----
                step = -20
                dut.io.step.poke(step.S)
                dut.io.en.poke(true)
                for(i <- 0 until 20) {
                    dut.clock.step()
                    x += step
                    val y = math.floorMod(x, modu)
                    if(y + step < 0)
                        dut.io.wrapDown.expect(true)
                    else
                        dut.io.wrapDown.expect(false)
                    dut.io.wrapUp.expect(false)
                    dut.io.accu.expect(y.U)
                }
                println("-----------------------------")
                println(s"\u001b[1mAccumulator test Pass.\u001b[0m")
                println("=============================")
                Thread.sleep(1000)
            }
        }
    }
}