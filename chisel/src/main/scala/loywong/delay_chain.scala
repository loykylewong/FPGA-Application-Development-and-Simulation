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

class DelayChainMem2[T <: Data](gen: T, len: Int) extends Module {
    val addrWidth = log2Up(len)
    val io = IO(new Bundle {
        val en = Input(Bool())
        val in = Input(gen)
        val out = Output(gen)
    })
    if(len == 0) {
        io.out := io.in
    }
    else if(len == 1) {
        io.out := RegEnable(io.in, 0.U.asTypeOf(gen), io.en)
    }
    else {
        val en_dly = RegNext(io.en, false.B)
        
        val addr = RegInit(0.U(addrWidth.W))
        when(io.en) {
            addr := Mux(addr < (len - 2).U, addr + 1.U, 0.U)
        }
        
        val ramrf = SyncReadMemReadFirst(len, gen)(clock)
        ramrf.write(addr, io.in, io.en)
        val ram_out = ramrf.read(addr)
        
        val ram_out_dly = RegEnable(ram_out, 0.U.asTypeOf(gen), en_dly)
        io.out := Mux(en_dly, ram_out, ram_out_dly)
    }
}

class DelayChainVariableLength[T <: Data](gen: T, maxLen: Int, minLen: Int) extends Module {
    
    val lenWidth = log2Up(maxLen + 1)
    val addrWidth = log2Up(maxLen)
    
    val io = IO(new Bundle {
        val en = Input(Bool())
        val length = Input(UInt(lenWidth.W))
        val in = Input(gen)
        val out = Output(gen)
    })
    
    val en_dly = RegNext(io.en, false.B)
    val in_dly = RegEnable(io.in, 0.U.asTypeOf(gen), io.en)
    
    val ram = SyncReadMemReadFirst(maxLen, gen)(clock)
    
    val addr = RegInit(0.U(addrWidth.W))
    when(io.en) {
        addr := Mux(addr < io.length - 2.U, addr + 1.U, 0.U)
    }
    
    val ram_out = ram.read(addr)
    ram.write(addr, io.in, io.en)
    
    val ram_out_dly = RegEnable(ram_out, 0.U.asTypeOf(gen), en_dly)
    if(minLen > 1) {
        io.out := Mux(en_dly, ram_out, ram_out_dly)
    }
    else if(minLen > 0) {
        io.out := MuxCase(ram_out_dly, Seq(
            (io.length === 1.U) -> in_dly,
            (en_dly) -> ram_out
        ))
    }
    else {
        io.out := MuxCase(ram_out_dly, Seq(
            (io.length === 0.U) -> io.in,
            (io.length === 1.U) -> in_dly,
            (en_dly) -> ram_out
        ))
    }
}

package examples {
    class delay_chain_example extends Module {
        val n = 16
        val dw = 8
        val io = IO(new Bundle {
            val en = Input(Bool())
            val in = Input(UInt(dw.W))
            val out = Output(UInt(dw.W))
        })
        // user chisel3.util.ShiftRegister directly
        if(n < 16)
            io.out := ShiftRegister(io.in, n, io.en)
        else
            io.out := ShiftRegister.mem(io.in, n, io.en, true, None)
    }
    
    class delay_chain_mem2_example extends Module {
        val len = 12
        val dw = 8
        val dType = UInt(dw.W)
        val io = IO(new Bundle {
            val en = Input(Bool())
            val in = Input(dType)
            val out = Output(dType)
        })
        val delayChainMem2 = Module(new DelayChainMem2(dType, len))
        io <> delayChainMem2.io
    }
    
    class delay_chain_varlen_example extends Module {
        val maxLen = 16
        val lenWidth = log2Up(maxLen + 1)
        val dw = 8
        val dType = UInt(dw.W)
        val io = IO(new Bundle {
            val en = Input(Bool())
            val length = Input(UInt(lenWidth.W))
            val in = Input(dType)
            val out = Output(dType)
        })
        val delayChainVarLen = Module(new DelayChainVariableLength(dType, maxLen, 0))
        io <> delayChainVarLen.io
    }
}
