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
import loywong.util._

object CordicCoordinates extends Enumeration {
    val Circular = Value(1)
    val Linear = Value(0)
    val Hyperbolic = Value(-1)
}

object CordicMode extends Enumeration {
    val Rotation = Value(0)
    val Vectoring = Value(1)
}

class CordicIOStrBits(xyDW: Int, zDW: Int) extends StrBits {
    val x = SInt(xyDW.W)
    val y = SInt(xyDW.W)
    val z = SInt(zDW.W)
}

/**
 * Represent a hardware stream stage implemented one iteration step of CORDIC.
 * @param gen           generator of CORDIC IO bits, must be inherited from
 *                      `CordicIOStrBits`
 * @param stgIdx        index of iteration step
 * @param zFW           fraction width of `z` (angle)
 * @param coordinates   coordinate system
 * @param mode          rotation or vectoring mode
 * @tparam T            type of CORDIC IO bits
 * @note                Do NOT use this class.
 */
class CordicStage[T <: CordicIOStrBits](gen: T, stgIdx: Int, zFW: Int,
                                        coordinates: CordicCoordinates.Value,
                                        mode: CordicMode.Value)
  extends StrActiveStage(gen, gen)() {

    val xyDW = gen.x.getWidth
    val zDW = gen.z.getWidth

    coordinates match {
        case CordicCoordinates.Circular =>
            require(stgIdx >= 0)
        case CordicCoordinates.Hyperbolic =>
            require(stgIdx >= 1)
        case _ => { }
    }

    def atanh(x: Double): Double = {
        if (x.abs >= 1) Double.NaN
        else 0.5 * math.log((1 + x) / (1 - x))
    }

    // ---- parameters ----
    val deltaZDouble: Double = coordinates match {
        // for circular, map angle from [-pi, pi) to [-1, 1) (Qx.FW)
        case CordicCoordinates.Circular => math.atan(math.pow(2.0, -stgIdx)) / math.Pi
        case CordicCoordinates.Linear => math.pow(2.0, -stgIdx)
        case CordicCoordinates.Hyperbolic => atanh(math.pow(2.0, -stgIdx))
    }
    val deltaZ = Math.round(deltaZDouble * math.pow(2.0, zFW)).asSInt

    val sigma: Bool = mode match {
        case CordicMode.Rotation => !io.us.bits.z.signBit
        case CordicMode.Vectoring => io.us.bits.y.signBit
    }

    // ==== override `ds_bits_next` in `StrActiveStage` ====
    private def shiftRight(x: SInt, n: Int): Bits = {
        if (n >= 0) x >> n
        else x << -n
    }
    // ---- x ----
    coordinates match {
        case CordicCoordinates.Linear =>
            ds_bits_next.x := io.us.bits.x
        case CordicCoordinates.Circular =>
            when(sigma) {
                ds_bits_next.x := io.us.bits.x - shiftRight(io.us.bits.y, stgIdx).asSInt
            }.otherwise {
                ds_bits_next.x := io.us.bits.x + shiftRight(io.us.bits.y, stgIdx).asSInt
            }
        case CordicCoordinates.Hyperbolic =>
            when(sigma) {
                ds_bits_next.x := io.us.bits.x + shiftRight(io.us.bits.y, stgIdx).asSInt
            }.otherwise {
                ds_bits_next.x := io.us.bits.x - shiftRight(io.us.bits.y, stgIdx).asSInt
            }
    }
    // ---- y ----
    when(sigma) {
        ds_bits_next.y := io.us.bits.y + shiftRight(io.us.bits.x, stgIdx).asSInt
    }.otherwise {
        ds_bits_next.y := io.us.bits.y - shiftRight(io.us.bits.x, stgIdx).asSInt
    }
    // ---- z ----
    when(sigma) {
        ds_bits_next.z := io.us.bits.z - deltaZ
    }.otherwise {
        ds_bits_next.z := io.us.bits.z + deltaZ
    }
}

