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
import chisel3.experimental.requireIsChiselType

/**
 * Represents a hardware active pipeline stage.
 *
 * An "active" pipeline stage handles handshaking in each stage, and generate
 * `en` signal for controlling data flow, which can be used for
 * `str_passive_stage` or user defined logic.
 *
 * @param genUS     Data type generator for upstream payload
 * @param genDS     Data type generator for downstream payload
 * @param initDS    Initialization function for reset value of downstream
 *                  payload, default `None` makes init value all zero
 * @param worker    Function for processing upstream payload into downstream
 *                  payload
 * @tparam U        Data type of upstream payload
 * @tparam D        Data type of downstream payload
 * @note    Recommended usage:
 *          1. Instantiate with arg `worker` represent operations needed.
 *          1. Extends and override `ds_bits_next := ...` or `ds_bits_next.xxx := ...`
 */
class StrActiveStage[+U <: Data, +D <: Data]
(genUS: U = Bool(), genDS: D = Bool(), initDS: Option[()=>D] = None)
(worker: U => D = (x: U) => x.asTypeOf(genDS)) extends Module {
    requireIsChiselType(genUS)
    requireIsChiselType(genDS)

    override def desiredName = s"${super.desiredName}_${genUS.typeName}_to_${genDS.typeName}"

    val io = FlatIO(new Bundle {
        val us = Flipped(Irrevocable(genUS))
        val ds = Irrevocable(genDS)
        val en = Output(Bool())
    })

    io.en := io.us.fire
    io.us.ready := io.ds.ready || !io.ds.valid

    val ds_valid = RegInit(false.B)
    // ds_valid := Mux(io.en, true.B, Mux(io.ds.ready, false.B, ds_valid))
    ds_valid := MuxCase(ds_valid, Seq(
        io.us.fire -> true.B,
        io.ds.ready -> false.B
    ))
    io.ds.valid := ds_valid

    val ds_bits_next: D = WireDefault(0.U.asTypeOf(genDS))
    ds_bits_next := worker(io.us.bits)

    val ds_bits = initDS match {
        case Some(f) => RegInit(f())
        case None => RegInit(0.U.asTypeOf(genDS))
    }
    ds_bits := Mux(io.en, ds_bits_next, ds_bits)
    io.ds.bits := ds_bits
}

/**
 * Represents a hardware passive pipeline stage.
 *
 * A "passive" pipeline stage passively control data flow by using `en` signal
 * which can be provided by `str_active_stage` or user logic.
 *
 * @param genUS     Data type generator for upstream payload
 * @param genDS     Data type generator for downstream payload
 * @param initDS    Initialization function for reset value of downstream
 *                  payload
 * @param worker    Function for processing upstream payload into downstream
 *                  payload
 * @tparam U        Data type of upstream payload
 * @tparam D        Data type of downstream payload
 * @note    Recommended usage:
 *          1. Instantiate with arg `worker` represent operations needed.
 *          1. Extends and override `ds_bits_next := ...` or `ds_bits_next.xxx := ...`
 */
class StrPassiveStage[+U <: Data, +D <: Data]
(genUS: U = Bool(), genDS: D = Bool(), initDS: Option[()=>D] = None)
(worker: U => D = (x: U) => x.asTypeOf(genDS)) extends Module {
    requireIsChiselType(genUS)
    requireIsChiselType(genDS)

    override def desiredName = s"${super.desiredName}_${genUS.typeName}_to_${genDS.typeName}"

    val io = FlatIO(new Bundle {
        val en = Input(Bool())
        val us_bits = Input(genUS)
        val ds_bits = Output(genDS)
    })

    val ds_bits_next = WireDefault(0.U.asTypeOf(genDS))
    ds_bits_next := worker(io.us_bits)

    val ds_bits = initDS match {
        case Some(f) => RegInit(f())
        case None => RegInit(0.U.asTypeOf(genDS))
    }
    ds_bits := Mux(io.en, ds_bits_next, ds_bits)
    io.ds_bits := ds_bits
}

