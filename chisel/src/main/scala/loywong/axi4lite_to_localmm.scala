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

/**
 * Local Memory Map I.F. with:
 *  - address  : the register address, not the byte address
 *  - write    : write enable signal for issuing a write transaction
 *  - writeData: data to be written to the address when write asserted
 *  - writeByteEn : byte enable for writeData in a write transaction
 *  - read      : read enable signal for issuing a read transaction
 *  - readData  : data read from the address when read asserted
 * @param addrWidth width of the address
 * @param dataBytes number of bytes of data
 * @note
 *  - In write transaction, `address`, `writeData` and `writeByteEn` must be
 *    active in the same cycle when write asserted, that is:
 *    - Write Wait = 0
 *    - Write Latency = 0
 *  - In read transaction, `address` must be active in the same cycle when read
 *    asserted, and readData must be valid in the very next cycle, that is:
 *    - Read Wait = 0
 *    - Read Latency = 1
 */
class LocalMemoryMapIO(addrWidth: Int, dataBytes: Int = 4) extends Bundle {
    val address     = Output(UInt(addrWidth.W))
    val write       = Output(Bool())
    val writeData   = Output(UInt((dataBytes*8).W))
    val writeByteEn = Output(UInt(dataBytes.W))
    val read        = Output(Bool())
    val readData    = Input(UInt((dataBytes*8).W))
}

object LocalMemoryMap {
    /**
     * Create a instance of Local Memory Map Master IO
     * @param addrWidth Width of register word address
     * @param dataBytes Number of data bytes
     * @return          Instance created
     */
    def MasterIO(addrWidth: Int, dataBytes: Int = 4) = {
        new LocalMemoryMapIO(addrWidth, dataBytes)
    }

    /**
     * Create a instance of Local Memory Map Slave IO
     * @param addrWidth Width of register word address
     * @param dataBytes Number of data bytes
     * @return          Instance created
     */
    def SlaveIO(addrWidth: Int, dataBytes: Int = 4) = {
        Flipped(new LocalMemoryMapIO(addrWidth, dataBytes))
    }
}

class Axi4LiteIO(addrWidth: Int, dataBytes: Int = 4) extends Bundle {
    class AWBits extends Bundle {
        val addr = UInt(addrWidth.W)
        val prot = UInt(3.W)
    }
    class WBits extends Bundle {
        val data = UInt((dataBytes*8).W)
        val strb = UInt(dataBytes.W)
    }
    class BBits extends Bundle {
        val resp = UInt(2.W)
    }
    class ARBits extends Bundle {
        val addr = UInt(addrWidth.W)
        val prot = UInt(3.W)
    }
    class RBits extends Bundle {
        val data = UInt((dataBytes*8).W)
        val resp = UInt(2.W)
    }
    val aw = Irrevocable(new AWBits)
    val w  = Irrevocable(new WBits)
    val b  = Flipped(Irrevocable(new BBits))
    val ar = Irrevocable(new ARBits)
    val r  = Flipped(Irrevocable(new RBits))
}

object Axi4Lite {
    /**
     * Create a instance of AXI4-Lite Master IO
     * @param addrWidth Width of address (byte address)
     * @param dataBytes Number of data bytes
     * @return          Instance created
     */
    def MasterIO(addrWidth: Int, dataBytes: Int = 4)  = {
        new Axi4LiteIO(addrWidth, dataBytes)
    }
    /**
     * Create a instance of AXI4-Lite Slave IO
     * @param addrWidth Width of address (byte address)
     * @param dataBytes Number of data bytes
     * @return          Instance created
     */
    def SlaveIO(addrWidth: Int, dataBytes: Int = 4) = {
        Flipped(new Axi4LiteIO(addrWidth, dataBytes))
    }
}

/**
 * Represent a hardware AXI4-Lite Slave to local memory map master bridge
 * module.
 * @param regAddrWidth  Width of register word address (not the byte address)
 * @param regDataBytes  Number of bytes of tdata in AXI4-Lite and local memory
 *                      map I.F.
 */