class CordicCircularQuadrantTrans[T <: CordicIOStrBits](gen: T, mode: CordicMode.Value)
        extends StrActiveStage(gen, gen)() {

    val xyDW = gen.x.getWidth
    val zDW = gen.z.getWidth

    val zInQuad2or3 = io.us.bits.z(zDW - 1, zDW - 2).xorR
    val xInQuad2or3 = io.us.bits.x(xyDW - 1)

    mode match {
        case CordicMode.Rotation => {
            when(zInQuad2or3) {
                ds_bits_next.x := -io.us.bits.x
                ds_bits_next.y := -io.us.bits.y
                ds_bits_next.z := io.us.bits.z ^ (1.U << (zDW - 1)).asSInt
            }.otherwise {
                ds_bits_next.x := io.us.bits.x
                ds_bits_next.y := io.us.bits.y
                ds_bits_next.z := io.us.bits.z
            }
        }
        case CordicMode.Vectoring => {
            when(xInQuad2or3) {
                ds_bits_next.x := -io.us.bits.x
                ds_bits_next.y := -io.us.bits.y
                ds_bits_next.z := io.us.bits.z ^ (1.U << (zDW - 1)).asSInt
            }.otherwise {
                ds_bits_next.x := io.us.bits.x
                ds_bits_next.y := io.us.bits.y
                ds_bits_next.z := io.us.bits.z
            }
        }
    }
}

class CordicLinearVectoringQuadrantTrans[T <: CordicIOStrBits](gen: T)
        extends StrActiveStage(gen, gen)() {

    val xyDW = gen.x.getWidth

    val xInQuad2or3 = io.us.bits.x(xyDW - 1)

    when(xInQuad2or3) {
        ds_bits_next.x := -io.us.bits.x
        ds_bits_next.y := -io.us.bits.y
        ds_bits_next.z := io.us.bits.z
    }.otherwise {
        ds_bits_next.x := io.us.bits.x
        ds_bits_next.y := io.us.bits.y
        ds_bits_next.z := io.us.bits.z
    }
}

class CordicHyperbolicVectoringQuadrantTrans[T <: CordicIOStrBits](gen: T)
        extends StrActiveStage(gen, gen)() {

    val xyDW = gen.x.getWidth

    val xInQuad2or3 = io.us.bits.x(xyDW - 1)

    when(xInQuad2or3) {
        ds_bits_next.x := -io.us.bits.x
        ds_bits_next.y := -io.us.bits.y
        ds_bits_next.z := io.us.bits.z
    }.otherwise {
        ds_bits_next.x := io.us.bits.x
        ds_bits_next.y := io.us.bits.y
        ds_bits_next.z := io.us.bits.z
    }
}

/**
 * Represent a hardware module of CORDIC algorithm
 *
 * @param gen           generator of generator of CORDIC IO bits, must be inherited from
 *                      `CordicIOStrBits`
 * @param nStages       number of iterations (pipe stages)
 * @param xyFW          fraction width of x and y
 * @param zFW           fraction width of z (angle)
 * @param coordinates   coordinate system
 * @param mode          rotation or vectoring mode
 * @param linStgStart   stage index start for linear coordinates,
 *                       - in Rotation mode, range of abs(z) < 2^(1 - linStgStart)^,
 *                       - in Vectoring mode, range of abs(y/x) < 2^(1 - linStgStart)^,
 *                       - x & y widths must make range of abs(x or y) covers
 *                       max{x_in, y_in} * 2^-linStgStart^, x_out, y_out}.
 * @tparam T            type of CORDIC IO bits
 * @note
 * - it's the user's responsibility to make sure the data width and fraction
 *   width match the CORDIC's input and output value domain.
 */
