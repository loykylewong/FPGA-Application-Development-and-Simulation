package loywong

import chisel3._
import chisel3.util._
import chiseltest._

import scala.annotation.unused

object util {
    implicit class BitsUtil(private val x: Bits) extends AnyVal {
        /**
         * Get the minimum width divisible by 8 and no less than the data width
         *
         * @return The minimum width divisible by 8
         */
        def getWidthUp8: Int = ((x.getWidth - 1) / 8 + 1) * 8

        /**
         * Get the minimum number of bytes that can hold data
         *
         * @return The minimum number of bytes
         */
        def getBytesCeil: Int = (x.getWidth - 1) / 8 + 1

        /**
         * Extend width by padding 0 to MSB side
         *
         * @param toBits Desired width of return data
         * @return Extended data
         */
        def extend(toBits: Int): Bits = {
            require(toBits >= x.getWidth)
            if (toBits > x.getWidth) {
                0.U((toBits - x.getWidth).W) ## x
            }
            else {
                x
            }
        }

        /**
         * Extend width to integer number of bytes
         *
         * @return Extended data
         */
        def extendToBytes: Bits = {
            x match {
                case u: UInt => u.extendToBytes
                case s: SInt => s.extendToBytes
                case _ => x.extendToBytes
            }
        }

        /**
         * Slice Bits into slices according to width of sinks and connect them
         * to sinks
         *
         * @param sinks Sinks to be connected
         * @example {{{
         *              val x = Wire(UInt(12.W))
         *              val a = Wire(UInt(4.W))
         *              val b = Wire(SInt(8.W))
         *              x.sliceTo(a, b)
         * }}}
         */
        def sliceTo(sinks: Bits*): Unit = {
            var lsb = 0
            sinks.reverse.foreach(y => {
                y match {
                    case s: SInt => s := x(lsb + s.getWidth - 1, lsb).asSInt
                    case u: UInt => u := x(lsb + u.getWidth - 1, lsb)
                    case _ => y := x(lsb + y.getWidth - 1, lsb)
                }
                lsb += y.getWidth
            })
        }

        /**
         * Slice Bits into slices according to widths
         *
         * @param widths Widths of each slices
         * @return Seq of slices
         */
        def slices(widths: Int*): Seq[UInt] = {
            val res = widths.map(w => Wire(UInt(w.W)))
            sliceTo(res: _*)
            res
        }

        /**
         * Concat multiple Bits and connect them to this Bits
         *
         * @param sources The multiple bits to be concatenated
         */
        def catFrom(sources: Bits*): Unit = {
            x := Cat(sources)
        }

        /**
         * Slice Bits into slices according to `widthUp8` of sinks and connect
         * them to sinks
         *
         * @param sinks Sinks to be connected
         * @example {{{
         *              val x = Wire(UInt(24W))
         *              val a = Wire(UInt(6.W))
         *              val b = Wire(UInt(12.W))
         *              // a := x(21, 16)
         *              // b := x(11,  0)
         *              x.sliceTo(a, b)
         * }}}
         */
        def sliceByteWiseTo(sinks: Bits*): Unit = {
            var lsb = 0
            sinks.reverse.foreach(y => {
                y match {
                    case s: SInt => s := x(lsb + s.getWidth - 1, lsb).asSInt
                    case u: UInt => u := x(lsb + u.getWidth - 1, lsb)
                    case _ => y := x(lsb + y.getWidth - 1, lsb)
                }
                lsb += y.getWidthUp8
            })
        }

        /**
         * Slice Bits into slices according to "up8" of specified widths
         *
         * @param widths Widths of each slices
         * @return Seq of slices
         */
        def slicesByteWise(widths: Int*): Seq[UInt] = {
            val res = widths.map(w => Wire(UInt(w.W)))
            sliceByteWiseTo(res: _*)
            res
        }

        /**
         * Extend multiple Bits to "up8" widths, concat, and connect them to this Bits
         *
         * @param sources The multiple bits to be concatenated
         */
        def catByteWiseFrom(sources: Bits*): Unit = {
            if (sources.isEmpty)
                x := 0.U
            else
                x := Cat(sources.map(s => s.extendToBytes))
        }

        /**
         * Reinterpret this Bits as a Fixed-Point with specified frac width
         * @param fw Width of fractional part
         * @return Fixed-Point Wire
         */
        def asFixPoint(fw: Int): FixPoint = {
            val res = Wire(FixPoint(x.getWidth.W, fw))
            res.bits := x
            res
        }
    }

