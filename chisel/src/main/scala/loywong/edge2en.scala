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

/*
package loywong

import chisel3._
import chisel3.util._

// ==== Moved into cross_clock_domain.scala ====
object Edge2En {
    def apply(nStages:Int = 2, in:Bool, initOnes:Boolean = false): (Bool, Bool, Bool) = {
        require(nStages >= 0, "nStages must positive in edge2en")
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

package examples {
    class edge2en_example(nStages: Int = 2) extends Module {
        val io = IO(new Bundle {
            val in = Input(Bool())
            val out = Output(Bool())
            val rising = Output(Bool())
            val falling = Output(Bool())
        })
        val (r, f, o) = edge2en(nStages, io.in, true)
        io.rising := r
        io.falling := f
        io.out := o
    }
}
 */
