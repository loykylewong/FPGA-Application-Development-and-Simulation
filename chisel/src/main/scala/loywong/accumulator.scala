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

class Accumulator(modu: Int) extends Module {
    require(modu > 1)
    val dw = log2Up(modu)
    val idw = dw + 2
    val io = IO(new Bundle {
        val en = Input(Bool())
        val step = Input(SInt(dw.W))
        val accu = Output(UInt(dw.W))
        val wrapUp = Output(Bool())
        val wrapDown = Output(Bool())
    })
    
    val accu = RegInit(0.U(dw.W))
    val nextRaw = Wire(SInt(idw.W))
    val wrapUp = WireDefault(nextRaw >= modu.S)
    val wrapDown = WireDefault(nextRaw < 0.S)
    val nextWrap = Wire(UInt(dw.W))
    nextRaw := (0.U(1.W) ## accu).asSInt +& io.step
    nextWrap := MuxCase(nextRaw(dw - 1, 0), Seq(
        wrapUp -> (nextRaw - modu.S)(dw - 1, 0),
        wrapDown -> (nextRaw + modu.S)(dw - 1, 0)
    ))
    when(io.en) {
        accu := nextWrap
    }
    io.accu := accu
    io.wrapUp := wrapUp && io.en
    io.wrapDown := wrapDown && io.en
}

package examples {
    class accumulator_example extends Module {
        val modu = 100
        val io = IO(new Bundle {
            val en = Input(Bool())
            val step = Input(SInt(7.W))
            val accu = Output(UInt(7.W))
            val wrapUp = Output(Bool())
            val wrapDown = Output(Bool())
        })
        val theAccu = Module(new Accumulator(modu))
        io <> theAccu.io
        
    }
}