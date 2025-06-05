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

/*class ShiftReg(nBits: Int) extends Module {
    val io = IO(new Bundle {
        val shift = Input(Bool())
        val load = Input(Bool())
        val din = Input(UInt(nBits.W))
        val sin = Input(Bool())
        val qout = Output(UInt(nBits.W))
    })
    val regs = RegInit(0.U(nBits.W))
    /*regs := MuxCase(regs, Seq(
        ((io.shift ## io.load) === "b10".U) -> regs(nBits - 2, 0) ## io.sin,
        ((io.shift ## io.load) === "b01".U) -> io.din,
        ((io.shift ## io.load) === "b11".U) -> io.din(nBits - 2, 0) ## io.sin
    ))*/
    switch (io.shift ## io.load) {
        is("b10".U) { regs := regs(nBits - 2, 0) ## io.sin }
        is("b01".U) { regs := io.din }
        is("b11".U) { regs := io.din(nBits - 2, 0) ## io.sin }
    }
    io.qout := regs
}*/

class ShiftReg(nBits: Int) {
    val regs = RegInit(0.U(nBits.W))
    def load(din: UInt): UInt = {
        regs := din
        regs
    }
    def shift(sin: Bool): UInt = {
        regs := regs(nBits - 2, 0) ## sin
        regs
    }
    def qout: UInt = regs
}

package examples {
    class shift_reg_example extends Module {
        val dw = 10
        val io = IO(new Bundle {
            val shift = Input(Bool())
            val load = Input(Bool())
            val din = Input(UInt(dw.W))
            val sin = Input(Bool())
            val qout = Output(UInt(dw.W))
        })
        val sr = new ShiftReg(dw)
        when(io.shift) {
            sr.shift(io.sin)
        }
        when(io.load) {
            sr.load(io.din)
        }
        io.qout := sr.qout
    }
}