class Axi4LiteToLocalMemoryMap(regAddrWidth: Int, regDataBytes: Int = 4) extends Module {
    require(regAddrWidth >= 0)
    require(isPow2(regDataBytes))

    override def desiredName: String = super.desiredName +
            s"_${1 << regAddrWidth}x${regDataBytes * 8}"

    val byteAddrExt = log2Ceil(regDataBytes)
    val byteAddrWidth = regAddrWidth + byteAddrExt

    val io = IO(new Bundle {
        val axi4l = Axi4Lite.SlaveIO(byteAddrWidth, regDataBytes)
        val lmm = LocalMemoryMap.MasterIO(regAddrWidth, regDataBytes)
    })

    val regs_wr = WireDefault(Bool(), io.axi4l.w.fire)
    val regs_rd = WireDefault(Bool(), io.axi4l.ar.fire)

    // ==== aw channel ====
    io.axi4l.aw.ready := true.B // always ready
    val waddr_reg = RegInit(0.U(regAddrWidth.W))
    when(io.axi4l.aw.valid) {
        waddr_reg := io.axi4l.aw.bits.addr >> byteAddrExt
    }
    // ==== w channel ====
    val wready = RegInit(false.B)
    when(io.axi4l.aw.valid) {
        wready := true.B
    }.elsewhen(io.axi4l.w.fire) {
        wready := false.B
    }
    io.axi4l.w.ready := wready
    // ==== b channel ====
    io.axi4l.b.bits.resp := "b00".U(2.W) // always OK
    val bvalid = RegInit(false.B)
    when(io.axi4l.w.fire) {
        bvalid := true.B
    }.elsewhen(io.axi4l.b.fire) {
        bvalid := false.B
    }
    io.axi4l.b.valid := bvalid
    // ==== ar channel ====
    val raddr_reg = RegInit(0.U(regAddrWidth.W))
    when(io.axi4l.ar.valid) {
        raddr_reg := io.axi4l.ar.bits.addr >> byteAddrExt
    }
    val arready = RegInit(false.B)
    when(io.axi4l.ar.valid && !io.axi4l.ar.ready) {
        arready := true.B
    }.elsewhen(io.axi4l.ar.fire) {
        arready := false.B
    }
    io.axi4l.ar.ready := arready
    // ==== r channel ====
    io.axi4l.r.bits.resp := 0.U(2.W) // always OK
    val rvalid = RegInit(false.B)
    when(io.axi4l.ar.fire) {
        rvalid := true.B
    }.elsewhen(io.axi4l.r.fire) {
        rvalid := false.B
    }
    io.axi4l.r.valid := rvalid
    // ==== lmm ====
    io.lmm.address := Mux(regs_wr, waddr_reg, raddr_reg)
    io.lmm.write := regs_wr
    io.lmm.writeData := io.axi4l.w.bits.data
    io.lmm.writeByteEn := io.axi4l.w.bits.strb
    io.lmm.read := regs_rd
    io.axi4l.r.bits.data := io.lmm.readData
}

class Axi4LiteToLocalMemoryMapWrapper(regAddrWidth: Int, regDataBytes: Int = 4) extends RawModule {
    require(regAddrWidth >= 0)
    require(isPow2(regDataBytes))

    override def desiredName: String = super.desiredName +
            s"_${1 << regAddrWidth}x${regDataBytes * 8}"

    val byteAddrExt = log2Ceil(regDataBytes)
    val byteAddrWidth = regAddrWidth + byteAddrExt

    val aclk = IO(Input(Clock()))
    val areset_n = IO(Input(Bool()))
    val axi4l = IO(Axi4Lite.SlaveIO(byteAddrWidth, regDataBytes)).suggestName("s_axi4l")
    val lmm = IO(LocalMemoryMap.MasterIO(regAddrWidth, regDataBytes))

    val axi4l_to_lmm = withClockAndReset(aclk, !areset_n) {
        Module(new Axi4LiteToLocalMemoryMap(regAddrWidth, regDataBytes))
    }

    axi4l <> axi4l_to_lmm.io.axi4l
    lmm <> axi4l_to_lmm.io.lmm
}
