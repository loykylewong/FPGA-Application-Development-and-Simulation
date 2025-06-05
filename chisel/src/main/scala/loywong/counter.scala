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

package examples {
    class counter_example(m: Int = 256) extends Module {
        val io = IO(new Bundle {
            val en = Input(Bool())
            val out = Output(UInt(log2Ceil(m).W))
            val co = Output(Bool())
        })
        // use chisel3.util.Counter !
        val (cnt, co) = Counter(io.en, m)
        io.out := cnt
        io.co := co
    }
}

object CounterOneShot {
    def apply(m:BigInt, en:Bool, continue:Bool = false.B): (UInt, Bool) = {
        val w = log2Ceil(m)
        val cnt = RegInit(0.U(w.W))
        val wrap = cnt === (m-1).U
        when(en) {
            when(wrap) {
                cnt := Mux(continue, 0.U(w.W), cnt)
            }.otherwise {
                cnt := cnt + 1.U(w.W)
            }
        }
        (cnt, en && wrap && continue)
    }
}

package examples {
    class counter_oneshot_example extends Module {
        val io = FlatIO(new Bundle {
            val en = Input(Bool())
            val dly_rst = Output(Bool())
        })
        val (cnt, _) = CounterOneShot(100, io.en)
        io.dly_rst := cnt === 99.U
    }
}

object CounterMax {
    def apply(width:Int, max:UInt, en:Bool): (UInt, Bool) = {
        val cnt = RegInit(0.U(width.W))
        val wrap = cnt === max
        when(en) {
            when(wrap) {
                cnt := 0.U(width.W)
            }.otherwise {
                cnt := cnt + 1.U(width.W)
            }
        }
        (cnt, en && wrap)
    }
}

object CounterMaxOneShot {
    def apply(width:Int, max:UInt, en:Bool, continue:Bool = false.B): (UInt, Bool) = {
        val cnt = RegInit(0.U(width.W))
        val wrap = cnt === max
        when(en) {
            when(wrap) {
                cnt := Mux(continue, 0.U(width.W), cnt)
            }.otherwise {
                cnt := cnt + 1.U(width.W)
            }
        }
        (cnt, en && wrap && continue)
    }
}

package examples {
    class counter_max_example(width: Int = 8) extends Module {
        val io = IO(new Bundle {
            val max = Input(UInt(width.W))
            val en = Input(Bool())
            val out = Output(UInt(width.W))
            val co = Output(Bool())
        })
        val (out, co) = CounterMax(width, io.max, io.en)
        io.out := out
        io.co := co
    }

    class count_down_example extends Module {
        val io = FlatIO(new Bundle {
            val dly_rst = Output(Bool())
        })

        val en = Wire(Bool())
        val (cnt, wrap) = {
            Counter((99 to 0 by -1), en)
        }
        en := cnt =/= 0.U

        io.dly_rst := !en
    }

    class counterHrMinSec extends Module {
        val io = FlatIO(new Bundle {
            val en = Input(Bool())
            val sec = Output(UInt(6.W))
            val min = Output(UInt(6.W))
            val hr = Output(UInt(5.W))
            val en_day = Output(Bool())
        })
        val (_, en_sec) = Counter(io.en, 100e6.toInt)
        val (sec, en_min) = Counter(en_sec, 60)
        val (min, en_hr) = Counter(en_min, 60)
        val (hr, en_day) = Counter(en_hr, 24)
        io.sec := sec
        io.min := min
        io.hr := hr
        io.en_day := en_day

    }
}