    implicit class UIntUtil(private val x: UInt) extends AnyVal {
        /**
         * Extend width by padding 0 to MSB side
         *
         * @param toBits Desired width of return data
         * @return Extended data
         */
        def extend(toBits: Int): UInt = {
            require(toBits >= x.getWidth)
            if (toBits > x.getWidth) {
                0.U((toBits - x.getWidth).W) ## x
            }
            else {
                x
            }
        }

        /**
         * Extend width to integer number of bytes
         *
         * @return Extended data
         */
        def extendToBytes: UInt = {
            x.extend(x.getWidthUp8)
        }

        /**
         * Repeat data bits, same as `Fill(n, data)` or `{n{data}}` in verilog
         *
         * @param n Times to repeat
         * @return Data with original data bits repeat n times in it.
         */
        def repeat(n: Int): UInt = {
            require(n >= 0)
            Fill(n, x)
        }

        def isPositive: Bool = {
            x =/= 0.U
        }

        def isNegative: Bool = false.B
    }

    implicit class SIntUtil(private val x: SInt) extends AnyVal {
        /**
         * Extend width by padding sign bit to MSB side
         *
         * @param toBits Desired width of return data
         * @return Extended data
         */
        def extend(toBits: Int): SInt = {
            require(toBits >= x.getWidth)
            if (toBits > x.getWidth)
                (Fill(toBits - x.getWidth, x.asUInt(x.getWidth - 1)) ## x.asUInt).asSInt
            else
                x
        }

        /**
         * Extend width to integer number of bytes
         *
         * @return Extended data
         */
        def extendToBytes: SInt = {
            x.extend(x.getWidthUp8)
        }

        def isPositive: Bool = {
            x > 0.S
        }

        def isNegative: Bool = {
            x(x.getWidth - 1) === 1.U
        }

        /**
         * @return Sign bit of this SInt
         */
        def signBit: Bool = x(x.getWidth - 1).asBool
    }

    /**
     * Extend each data to integer number of bytes, and then concat.
     *
     * @param x Seq of data
     * @return Concat result in UInt
     */
    def CatByteWise(x: Bits*): UInt = {
        if (x.isEmpty)
            0.U
        else
            Cat(x.map(u => u.extendToBytes))
    }

    /**
     * Extend each BigInt to integer number of bytes, and then concat.
     *
     * @param isSigned Seq of signedness of each data
     * @param w Seq of width of each data
     * @param x Seq of BigInts, lower w(i) bits of each is the actual data to
     *          be concat
     * @return Concat result in BigInt
     */
    def CatByteWise(isSigned: Seq[Boolean], w: Seq[Int], x: BigInt*): BigInt = {
        require(x.length == w.length)
        if (x.isEmpty)
            BigInt(0)
        else {
            var lsb = 0
            var res = BigInt(0)
            for (i <- x.length - 1 to 0 by -1) {
                val data = x(i)
                val width = w(i)
                if (isSigned(i))
                    res |= data.asSigned(width).asUnsigned(width.up8) << lsb
                else
                    res |= data.asUnsigned(width) << lsb
                lsb += width.up8
            }
            res.asUnsigned(lsb)
        }
    }

    implicit class BigIntUtils(private val x: BigInt) extends AnyVal {
        /**
         * @return The minimum number divisible by 8 and no less than this
         *         BigInt
         */
        def up8: BigInt = if (x < 0) 0 else ((x - 1) / 8 + 1) * 8

        /**
         * @return The number of high bit in this BigInt
         */
        def popCount: Int = {
            var n = 0
            for (i <- 0 until x.bitLength) {
                if (x.testBit(i))
                    n = n + 1
            }
            n
        }

        /**
         * @param mask Bits to be tested
         * @return True if `(x & mask) == mask`
         */
        def testBits(mask: BigInt): Boolean = {
            (x & mask) == mask
        }

        /**
         * @param mask Bits to be tested
         * @param bits Bits to be compared
         * @return True if `(x & mask) == bits`
         */
        def testBits(mask: BigInt, bits: BigInt): Boolean = {
            (x & mask) == bits
        }

        /**
         * @param nBit Number of lower bits to be reinterpreted
         * @return Reinterpret the lower nBit as unsigned
         */
        def asUnsigned(nBit: Int): BigInt = {
            x & ((BigInt(1) << nBit) - 1)
        }

        /**
         * @param nBit Number of lower bits to be reinterpreted
         * @return Reinterpret the lower nBit as signed
         */
        def asSigned(nBit: Int): BigInt = {
            if (x.testBits(BigInt(1) << (nBit - 1))) { // negative
                x.asUnsigned(nBit) - (BigInt(1) << nBit)
            }
            else { // positive
                x.asUnsigned(nBit)
            }
        }

        /**
         * Get bits by specifying MSB and LSB in this BigInt
         * @param msb Most significant bit pos
         * @param lsb Least significant bit pos
         * @return Bits in BigInt (this[msb : lsb])
         */
        def bitSlice(msb: Int, lsb: Int): BigInt = {
            (x >> lsb) & ((BigInt(2) << (msb - lsb)) - 1)
        }

        /**
         * Slice BigInt into slices according to widths
         *
         * @param widths Widths of each slices
         * @return Seq of slices
         */
        def bitSlices(widths: Int*): Seq[BigInt] = {
            var lsb = 0
            widths.reverse.map(w => {
                val res = x.bitSlice(lsb + w - 1, lsb)
                lsb += w
                res
            }).reverse
        }

        /**
         * Slice BigInt into slices according to "up8" of specified widths
         *
         * @param widths Widths of each slices
         * @return result slices
         */
        def bitSlicesByteWise(widths: Int*): Seq[BigInt] = {
            var lsb = 0
            widths.reverse.map(w => {
                val res = x.bitSlice(lsb + w - 1, lsb)
                lsb += w.up8
                res
            }).reverse
        }

        /**
         * Get the value if treat the lower width bits as a Fixed-Point with
         * specified frac width.
         *
         * @param width Width of effective bits
         * @param fracWidth Width of fractional part
         * @return Value of the Fixed-Point
         */
        def valueAsFixPoint(width: Int, fracWidth: Int): Double = {
            x.asSigned(width).toDouble * math.pow(2.0, -fracWidth)
        }

        /**
         * Get the value if treat the lower width bits as a Fixed-Point with
         * specified frac width.
         *
         * @param width Width of effective bits
         * @param fracWidth Width of fractional part
         * @return Value of the Fixed-Point
         * @note This BigDecimal version of `valueAsFixPoint` is more accurate
         *       than the Double version, when width or fracWidth is larger
         *       than or near to 64, this version is recommended.
         */
        def valueAsFixPointInBigDecimal(width: Int, fracWidth: Int): BigDecimal = {
            BigDecimal(x.asSigned(width)) * BigDecimal(2.0).pow(-fracWidth)
        }
    }

    implicit class LongUtils(private val x: Long) extends AnyVal {
        /**
         * @return The minimum number divisible by 8 and no less than this Long
         */
        def up8: Long = if (x < 0) 0 else ((x - 1) / 8 + 1) * 8

        /**
         * @param mask Bits to be tested
         * @return True if `(x & mask) == mask`
         */
        def testBits(mask: Long): Boolean = {
            (x & mask) == mask
        }

        /**
         * @param mask Bits to be tested
         * @param bits Bits to be compared
         * @return True if `(x & mask) == bits`
         */
        def testBits(mask: Long, bits: Long): Boolean = {
            (x & mask) == bits
        }

        /**
         * @param nBit Number of lower bits to be reinterpreted
         * @return Reinterpret the lower nBit as unsigned
         */
        def asUnsigned(nBit: Int): Long = {
            require(nBit < 64)
            x & ((1L << nBit) - 1)
        }

        /**
         * @param nBit Number of lower bits to be reinterpreted
         * @return Reinterpret the lower nBit as signed
         */
        def asSigned(nBit: Int): Long = {
            require(nBit <= 64)
            if (nBit == 64) {
                x
            }
            else if (x.testBits(1L << (nBit - 1))) { // negative
                x.asUnsigned(nBit) - (1L << nBit)
            }
            else { // positive
                x.asUnsigned(nBit)
            }
        }

        def toBigInt: BigInt = BigInt(x)
    }

    implicit class IntUtils(private val x: Int) extends AnyVal {
        /**
         * @return The minimum number divisible by 8 and no less than this Int
         */
        def up8: Int = if (x < 0) 0 else ((x - 1) / 8 + 1) * 8

        /**
         * @param mask Bits to be tested
         * @return True if `(x & mask) == mask`
         */
        def testBits(mask: Int): Boolean = {
            (x & mask) == mask
        }

        /**
         * @param mask Bits to be tested
         * @param bits Bits to be compared
         * @return True if `(x & mask) == bits`
         */
        def testBits(mask: Int, bits: Int): Boolean = {
            (x & mask) == bits
        }

        /**
         * @param nBit Number of lower bits to be reinterpreted
         * @return Reinterpret the lower nBit as unsigned
         */
        def asUnsigned(nBit: Int): Int = {
            require(nBit < 32)
            x & ((1 << nBit) - 1)
        }

        /**
         * @param nBit Number of lower bits to be reinterpreted
         * @return Reinterpret the lower nBit as signed
         */
        def asSigned(nBit: Int): Int = {
            require(nBit <= 32)
            if (nBit == 32) {
                x
            }
            else if (x.testBits(1 << (nBit - 1))) { // negative
                x.asUnsigned(nBit) - (1 << nBit)
            }
            else { // positive
                x.asUnsigned(nBit)
            }
        }

        def toBigInt: BigInt = BigInt(x)
    }

    implicit class ByteSeqReinterpret(private val bytes: Seq[Byte]) extends AnyVal {
        def asS8(idx: Int): Int = {
            require(idx + 1 <= bytes.length)
            bytes(idx).toInt
        }

        def asU8(idx: Int): Int = {
            require(idx + 1 <= bytes.length)
            bytes(idx) & 0xFF
        }

        def asS16(idx: Int, isBigEndian: Boolean = false): Int = {
            require(idx + 2 <= bytes.length)
            val x: Int = if (isBigEndian) {
                bytes.slice(idx, idx + 2).foldLeft(0)((acc, byte) => (acc << 8) | (byte & 0xFF))
            }
            else {
                bytes.slice(idx, idx + 2).foldRight(0)((byte, acc) => (byte & 0xFF) | (acc << 8))
            }
            x.asSigned(16)
        }

        def asU16(idx: Int, isBigEndian: Boolean = false): Int = {
            require(idx + 2 <= bytes.length)
            val x: Int = if (isBigEndian) {
                bytes.slice(idx, idx + 2).foldLeft(0)((acc, byte) => (acc << 8) | (byte & 0xFF))
            }
            else {
                bytes.slice(idx, idx + 2).foldRight(0)((byte, acc) => (byte & 0xFF) | (acc << 8))
            }
            x
        }

        def asS32(idx: Int, isBigEndian: Boolean = false): Int = {
            require(idx + 4 <= bytes.length)
            val x: Int = if (isBigEndian) {
                bytes.slice(idx, idx + 4).foldLeft(0)((acc, byte) => (acc << 8) | (byte & 0xFF))
            }
            else {
                bytes.slice(idx, idx + 4).foldRight(0)((byte, acc) => (byte & 0xFF) | (acc << 8))
            }
            x
        }

        def asU32(idx: Int, isBigEndian: Boolean = false): Long = {
            require(idx + 4 <= bytes.length)
            val x: Long = if (isBigEndian) {
                bytes.slice(idx, idx + 4).foldLeft(0L)((acc, byte) => (acc << 8) | (byte & 0xFF))
            }
            else {
                bytes.slice(idx, idx + 4).foldRight(0L)((byte, acc) => (byte & 0xFF) | (acc << 8))
            }
            x.asUnsigned(32)
        }

        def asS64(idx: Int, isBigEndian: Boolean = false): Long = {
            require(idx + 8 <= bytes.length)
            val x: Long = if (isBigEndian) {
                bytes.slice(idx, idx + 8).foldLeft(0L)((acc, byte) => (acc << 8) | (byte & 0xFF))
            }
            else {
                bytes.slice(idx, idx + 8).foldRight(0L)((byte, acc) => (byte & 0xFF) | (acc << 8))
            }
            x
        }

        def asU64(idx: Int, isBigEndian: Boolean = false): BigInt = {
            require(idx + 8 <= bytes.length)
            val x: BigInt = if (isBigEndian) {
                bytes.slice(idx, idx + 8).foldLeft(BigInt(0))((acc, byte) => (acc << 8) | (byte & 0xFF))
            }
            else {
                bytes.slice(idx, idx + 8).foldRight(BigInt(0))((byte, acc) => (byte & 0xFF) | (acc << 8))
            }
            x.asUnsigned(64)
        }

        def asUInt(idx: Int, nBit: Int, isBigEndian: Boolean = false): BigInt = {
            require(nBit > 0, s"In Seq[Byte].asUInt(), nBit must be > 0, got ${nBit}.")
            val nBytes = (nBit - 1) / 8 + 1
            require(idx + nBytes <= bytes.length)
            val x: BigInt = if (isBigEndian) {
                bytes.slice(idx, idx + nBytes).foldLeft(BigInt(0))((acc, byte) => (acc << 8) | (byte & 0xFF))
            }
            else {
                bytes.slice(idx, idx + nBytes).foldRight(BigInt(0))((byte, acc) => (byte & 0xFF) | (acc << 8))
            }
            x.asUnsigned(nBit)
        }

        def asSInt(idx: Int, nBit: Int, isBigEndian: Boolean = false): BigInt = {
            require(nBit > 0, s"In Seq[Byte].asInt(), nBit must be > 0, got ${nBit}.")
            val nBytes = (nBit - 1) / 8 + 1
            require(idx + nBytes <= bytes.length)
            val y: BigInt = if (isBigEndian) {
                bytes.slice(idx, idx + nBytes).foldLeft(BigInt(0))((acc, byte) => (acc << 8) | (byte & 0xFF))
            }
            else {
                bytes.slice(idx, idx + nBytes).foldRight(BigInt(0))((byte, acc) => (byte & 0xFF) | (acc << 8))
            }
            y.asSigned(nBit)
        }
    }

    implicit class StrBitsUtils[+T <: StrBits](private val x: T) extends AnyVal {
        def hasData: Boolean = x.isInstanceOf[StrHasData]

        def hasStrb: Boolean = x.isInstanceOf[StrHasStrb]

        def hasKeep: Boolean = x.isInstanceOf[StrHasKeep]

        def hasLast: Boolean = x.isInstanceOf[StrHasLast]

        def hasId: Boolean = x.isInstanceOf[StrHasId]

        def hasDest: Boolean = x.isInstanceOf[StrHasDest]

        def hasUser: Boolean = x.isInstanceOf[StrHasUser]

        def dataWidth: Int = {
            x match {
                case y: StrHasData => y.data.getWidth
                case _ => 0
            }
        }

        def pokeDataIfExist(data: BigInt): Option[BigInt] = {
            x match {
                case y: StrHasData => {
                    y.data match {
                        case d: UInt => d.poke(data)
                        case d: SInt => d.poke(data)
                        case _ => y.data.poke(data.asUInt)
                    }
                    Some(data)
                }
                case _ => None
            }
        }

        def peekDataIfExist: Option[BigInt] = {
            x match {
                case y: StrHasData => {
                    y.data match {
                        case d: UInt => Some(d.peekInt())
                        case d: SInt => Some(d.peekInt())
                        case _ => Some(y.data.asUInt.peekInt())
                    }
                }
                case _ => None
            }
        }

        def dataBytesCeil: Int = {
            x match {
                case y: StrHasData => (y.data.getWidth - 1) / 8 + 1
                case _ => 0
            }
        }

        def bytesPerBeat: Int = {
            x match {
                case y: StrHasData => (y.data.getWidth - 1) / 8 + 1
                case _ => 0
            }
        }

        def strbWidth: Int = {
            x match {
                case y: StrHasStrb => y.strb.getWidth
                case _ => 0
            }
        }

        def strbMask: BigInt = {
            (BigInt(1) << dataBytesCeil) - 1
        }

        def pokeStrbIfExist(strb: BigInt): Option[BigInt] = {
            x match {
                case y: StrHasStrb => {
                    y.strb.poke(strb)
                    Some(strb)
                }
                case _ => None
            }
        }

        def peekStrbIfExist: Option[BigInt] = {
            x match {
                case y: StrHasStrb => Some(y.strb.peekInt())
                case _ => None
            }
        }

        def peekStrbImplicit: BigInt = {
            x match {
                case y: StrHasStrb => y.strb.peekInt()
                case _ => strbMask
            }
        }

        def keepWidth: Int = {
            x match {
                case y: StrHasKeep => y.keep.getWidth
                case _ => 0
            }
        }

        def keepMask: BigInt = {
            (BigInt(1) << dataBytesCeil) - 1
        }

        def pokeKeepIfExist(keep: BigInt): Option[BigInt] = {
            x match {
                case y: StrHasKeep => {
                    y.keep.poke(keep)
                    Some(keep)
                }
                case _ => None
            }
        }

        def peekKeepIfExist: Option[BigInt] = {
            x match {
                case y: StrHasKeep => Some(y.keep.peekInt())
                case _ => None
            }
        }

        def peekKeepImplicit: BigInt = {
            x match {
                case y: StrHasKeep => y.keep.peekInt()
                case _ => keepMask
            }
        }

        def pokeLastIfExist(last: Boolean): Option[Boolean] = {
            x match {
                case y: StrHasLast => {
                    y.last.poke(last)
                    Some(last)
                }
                case _ => None
            }
        }

        def peekLastIfExist: Option[Boolean] = {
            x match {
                case y: StrHasLast => Some(y.last.peekBoolean())
                case _ => None
            }
        }

        def idWidth: Int = {
            x match {
                case y: StrHasId => y.id.getWidth
                case _ => 0
            }
        }

        def pokeIdIfExist(id: Long): Option[Long] = {
            x match {
                case y: StrHasId => {
                    y.id.poke(BigInt(id))
                    Some(id)
                }
                case _ => None
            }
        }

        def peekIdIfExist: Option[Long] = {
            x match {
                case y: StrHasId => Some(y.id.peekInt().toLong)
                case _ => None
            }
        }

        def destWidth: Int = {
            x match {
                case y: StrHasDest => y.dest.getWidth
                case _ => 0
            }
        }

        def pokeDestIfExist(dest: Long): Option[Long] = {
            x match {
                case y: StrHasDest => {
                    y.dest.poke(BigInt(dest))
                    Some(dest)
                }
                case _ => None
            }
        }

        def peekDestIfExist: Option[Long] = {
            x match {
                case y: StrHasDest => Some(y.dest.peekInt().toLong)
                case _ => None
            }
        }

        def userWidth: Int = {
            x match {
                case y: StrHasUser => y.user.getWidth
                case _ => 0
            }
        }

        def userBitsPerDataByte: Int = {
            require(x.isInstanceOf[StrHasData])
            val bpb = (x.asInstanceOf[StrHasData].data.getWidth - 1) / 8 + 1
            x match {
                case y: StrHasUser => (y.user.getWidth - 1) / bpb + 1
                case _ => 0
            }
        }

        def pokeUserIfExist(user: BigInt): Option[BigInt] = {
            x match {
                case y: StrHasUser => {
                    y.user match {
                        case u: UInt => u.poke(user)
                        case u: SInt => u.poke(user)
                        case _ => y.user.poke(user.asUInt)
                    }
                    // y.user.poke(user)
                    Some(user)
                }
                case _ => None
            }
        }

        def peekUserIfExist: Option[BigInt] = {
            x match {
                case y: StrHasUser => {
                    y.user match {
                        case u: UInt => Some(u.peekInt())
                        case u: SInt => Some(u.peekInt())
                        case _ => Some(y.user.asUInt.peekInt())
                    }
                    // Some(y.user.peekInt())
                }
                case _ => None
            }
        }
    }

    sealed class FixPoint(val bits: SInt, private val fw: Int) extends Bundle {
        require(0 < fw && fw < 128, s"In FixPoint, fw must be > 0 and < 128, but fw=${fw} got.")
        require(bits.widthKnown)
        require(!bits.isLit)

        def getFracWidth: Int = fw

        def lowest: Double = FixPoint.lowest(bits.getWidth, fw)

        def highest: Double = FixPoint.highest(bits.getWidth, fw)

        def lowestInBigDecimal: BigDecimal = FixPoint.lowestInBigDecimal(bits.getWidth, fw)

        def highestInBigDecimal: BigDecimal = FixPoint.highestInBigDecimal(bits.getWidth, fw)

        def inRange(value: Double): Boolean = FixPoint.inRange(bits.getWidth, fw, value)

        def inRange(value: BigDecimal): Boolean = FixPoint.inRange(bits.getWidth, fw, value)

        /**
         * @param value assign a double constant/parameter
         */
        final def :=(value: Double): Unit = {
            require(inRange(value), s"In FixPoint, ${value} can not fit in fix point binary with width=${bits.getWidth} and fw=${fw}.")
            this.bits := (value * math.pow(2.0, fw)).round.asSInt
        }

        /**
         * @param value assign a BigDecimal constant/parameter
         */
        final def :=(value: BigDecimal): Unit = {
            require(inRange(value), s"In FixPoint, ${value} can not fit in fix point binary with width=${bits.getWidth} and fw=${fw}.")
            this.bits := (value * BigDecimal(2.0).pow(fw)).setScale(0, BigDecimal.RoundingMode.HALF_UP).toBigInt.asSInt
        }

        /**
         * @param sint assign a SInt to integer part and clear fractional part.
         * @note
         */
        final def :=(sint: SInt): Unit = {
            this.bits := (sint << fw)
        }

        /**
         * @param that assign another FixPoint
         */
        final def :=(that: FixPoint): Unit = {
            val bits = {
                if (this.fw > that.fw) that.bits << (this.fw - that.fw)
                else if (this.fw < that.fw) that.bits >> (that.fw - this.fw)
                else that.bits
            }
            this.bits := bits
        }

        private def matchPoint(that: FixPoint): (SInt, SInt, Int) = {
            val fw = math.max(this.fw, that.fw)
            val lBits = (this.bits << (fw - this.fw)).asSInt
            val rBits = (that.bits << (fw - that.fw)).asSInt
            (lBits, rBits, fw)
        }

        final def +(that: FixPoint): FixPoint = {
            val (l, r, fw) = matchPoint(that)
            val bits: SInt = l + r
            new FixPoint(bits, fw)
        }

        final def -(that: FixPoint): FixPoint = {
            val (l, r, fw) = matchPoint(that)
            val bits: SInt = l - r
            new FixPoint(bits, fw)
        }

        final def *(that: FixPoint): FixPoint = {
            val fw = this.fw + that.fw
            val bits: SInt = this.bits * that.bits
            new FixPoint(bits, fw)
        }

        final def ===(that: FixPoint): Bool = {
            val (l, r, _) = matchPoint(that)
            Mux(l === r, true.B, false.B)
        }

        final def =/=(that: FixPoint): Bool = {
            val (l, r, _) = matchPoint(that)
            Mux(l =/= r, true.B, false.B)
        }

        final def <(that: FixPoint): Bool = {
            val (l, r, _) = matchPoint(that)
            Mux(l < r, true.B, false.B)
        }

        final def <=(that: FixPoint): Bool = {
            val (l, r, _) = matchPoint(that)
            Mux(l <= r, true.B, false.B)
        }

        final def >=(that: FixPoint): Bool = {
            val (l, r, _) = matchPoint(that)
            Mux(l >= r, true.B, false.B)
        }

        final def >(that: FixPoint): Bool = {
            val (l, r, _) = matchPoint(that)
            Mux(l > r, true.B, false.B)
        }

        /**
         * Truncate
         *
         * @param newFracWidth Width of fraction part of result
         * @return Truncated result
         */
        def truncate(newFracWidth: Int = 0): FixPoint = {
            require(newFracWidth < fw)
            val shift = fw - newFracWidth
            new FixPoint((this.bits >> shift).asSInt, newFracWidth)
        }

        /**
         * Truncate by rounding
         *
         * @param newFracWidth Width of fraction part of result
         * @return Truncated result
         */
        def round(newFracWidth: Int = 0): FixPoint = {
            require(newFracWidth < fw)
            val shift = fw - newFracWidth
            val bits = Mux(
                this.bits(shift - 1),
                1.S + (this.bits >> shift).asSInt,
                (this.bits >> shift).asSInt
            )
            new FixPoint(bits, newFracWidth)
        }

        /**
         * @return Raw bits of this FixPoint
         */
        def asSInt: SInt = this.bits

        /**
         * @return Raw bits of this FixPoint
         */
        def getBits: SInt = this.bits

        /**
         * @return Convert to SInt by truncate fraction part
         */
        def toSInt: SInt = this.truncate(0).bits

        /**
         * @return Convert to SInt by round fraction part
         */
        def roundToSInt: SInt = this.round(0).bits

        /**
         * @return Peek value as Double
         */
        def peekDouble(): Double = {
            val d = this.bits.peekInt()
            d.toDouble * math.pow(2.0, -fw)
        }

        /**
         * @return Peek value as BigDecimal
         */
        def peekBigDecimal(): BigDecimal = {
            val d = this.bits.peekInt()
            BigDecimal(d) * BigDecimal(2.0).pow(-fw)
        }
    }

    object FixPoint {
        /**
         * Create a Chisel type of FixPoint
         *
         * @param width total width
         * @param fw    fraction width (or binary point position)
         * @return a Chisel type
         */
        def apply(width: Width, fw: Int): FixPoint = {
            new FixPoint(SInt(width), fw)
        }

        /**
         * Create a hardware of FixPoint
         *
         * @param bits Raw bits for Fixpoint hardware, width of bits is the
         *             total width of FixPoint
         * @param fw   fraction width (or binary point position)
         * @return a hardware of FixPoint
         */
        def apply(bits: SInt, fw: Int): FixPoint = {
            val res = Wire(FixPoint(bits.getWidth.W, fw))
            res.bits := bits
            res
        }

        /**
         * Create a hardware of FixPoint
         *
         * @param width total width
         * @param fw    fraction width (or binary point position)
         * @param value double value to be represent
         * @return the FixPoint hardware created
         */
        def apply(width: Width, fw: Int, value: Double): FixPoint = {
            val res = Wire(FixPoint(width, fw))
            res := value
            res
        }

        def lowest(w: Int, fw: Int): Double = {
            -math.pow(2.0, w - 1 - fw)
        }

        def highest(w: Int, fw: Int): Double = {
            math.pow(2.0, w - 1 - fw) - math.pow(2.0, -fw)
        }

        def lowestInBigDecimal(w: Int, fw: Int): BigDecimal = {
            -BigDecimal(2.0).pow(w - 1 - fw)
        }

        def highestInBigDecimal(w: Int, fw: Int): BigDecimal = {
            BigDecimal(2.0).pow(w - 1 - fw) - BigDecimal(2.0).pow(-fw)
        }

        def inRange(w: Int, fw: Int, value: Double): Boolean = {
            lowest(w, fw) <= value && value <= highest(w, fw)
        }

        def inRange(w: Int, fw: Int, value: BigDecimal): Boolean = {
            val low = lowestInBigDecimal(w, fw)
            val high = highestInBigDecimal(w, fw)
            low <= value && value <= high
        }
    }

    implicit class FromDoubleToFixPoint(private val x: Double) extends AnyVal {
        def toFixPoint(width: Width, fw: Int): FixPoint = {
            val res = Wire(FixPoint(width, fw))
            res := x
            res
        }

        def F(width: Width, fw: Int): FixPoint = {
            val res = Wire(FixPoint(width, fw))
            res := x
            res
        }

        def toFixPoint(width: Int, fw: Int): Long = {
            require(width <= 64 && fw < 64)
            require(FixPoint.inRange(width, fw, x))
            (x * math.pow(2.0, fw)).round
        }
    }

    implicit class FromBigDecimalToFixPoint(private val x: BigDecimal) extends AnyVal {
        def toFixPoint(width: Width, fw: Int): FixPoint = {
            val res = Wire(FixPoint(width, fw))
            res := x
            res
        }

        def F(width: Width, fw: Int): FixPoint = {
            val res = Wire(FixPoint(width, fw))
            res := x
            res
        }

        def toFixPoint(width: Int, fw: Int): BigInt = {
            require(width <= 128 && fw < 128)
            require(FixPoint.inRange(width, fw, x))
            (x * BigDecimal(2.0).pow(fw)).setScale(0, BigDecimal.RoundingMode.HALF_UP).toBigInt
        }
    }

    implicit class DoubleUtils(private val x: Double) extends AnyVal {
        // template<typename T = float>
        //         constexpr T PhaseCycle (T x)
        // {
        //     return std::floor((x + (T)M_PI) / (2 * (T)M_PI));
        // }
        def phaseCycle: Double = {
            math.floor((x + math.Pi) / (2.0 * math.Pi))
        }

        // template<typename T = float>
        //         constexpr T PhaseWrap(T x)
        // {
        //     return x - 2 * (T)M_PI * PhaseCycle(x);
        // }
        def phaseWrap: Double = {
            x - 2.0 * math.Pi * phaseCycle
        }

        // template<typename T = float>
        //         constexpr T PhaseUnwrap(T x, T a)
        // {
        //     return x + 2 * (T)M_PI * PhaseCycle(a - x);
        // }
        def phaseUnwrap(a: Double = 0.0): Double = {
            x + 2.0 * math.Pi * (a - x).phaseCycle
        }

        def phaseDiff(y: Double): Double = {
            (x - y).phaseUnwrap()
        }

        // template<typename T = float>
        //         constexpr T Clamp(T x, T l, T h)
        // {
        //     return x > h ? h :
        //             x < l ? l : x;
        // }
        def clamp(l: Double, h: Double): Double = {
            if (x > h) h
            else if (x < l) l
            else x
        }

        def corrod(l: Double, h: Double): Double = {
            if (x > h) x - h
            else if (x < l) x - l
            else 0.0
        }

        // template <typename T>
        // inline T Map2Unit(T x, T l, T h)
        // {
        // return (x - l) / (h - l);
        // }
        def mapRange2Unit(l: Double, h: Double): Double = {
            (x - l) / (h - l)
        }

        // template <typename T>
        // inline T Map2Range(T x, T l, T h)
        // {
        // return x * (h - l) + l;
        // }
        def mapUnit2Range(l: Double, h: Double): Double = {
            x * (h - l) + l
        }

        def mapFromTo(fromL: Double, fromH: Double, toL: Double, toH: Double): Double = {
            (x - fromL) / (fromH - fromL) * (toH - toL) + toL
        }

        // template <typename T>
        // inline T Wrap(T x, T l, T h)
        // {
        // T d = h - l;
        // return x - std::floor((x - l) / d) * d;
        // }
        def wrap(l: Double, h: Double): Double = {
            val d = h - l
            x - math.floor((x - l) / d) * d
        }

        // template <typename T>
        // inline T Unwrp(T x, T l, T h, T a)
        // {
        // T d = (h - l) * (T)0.5;
        // return x - a >  d ? x - (h - l) :
        //         x - a < -d ? x + (h - l) : x;
        // }
        def unwrap(l: Double, h: Double, a: Double = 0.0): Double = {
            val d = (h - l) * 0.5
            if (x - a > d)
                x - (h - l)
            else if (x - a < -d)
                x + (h - l)
            else
                x
        }
    }

    /**
     * Greatest common divisor of 2 integer
     *
     * @param u One integer
     * @param v Another integer
     * @tparam T Type of integers
     * @return GCD of `u` and `v`
     */
    def GCD[T: Integral](u: T, v: T): T = {
        val int = implicitly[Integral[T]]
        import int.mkNumericOps
        if (v == 0) u
        else GCD(v, u % v)
    }

    /**
     * Least common multiple of 2 integer
     *
     * @param u One integer
     * @param v Another integer
     * @tparam T Type of integer
     * @return LCM of `u` and `v`
     */
    def LCM[T: Integral](u: T, v: T): T = {
        val int = implicitly[Integral[T]]
        import int.mkNumericOps
        u * v / GCD(u, v)
    }

    def phaseDiff(x: Double, y: Double): Double = {
        (x - y).phaseUnwrap()
    }

    def asinh(x: Double): Double = {
        import scala.math._
        log(x + sqrt(x * x + 1))
    }

    def acosh(x: Double): Double = {
        import scala.math._
        if (x < 1) Double.NaN
        else log(x + sqrt(x * x - 1))
    }

    def atanh(x: Double): Double = {
        import scala.math._
        if (x.abs >= 1) Double.NaN
        else 0.5 * log((1 + x) / (1 - x))
    }

    def elemWiseDiff[T: Numeric](x: Seq[T], y: Seq[T]): Seq[T] = {
        val num = implicitly[Numeric[T]]
        import num.mkNumericOps
        x.zip(y).map { case (x, y) => x - y }
    }

    def maxAndRms[T: Numeric](x: Seq[T]): (T, Int, Double) = {
        val num = implicitly[Numeric[T]]
        import num._
        val (max, mi, pwr) = x.zipWithIndex.foldLeft((zero, -1, 0.0)) {
            case ((max, mi, pwr), (x, i)) => {
                val abs = x.abs
                val sqr = x.toDouble * x.toDouble
                val (new_max, new_mi) = if (abs > max) (abs, i) else (max, mi)
                (new_max, new_mi, pwr + sqr)
            }
        }
        (max, mi, math.sqrt(pwr / x.length))
    }

    def minAndIndices[T: Numeric](x: Seq[T]): (T, Seq[Int]) = {
        val min = x.min
        val minIndices = x.zipWithIndex.collect{
            case (v, i) if v == min => i
        }
        (min, minIndices)
    }

    def maxAndIndices[T: Numeric](x: Seq[T]): (T, Seq[Int]) = {
        val max = x.max
        val maxIndices = x.zipWithIndex.collect{
            case (v, i) if v == max => i
        }
        (max, maxIndices)
    }

}