package examples {
    class str_stage_example_0(dw: Int = 8) extends Module {
        class us_bits extends Bundle {
            val real = SInt(dw.W)
            val imag = SInt(dw.W)
        }

        class ds_bits extends Bundle {
            val power = SInt((dw * 2).W)
        }

        val io = FlatIO(new Bundle {
            val us = Flipped(Irrevocable(new us_bits))
            val ds = Irrevocable(new ds_bits)
        })

        class sq_bits extends Bundle {
            val r_sq = SInt((dw * 2).W)
            val i_sq = SInt((dw * 2).W)
        }

        val stg_sq = Module(new StrActiveStage(
            new us_bits,
            new sq_bits,
        )(
            (x: us_bits) => {
                val y = Wire(new sq_bits)
                y.r_sq := x.real * x.real
                y.i_sq := x.imag * x.imag
                y
            }
        ))
        val stg_add = Module(new StrActiveStage(
            new sq_bits,
            new ds_bits,
        )(
            (x: sq_bits) => {
                val y = Wire(new ds_bits)
                y.power := x.r_sq + x.i_sq
                y
            }
        ))

        io.us <> stg_sq.io.us
        stg_sq.io.ds <> stg_add.io.us
        stg_add.io.ds <> io.ds
    }

    class str_stage_example_1(dw: Int = 8, sbw: Int = 8) extends Module {
        class us_bits extends Bundle {
            val real = SInt(dw.W)
            val imag = SInt(dw.W)
            val sideband = UInt(sbw.W)
        }

        class ds_bits extends Bundle {
            val power = SInt((dw * 2).W)
            val sideband = UInt(sbw.W)
        }

        val io = FlatIO(new Bundle {
            val us = Flipped(Irrevocable(new us_bits))
            val ds = Irrevocable(new ds_bits)
        })

        class sq_bits extends Bundle {
            val r_sq = SInt((dw * 2).W)
            val i_sq = SInt((dw * 2).W)
            val sideband = UInt(sbw.W)
        }

        val stg_sq = Module(new StrActiveStage(
            new us_bits,
            new sq_bits,
        )(
            (x: us_bits) => {
                val y = Wire(new sq_bits)
                y.sideband := x.sideband
                y.r_sq := x.real * x.real
                y.i_sq := x.imag * x.imag
                y
            }
        ))
        val stg_add = Module(new StrActiveStage(
            new sq_bits,
            new ds_bits,
        )(
            (x: sq_bits) => {
                val y = Wire(new ds_bits)
                y.sideband := x.sideband
                y.power := x.r_sq + x.i_sq
                y
            }
        ))

        io.us <> stg_sq.io.us
        stg_sq.io.ds <> stg_add.io.us
        stg_add.io.ds <> io.ds
    }

    class str_stage_example_2(dw: Int = 8, sbw: Int = 8) extends Module {
        class us_bits extends StrHasLast {
            override val last = Bool()
            val real = SInt(dw.W)
            val imag = SInt(dw.W)
            val sideband = UInt(sbw.W)
        }

        class ds_bits extends StrHasLast {
            override val last = Bool()
            val power = SInt((dw * 2).W)
            val sideband = UInt(sbw.W)
        }

        val io = FlatIO(new Bundle {
            val us = Flipped(Irrevocable(new us_bits))
            val ds = Irrevocable(new ds_bits)
        })

        class sq_bits extends Bundle {
            val r_sq = SInt((dw * 2).W)
            val i_sq = SInt((dw * 2).W)
        }

        val stg_sq = Module(new StrActiveStage()())
        val stg_add = Module(new StrActiveStage()())

        io.us.valid <> stg_sq.io.us.valid
        io.us.ready <> stg_sq.io.us.ready
        io.us.bits.last <> stg_sq.io.us.bits

        stg_sq.io.ds <> stg_add.io.us

        stg_add.io.ds.valid <> io.ds.valid
        stg_add.io.ds.ready <> io.ds.ready
        stg_add.io.ds.bits <> io.ds.bits.last

        val sq_regs = Reg(new sq_bits)
        when(stg_sq.io.en) {
            sq_regs.r_sq := io.us.bits.real * io.us.bits.real
            sq_regs.i_sq := io.us.bits.imag * io.us.bits.imag
        }

        val pw_regs = Reg(SInt((dw * 2).W))
        when(stg_add.io.en) {
            pw_regs := sq_regs.r_sq + sq_regs.i_sq
        }

        io.ds.bits.power := pw_regs

        val stg_sideband = Array.fill(2) {
            Module(new StrPassiveStage(UInt(sbw.W), UInt(sbw.W))())
        }
        stg_sideband(0).io.us_bits <> io.us.bits.sideband
        stg_sideband(0).io.en <> stg_sq.io.en
        stg_sideband(1).io.en <> stg_add.io.en
        for (i <- 1 until 2) {
            stg_sideband(i).io.us_bits := stg_sideband(i - 1).io.ds_bits
        }
        io.ds.bits.sideband <> stg_sideband(1).io.ds_bits
    }
}
