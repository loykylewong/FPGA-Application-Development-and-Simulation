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

package loywongtest

import chisel3._
import chisel3.util._
import chiseltest._
import chiseltest.internal.TesterThreadList

import loywong._
import loywong.util._

/**
 * An AXI4-Lite Master for test-bench.
 * @param clk   The clock associated with the AXI4-Lite IO
 * @param axi4l The AXI4-Lite Slave IO to be tested
 */
class Axi4LiteTestMaster(clk: Clock, axi4l: Axi4LiteIO) {

    // private val addrWidth = axi4l.ar.bits.addr.getWidth
    private val dataBytes = axi4l.r.bits.data.getWidth / 8
    private val dataMask = (BigInt(1) << (dataBytes * 8)) - 1
    private val strbMask = (BigInt(1) << dataBytes) - 1

    /**
     * Issue a write transaction
     *
     * @param addr Address of the write transaction
     * @param data Data to be written
     * @param strb Strb associated to the data
     * @return Slave response
     */
    def write(addr: BigInt, data: BigInt, strb: BigInt = strbMask): Int = {
        axi4l.aw.bits.addr.poke(addr)
        axi4l.aw.bits.prot.poke(0)
        axi4l.aw.valid.poke(true)
        axi4l.w.bits.data.poke(data & dataMask)
        axi4l.w.bits.strb.poke(strb & strbMask)
        axi4l.w.valid.poke(true)
        axi4l.b.ready.poke(true)
        val awt = fork {
            while (!axi4l.aw.ready.peekBoolean()) {
                clk.step()
            }
            clk.step() // aw handshake cycle
            axi4l.aw.valid.poke(false)
        }
        val wt = fork {
            while (!axi4l.w.ready.peekBoolean()) {
                clk.step()
            }
            clk.step() // w handshake cycle
            axi4l.w.valid.poke(false)
        }
        awt.join()
        wt.join()
        while (!axi4l.b.valid.peekBoolean()) {
            clk.step()
        }
        val resp = axi4l.b.bits.resp.peekInt()
        clk.step() // b handshake cycle
        resp.toInt
    }

    /**
     * Issue a read transaction
     *
     * @param addr Address of the read transaction
     * @return (data, resp)
     *         - data: Data read
     *         - resp: Slave response
     */
    def read(addr: BigInt): (BigInt, Int) = {
        axi4l.ar.bits.addr.poke(addr)
        axi4l.ar.bits.prot.poke(0)
        axi4l.ar.valid.poke(true)
        axi4l.r.ready.poke(true)
        while (!axi4l.ar.ready.peekBoolean()) {
            clk.step()
        }
        clk.step() // ar handshake cycle
        axi4l.ar.valid.poke(false)
        while (!axi4l.r.valid.peekBoolean()) {
            clk.step()
        }
        val data = axi4l.r.bits.data.peekInt()
        val resp = axi4l.r.bits.resp.peekInt().toInt
        clk.step() // r handshake cycle
        (data, resp)
    }
}
