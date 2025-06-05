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

package test_axi4l_0

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers._
import loywong._
import loywongtest._

object SimSettings {
    val axi4lAddrWidth = 12
    val axi4lDataBytes = 4

    val lmmAddrWidth = axi4lAddrWidth - log2Up(axi4lDataBytes)
    val lmmDataBytes = axi4lDataBytes
    val lmmDataWidth = lmmDataBytes * 8

    val regAddrWidth = lmmAddrWidth
    val regDataBytes = lmmDataBytes
    val regDataWidth = lmmDataWidth

    val regMemSize   = 1 << regAddrWidth
    val dataMask = (BigInt(1) << regDataWidth) - 1

    require(isPow2(axi4lDataBytes))
}

class Dut extends Module {
    import SimSettings._
    val io = IO(new Bundle {
        val axi4l = Axi4Lite.SlaveIO(axi4lAddrWidth, axi4lDataBytes)
    })

    val axi2lmm = Module(new Axi4LiteToLocalMemoryMap(regAddrWidth, regDataBytes))
    io.axi4l <> axi2lmm.io.axi4l

    val mem = SyncReadMem(regMemSize, UInt(32.W))
    axi2lmm.io.lmm.readData := mem.read(axi2lmm.io.lmm.address, axi2lmm.io.lmm.read)
    when(axi2lmm.io.lmm.write) {
        mem.write(axi2lmm.io.lmm.address, axi2lmm.io.lmm.writeData)
    }

//    val mem = SyncReadMemReadFirst(regMemSize, UInt(32.W))(clock)
//    axi2lmm.io.lmm.readData := mem.read(axi2lmm.io.lmm.address)
//    mem.write(axi2lmm.io.lmm.address, axi2lmm.io.lmm.writeData, axi2lmm.io.lmm.write)

}

class test extends AnyFlatSpec with ChiselScalatestTester {
    println()
    println("===========================")
    println("Test AXI4-Lite Registers...")
    println("---------------------------")
    
    "DUT" should "pass" in {
        test(new Dut)/*.withAnnotations(Seq(VerilatorBackendAnnotation))*/ {
            dut => {
                import SimSettings._

                val master = new Axi4LiteTestMaster(dut.clock, dut.io.axi4l)

                dut.reset.poke(true.asBool)
                dut.clock.step()
                dut.reset.poke(false.asBool)
                dut.clock.step()

                println("---- Write cycle 1 ----")
                for(regAddr <- 0 until regMemSize) {
                    val data = ~BigInt(regAddr) & dataMask
                    master.write(regAddr * 4, data)
                    println(f"wrote: ${data}%08x @ ${regAddr}%03x")
                }
                println("---- Read cycle 1 ----")
                var errCnt = 0
                for(regAddr <- 0 until regMemSize) {
                    val dataRef = ~BigInt(regAddr) & dataMask
                    val (data, _) = master.read(regAddr * 4)
                    println(f"read: ${data}%08x (ref: ${dataRef}%08x) @ ${regAddr}%03x")
                    if(data != dataRef) {
                        errCnt = errCnt + 1
                    }
                }
                println(s"Total error: ${errCnt}")

                println("---- Write cycle 2 ----")
                for(regAddr <- 0 until regMemSize) {
                    val data = BigInt(regAddr)
                    master.write(regAddr * 4, data)
                    println(f"wrote: ${data}%08x @ ${regAddr}%03x")
                }
                println("---- Read cycle 2 ----")
                for(regAddr <- 0 until regMemSize) {
                    val dataRef = BigInt(regAddr)
                    val (data, _) = master.read(regAddr * 4)
                    println(f"read: ${data}%08x (ref: ${dataRef}%08x) @ ${regAddr}%03x")
                    if(data != dataRef) {
                        errCnt = errCnt + 1
                    }
                }
                println("-----------------------------")
                println(s"\u001b[1mTotal Error: ${errCnt}\u001b[0m")
                errCnt should be (0)
                println("=============================")
                Thread.sleep(1000)
            }
        }
    }
}