class Cordic[T <: CordicIOStrBits](gen: T, nStages: Int, xyFW: Int, zFW: Int,
                                   coordinates: CordicCoordinates.Value,
                                   mode: CordicMode.Value, linStgStart: Int = 0
               ) extends Module {

    val xyDW = gen.x.getWidth
    val zDW = gen.z.getWidth

    val nIterStages = nStages
    val nTotalStages = nIterStages + { coordinates match {
        case CordicCoordinates.Circular => 2    // quadTrans & scaleComp
        case CordicCoordinates.Hyperbolic => mode match {
            case CordicMode.Rotation => 1       // scaleComp
            case CordicMode.Vectoring => 2      // quadTrans & scaleComp
        }
        case CordicCoordinates.Linear => mode match {
            case CordicMode.Rotation => 0
            case CordicMode.Vectoring => 1      // quadTrans
        }
    }}

    if (coordinates == CordicCoordinates.Circular)
        require(zDW == zFW + 1)
    else if (coordinates == CordicCoordinates.Linear)
        require(linStgStart < zDW - zFW - 1)

    private def hyperbolicIter(i: Int): Int = {
        if (i <= 4) i // repeat 4
        else if (i <= 14) i - 1 // repeat 13
        else i - 2
    }

    val stageIdxSeq = coordinates match {
        case CordicCoordinates.Circular =>
            (0 until nStages).toList
        case CordicCoordinates.Hyperbolic =>
            (1 to nStages).map(i => hyperbolicIter(i))
        case CordicCoordinates.Linear =>
            (linStgStart until linStgStart + nStages).toList
    }

    val scale = coordinates match {
        case CordicCoordinates.Circular =>
            stageIdxSeq.map(i => math.sqrt(1.0 + math.pow(2.0, -2.0 * i))).foldLeft(1.0)(_ * _)
        case CordicCoordinates.Hyperbolic =>
            stageIdxSeq.map(i => math.sqrt(1.0 - math.pow(2.0, -2.0 * i))).foldLeft(1.0)(_ * _)
        case CordicCoordinates.Linear => 1.0
    }

    val io = IO(new Bundle {
        val us = Flipped(Irrevocable(gen))
        val ds = Irrevocable(gen)
    })

    class ScaleCompStage extends StrActiveStage(gen, gen)() {
        val scaleComp =
            if (coordinates == CordicCoordinates.Circular)
                (1.0 / scale).toFixPoint(xyDW.W, xyFW)
            else
                (1.0 / scale).toFixPoint((xyDW + 1).W, xyFW)
        ds_bits_next.x := (this.io.us.bits.x.asFixPoint(xyFW) * scaleComp).truncate(xyFW).getBits
        ds_bits_next.y := (this.io.us.bits.y.asFixPoint(xyFW) * scaleComp).truncate(xyFW).getBits
    }

    val scaleCompStage =
        if(coordinates != CordicCoordinates.Linear)
            Some(Module(new ScaleCompStage))
        else
            None

    val cordicStages = stageIdxSeq.map(s => {
        Module(new CordicStage(gen, s, zFW, coordinates, mode))
    })

    for (i <- 1 until cordicStages.length) {
        cordicStages(i - 1).io.ds <> cordicStages(i).io.us
    }

    coordinates match {
        case CordicCoordinates.Circular => {
            val quadTrans = Module(new CordicCircularQuadrantTrans(gen, mode))
            io.us <> quadTrans.io.us
            quadTrans.io.ds <> scaleCompStage.get.io.us
            scaleCompStage.get.io.ds <> cordicStages.head.io.us
            cordicStages.last.io.ds <> io.ds
        }
        case CordicCoordinates.Linear => {
            mode match {
                case CordicMode.Rotation => {
                    io.us <> cordicStages.head.io.us
                }
                case CordicMode.Vectoring => {
                    val quadTrans = Module(new CordicLinearVectoringQuadrantTrans(gen))
                    io.us <> quadTrans.io.us
                    quadTrans.io.ds <> cordicStages.head.io.us
                }
            }
            cordicStages.last.io.ds <> io.ds
        }
        case CordicCoordinates.Hyperbolic => {
            mode match {
                case CordicMode.Rotation => {
                    io.us <> cordicStages.head.io.us
                }
                case CordicMode.Vectoring => {
                    val quadTrans = Module(new CordicHyperbolicVectoringQuadrantTrans(gen))
                    io.us <> quadTrans.io.us
                    quadTrans.io.ds <> cordicStages.head.io.us
                }
            }
            cordicStages.last.io.ds <> scaleCompStage.get.io.us
            scaleCompStage.get.io.ds <> io.ds
        }
        case _ => { }
    }
}

package examples {
    class cordic_example extends Module {
        val xyDW = 12
        val xyFW = 10
        val zDW = 12
        val zFW = 11
        class CordicBits extends CordicIOStrBits(xyDW, zDW) {
            val sideband = UInt(8.W)
        }
        val io = IO(new Bundle {
            val us = Flipped(Irrevocable(new CordicBits))
            val ds = Irrevocable(new CordicBits)
        })
        val cordic = Module(new Cordic(new CordicBits,
            8, xyFW, zFW,
            CordicCoordinates.Circular,
            CordicMode.Rotation
        ))
        io.us <> cordic.io.us
        cordic.io.ds <> io.ds
    }
}
