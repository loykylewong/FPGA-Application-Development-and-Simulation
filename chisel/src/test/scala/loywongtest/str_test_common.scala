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

import scala.util.Random
import scala.collection.Searching._
import scala.collection.mutable.ArrayBuffer
// import scala.reflect.{ClassTag, classTag}
import org.apache.commons.math3.distribution.PoissonDistribution
import loywong._
import loywong.util._

/**
 * A class collects stream signals
 * @param str   the stream io (IrrevocableIO) to be monitored
 * @tparam T    type of `str.bits`, must be inherited from StrBits
 */
abstract class StrMonitorSignals[T <: StrBits](str: IrrevocableIO[T]) {
    private val gapsArray: ArrayBuffer[Int] = ArrayBuffer[Int]()
    private val clksArray: ArrayBuffer[Long] = ArrayBuffer[Long]()
    private var lastClkCnt: Long = 0
    /**
     * Append gap to gapsArray, calculate and append element to clksArray.
     * @param clkCnt    clockStepCount after current beat
     */
    protected def appendGaps(clkCnt: Long): Unit = {
        gapsArray += {
            if(clksArray.isEmpty) clkCnt - lastClkCnt
            else clkCnt - clksArray.last
        }.toInt
        clksArray += clkCnt
        lastClkCnt = clkCnt
    }
    
    private val dataArray: ArrayBuffer[BigInt] = ArrayBuffer[BigInt]()
    private val strbArray: ArrayBuffer[BigInt] = ArrayBuffer[BigInt]()
    private val keepArray: ArrayBuffer[BigInt] = ArrayBuffer[BigInt]()
    private val lastArray: ArrayBuffer[Boolean] = ArrayBuffer[Boolean]()
    private val idArray: ArrayBuffer[Long] = ArrayBuffer[Long]()
    private val destArray: ArrayBuffer[Long] = ArrayBuffer[Long]()
    private val userArray: ArrayBuffer[BigInt] = ArrayBuffer[BigInt]()
    
    // non-removable bytes
    private val byteArray: ArrayBuffer[Byte] = ArrayBuffer[Byte]()
    // strb associated with each non-removable bytes
    private val bStrbArray: ArrayBuffer[Boolean] = ArrayBuffer[Boolean]()
    // id associated to each non-removable bytes
    private val bIdArray: ArrayBuffer[Long] = ArrayBuffer[Long]()
    // dest associated to each non-removable bytes
    private val bDestArray: ArrayBuffer[Long] = ArrayBuffer[Long]()
    // user associated with each non-removable bytes, if applicable
    private val bUserArray: ArrayBuffer[BigInt] = ArrayBuffer[BigInt]()
    
    private val nUserUnitBits = str.bits.userBitsPerDataByte
    private val userUnitMask = (BigInt(1) << nUserUnitBits) - 1
    
    protected def appendSignalsByPeek(): (
            Option[BigInt],     // data
            Option[BigInt],     // strb
            Option[BigInt],     // keep
            Option[Boolean],    // last
            Option[Long],       // id
            Option[Long],       // dest
            Option[BigInt]      // user
            ) = {
        val data = str.bits.peekDataIfExist
        val strb = str.bits.peekStrbIfExist
        val keep = str.bits.peekKeepIfExist
        val last = str.bits.peekLastIfExist
        val id = str.bits.peekIdIfExist
        val dest = str.bits.peekDestIfExist
        val user = str.bits.peekUserIfExist
        appendSignalsManually(data, strb, keep, last, id, dest, user)
        (data, strb, keep, last, id, dest, user)
    }
    
    protected def appendSignalsManually(data: Option[BigInt],
                                        strb: Option[BigInt],
                                        keep: Option[BigInt],
                                        last: Option[Boolean],
                                        id  : Option[Long],
                                        dest: Option[Long],
                                        user: Option[BigInt]): Unit = {
        data.foreach(d => dataArray += d)
        strb.foreach(s => strbArray += s)
        keep.foreach(k => keepArray += k)
        last.foreach(l => lastArray += l)
        id.foreach(i => idArray += i.toLong)
        dest.foreach(d => destArray += d.toLong)
        user.foreach(u => userArray += u)
        val s = strb.getOrElse(str.bits.strbMask)
        val k = keep.getOrElse(str.bits.keepMask)
        val d = data.getOrElse(BigInt(0))
        val i = id.getOrElse(0L)
        val t = dest.getOrElse(0L)
        val u = user.getOrElse(BigInt(0))
        for (b <- 0 until k.bitLength) {
            if (k.testBit(b)) {
                if (str.bits.hasData) {
                    byteArray += ((d >> (8 * b)) & 0xFF).toByte
                    if (str.bits.hasStrb) {
                        bStrbArray += s.testBit(b)
                    }
                }
                if (str.bits.hasId) {
                    bIdArray += i
                }
                if (str.bits.hasDest) {
                    bDestArray += t
                }
                if (str.bits.hasUser) {
                    if (str.bits.asInstanceOf[StrHasUser].userAssociation == StrUserAssociation.SpreadInBytes)
                        bUserArray += (u >> (nUserUnitBits * b)) & userUnitMask
                    else
                        bUserArray += u
                }
            }
        }
    }
    
    def gapsSeq: Seq[Int] = gapsArray.toSeq
    def clksSeq: Seq[Long] = clksArray.toSeq
    def dataSeq: Seq[BigInt] = dataArray.toSeq
    def strbSeq: Seq[BigInt] = strbArray.toSeq
    def keepSeq: Seq[BigInt] = keepArray.toSeq
    def lastSeq: Seq[Boolean] = lastArray.toSeq
    def idSeq: Seq[Long] = idArray.toSeq
    def destSeq: Seq[Long] = destArray.toSeq
    def userSeq: Seq[BigInt] = userArray.toSeq
    
    def byteSeq: Seq[Byte] = byteArray.toSeq
    def bStrbSeq: Seq[Boolean] = bStrbArray.toSeq
    def bIdSeq: Seq[Long] = bIdArray.toSeq
    def bDestSeq: Seq[Long] = bDestArray.toSeq
    def bUserSeq: Seq[BigInt] = bUserArray.toSeq
    
    def clearAllGapsAndSignals(): Unit = {
        gapsArray.clear()
        clksArray.clear()
        dataArray.clear()
        strbArray.clear()
        keepArray.clear()
        lastArray.clear()
        idArray.clear()
        destArray.clear()
        userArray.clear()
        byteArray.clear()
        bStrbArray.clear()
        bIdArray.clear()
        bDestArray.clear()
        bUserArray.clear()
    }
    
    private def checkSeqWithRef[T](ref: Seq[T], arr: ArrayBuffer[T]): Int = {
        var errCnt = math.abs(ref.length - arr.length)
        (0 until math.min(ref.length, arr.length)).foreach(i => {
            if(ref(i) != arr(i))
                errCnt = errCnt + 1
        })
        errCnt
    }
    
    def checkDataSeq(refData: Seq[BigInt]): Int = checkSeqWithRef(refData, dataArray)
    def checkStrbSeq(refStrb: Seq[BigInt]): Int = checkSeqWithRef(refStrb, strbArray)
    def checkKeepSeq(refKeep: Seq[BigInt]): Int = checkSeqWithRef(refKeep, keepArray)
    def checkIdSeq(refId: Seq[Long]): Int = checkSeqWithRef(refId, idArray)
    def checkDestSeq(refDest: Seq[Long]): Int = checkSeqWithRef(refDest, destArray)
    def checkUserSeq(refUser: Seq[BigInt]): Int = checkSeqWithRef(refUser, userArray)

    def checkByteSeq(refBytes: Seq[Byte]): Int = checkSeqWithRef(refBytes, byteArray)
    def checkBStrbSeq(refBStrbs: Seq[Boolean]): Int = checkSeqWithRef(refBStrbs, bStrbArray)
    def checkBIdSeq(refBIds: Seq[Long]): Int = checkSeqWithRef(refBIds, bIdArray)
    def checkBDestSeq(refBDests: Seq[Long]): Int = checkSeqWithRef(refBDests, bDestArray)
    def checkBUserSeq(refBUsers: Seq[BigInt]): Int = checkSeqWithRef(refBUsers, bUserArray)
    
    def totalClocks: Long = clksArray.last + 1
    
    private val dataHexWidth = str.bits.dataBytesCeil * 2
    private val dataFormat = s"d:%0${dataHexWidth}X"
    // private val strbHexWidth = math.ceil(str.bits.strStrbWidth / 4.0).toInt
    // private val strbFormat = s" s:%0${strbHexWidth}X"
    // private val keepHexWidth = math.ceil(str.bits.strKeepWidth / 4.0).toInt
    // private val keepFormat = s" k:%0${keepHexWidth}X"
    private val idHexWidth = math.ceil(str.bits.idWidth / 4.0).toInt
    private val idFormat = s" \u001b[38;2;128;128;128mi:\u001b[0m%0${idHexWidth}X"
    private val destHexWidth = math.ceil(str.bits.destWidth / 4.0).toInt
    private val destFormat = s" \u001b[38;2;128;128;128md:\u001b[0m%0${destHexWidth}X"
    private val userHexWidth = math.ceil(str.bits.userWidth / 4.0).toInt
    private val userFormat = s" \u001b[38;2;128;128;128mu:\u001b[0m%0${userHexWidth}X"
    private val emptyStringLen = /*2 +*/ dataHexWidth +
            // { if(str.bits.hasStrb) 3 + strbHexWidth else 0 } +
            // { if(str.bits.hasKeep) 3 + keepHexWidth else 0 } +
            // { if(str.bits.hasLast) 2 else 0 } +
            { if(str.bits.hasId) 3 + idHexWidth else 0 } +
            { if(str.bits.hasDest) 3 + destHexWidth else 0 } +
            { if(str.bits.hasUser) 3 + userHexWidth else 0 }
    private val emptyFormat = s"%${emptyStringLen}s"
    
    private def appendDataString(sigStr: StringBuilder, data: BigInt, strb: BigInt, keep: BigInt, last: Boolean): Unit = {
        if(last) {
            sigStr.append("\u001b[7m")
        }
        for(i <- str.bits.dataBytesCeil - 1 to 0 by -1) {
            if(!keep.testBit(i)) {
                // gray
                sigStr.append("\u001b[38;2;128;128;128m%02X\u001b[0m".format((data >> (i * 8)) & 0xFF))
            }
            else if(!strb.testBit(i)) {
                // normal
                sigStr.append("%02X\u001b[0m".format((data >> (i * 8)) & 0xFF))
            }
            else {
                // bold
                sigStr.append("\u001b[1m%02X\u001b[0m".format((data >> (i * 8)) & 0xFF))
            }
        }
    }

    /**
     * convert signals in the `nClock`-th clock cycle to human-readable string,
     * in which:
     *
     *  - data is printed in hex, byte:
     *
     *  is gray if associated keep is low;
     *
     *  is normal if associated keep is high and strb is low;
     *
     *  is bold if associated keep and strb are both high.
     *
     *  - id, dest and user are printed in hex with prefix `i:`, `d:` and `u:`.
     *
     * @param nClock    signals in which cycle to be converted
     * @return          human-readable string
     */
    def signalStringOfClock(nClock: Long): String = {
        val sigStr = new StringBuilder()
        clksArray.search(nClock) match {
            case Found(i) => {
                val strb = if(str.bits.hasStrb) strbArray(i) else str.bits.strbMask
                val keep = if(str.bits.hasKeep) keepArray(i) else str.bits.keepMask
                val last = if(str.bits.hasLast) lastArray(i) else false
                appendDataString(sigStr, dataArray(i), strb, keep, last)
                sigStr.append(
                    if (str.bits.hasId) {
                        idFormat.format(idArray(i))
                    } else ""
                )
                sigStr.append(
                    if (str.bits.hasDest) {
                        destFormat.format(destArray(i))
                    } else ""
                )
                sigStr.append(
                    if (str.bits.hasUser) {
                        userFormat.format(userArray(i))
                    } else ""
                )
                sigStr.toString()
            }
            case _ => {
                emptyFormat.format("")
            }
        }
    }
}

/**
 * A stream source for test-bench.
 * @param clk   Clock associated with stream IO (IrrevocableIO)
 * @param ds    Down-stream IO to be tested
 * @tparam T    Type of bits in IrrevocableIO
 */
class StrTestSource[T <: StrHasData](clk: Clock, ds: IrrevocableIO[T])
extends StrMonitorSignals[T](ds) {
    
    ds.valid.poke(false)

    private val bytesPerBeat = ds.bits.dataBytesCeil
    private val strbMask = (BigInt(1) << bytesPerBeat) - 1
    private val keepMask = (BigInt(1) << bytesPerBeat) - 1
    private val userUnitWidth = ds.bits.userBitsPerDataByte
    private val userUnitMask = (BigInt(1) << userUnitWidth) - 1

    private var poisson = new PoissonDistribution(1.0)
    private var fixedInterval = 0
    private var isRandomInterval = false

    def setThrottle(isRandomThrottle: Boolean, throttleRatio: Double): Unit = {
        poisson = new PoissonDistribution(if (throttleRatio <= 0.0) Double.MinPositiveValue else throttleRatio)
        fixedInterval = math.round(throttleRatio).toInt
        isRandomInterval = isRandomThrottle
    }

    private var genRandomKeep = false
    private var randomKeepDensity = 0.5
    
    /**
     * Enable random keep generation in `sendBeatsByBytes`
     * @param desireDensity desire keep bit density (duty of non-removable
     *                      bytes)
     *                      - if `strbSeq`, `keepSeq`, `idSeq` and `destSeq`
     *                      are empty in `sendBeatsByBytes`, `desireDensity`
     *                      take effects;
     *                      - otherwise, actual density will be overridden by
     *                      `byteSeq.length / (totalBeats * nBytesOfData)`, in
     *                      which totalBeats = length of `strbSeq`, `keepSeq`,
     *                      `idSeq` or `destSeq`
     * @note if random keep generation enabled and `keepSeq` is not empty in
     *       `sendBeatsByBytes`, elements in `keepSeq` will be overridden by
     *       generated random keep.
     * @note OBSOLETE, use:
     *       1. randomBytes(), randomBStrbs(), randomBUsers() and.
     *       1. convertBytesToBeats() and,
     *       1. sendBeats() instead.
     */
    def enableRandomKeep(desireDensity: Double = 0.5): Unit = {
        require(1.0/256.0 <= desireDensity && desireDensity <= 255.0/256.0)
        require(ds.bits.hasKeep)
        genRandomKeep = true
        randomKeepDensity = desireDensity
    }
    
    /**
     * Disable random keep generation in `sendBeatsByBytes`
     * @note if random keep generation disabled and `keepSeq` is empty in
     *       `sendBeatsByBytes`, `keep` in all beats will be all ones.
     * @note OBSOLETE, use:
     *       1. randomBytes(), randomBStrbs(), randomBUsers() and.
     *       1. convertBytesToBeats() and,
     *       1. sendBeats() instead.
     */
    def disableRandomKeep(): Unit = {
        genRandomKeep = false
    }

    /**
     * Wait a number of clock cycles specified by arg `isRandomThrottle` and
     * arg `throttleRatio` in method `setThrottle`.
     * @return  Actual cycles of clock waited
     */
    private def waitGap(): Int = {
        val interval =
            if (isRandomInterval) poisson.sample()
            else fixedInterval
        if (interval > 0) {
            clk.step(interval)
        }
        interval
    }

    /**
     * Send a transaction beat.
     *
     * @param data  Data to be sent
     * @param last  Whether send a high on last signal if the bits in
     *              IrrevocableIO contains last signal (inherit StrWithLast)
     * @param keep  Keep signal to be sent, default all ones, if the bits in
     *              IrrevocableIO contains keep signal (inherit StrWithKeep)
     * @return      Clock cycles spent on waiting ready signal
     */
    private def sendBeat(data: BigInt,
                         strb: BigInt = strbMask,
                         keep: BigInt = keepMask,
                         last: Boolean = false,
                         id  : Long = 0L,
                         dest: Long = 0L,
                         user: BigInt = BigInt(0)
                        ): Int = {
        
        val d = ds.bits.pokeDataIfExist(data)
        val l = ds.bits.pokeLastIfExist(last)
        val s = ds.bits.pokeStrbIfExist(strb)
        val k = ds.bits.pokeKeepIfExist(keep)
        val i = ds.bits.pokeIdIfExist(id)
        val t = ds.bits.pokeDestIfExist(dest)
        val u = ds.bits.pokeUserIfExist(user)
        
        appendSignalsManually(d, s, k, l, i, t, u)
        
        ds.valid.poke(true)
        var gap = 0
        while (!ds.ready.peekBoolean()) {
            clk.step(1)
            gap = gap + 1
        }
        clk.step(1)
        ds.valid.poke(false)
        
        appendGaps(clk.getStepCount)
        
        gap
    }
    
    private def prepareDataByKeep(bytes: Seq[Byte], currIdx: Int, keep: BigInt): (BigInt, Int) = {
        var idx = currIdx
        var data: BigInt = 0
        for (b <- 0 until bytesPerBeat) {
            if(keep.testBit(b)) {
                data = data | (BigInt(bytes(idx) & 0xFF) << (b * 8))
                idx = idx + 1
            }
        }
        (data, idx)
    }
    
    private def prepareUserByKeep(users: Seq[BigInt], currIdx: Int, keep: BigInt): (BigInt, Int) = {
        var idx = currIdx
        var user: BigInt = 0
        for (b <- 0 until bytesPerBeat) {
            if(keep.testBit(b)) {
                user = user | (users(idx) << (b * userUnitWidth))
                idx = idx + 1
            }
        }
        (user, idx)
    }
    
    private def randBigInt(nBits: Int): BigInt = {
        val r = (0 until nBits by 32).foldLeft(BigInt(0))(
            (acc, i) => acc | (BigInt(Random.nextInt() & 0xFFFFFFFFL) << i)
        )
        r & ((BigInt(1) << nBits) - 1)
    }
    def randomBytes(nBytes: Int): Seq[Byte] = {
        Random.nextBytes(nBytes).toSeq
    }
    def randomBStrbs(nBytes: Int, density: Double = 1.0): Seq[Boolean] = {
        val thr = math.round(nBytes * density).toInt
        Random.shuffle((0 until nBytes).toList).map(i => i < thr)
    }
    def randomBUsers(nBytes: Int, unitWidth: Int = userUnitWidth): Seq[BigInt] = {
        require(unitWidth > 0)
        Seq.fill(nBytes)(randBigInt(unitWidth))
    }
    def randomData(nBeats: Int): Seq[BigInt] = {
        Seq.fill(nBeats)(randBigInt(ds.bits.dataWidth))
    }
    def randomStrbs(nBeats: Int, bytesPerBeat: Int = bytesPerBeat, density: Double = 1.0): Seq[BigInt] = {
        require(bytesPerBeat > 0)
        val nBytes = nBeats * bytesPerBeat
        val strbMask = (BigInt(1) << bytesPerBeat) - 1
        val strb = Array.fill(nBeats)(strbMask)
        randomBStrbs(nBytes, density).zipWithIndex.foreach { case(b, i) =>
            val beatIdx = i / bytesPerBeat
            val bitPos = i % bytesPerBeat
            if(!b)
                strb(beatIdx) = strb(beatIdx) & ~(BigInt(1) << bitPos)
        }
        strb.toSeq
    }
    def randomIds(nBeats: Int, width: Int = ds.bits.idWidth, immutablePeriod: Int = 1): Seq[Long] = {
        require(width > 0)
        require(immutablePeriod > 0)
        require(nBeats % immutablePeriod == 0)
        var lastRand = 0L
        Seq.tabulate(nBeats)( i => {
            if (i % immutablePeriod == 0) {
                lastRand = Random.nextLong() & ((1L << width) - 1)
                lastRand
            }
            else lastRand
        })
    }
    def randomDests(nBeats: Int, width: Int = ds.bits.destWidth, immutablePeriod: Int = 1): Seq[Long] = {
        require(width > 0)
        require(immutablePeriod > 0)
        require(nBeats % immutablePeriod == 0)
        var lastRand = 0L
        Seq.tabulate(nBeats)( i => {
            if (i % immutablePeriod == 0) {
                lastRand = Random.nextLong() & ((1L << width) - 1)
                lastRand
            }
            else lastRand
        })
    }
    def randomUsers(nBeats: Int, width: Int = ds.bits.userWidth, immutablePeriod: Int = 1): Seq[BigInt] = {
        require(width > 0)
        require(immutablePeriod > 0)
        require(nBeats % immutablePeriod == 0)
        var lastRand = BigInt(0)
        Seq.tabulate(nBeats)(i => {
            if (i % immutablePeriod == 0) {
                lastRand = randBigInt(width)
                lastRand
            }
            else lastRand
        })
    }
    
    /**
     * Convert non-removable bytes, associated strb and user to beats.
     * @param nBeats    Number of desired beats, if `bytes.length < nDataBytes
     *                  * nBeats`, random keep will be generated, otherwise,
     *                  keep will be all ones.
     * @param bytes     Non-removable bytes
     * @param strb      Strb(s) associated with each byte in `bytes`
     * @param user      User(s) associated with each byte in `bytes`
     * @return
     */
    def convertBytesToBeats(nBeats: Int,
                            bytes: Seq[Byte],
                            strb: Seq[Boolean] = Seq.empty[Boolean],
                            user: Seq[BigInt] = Seq.empty[BigInt]
                           ): (Seq[BigInt], Seq[BigInt], Seq[BigInt], Seq[BigInt]) = {
        
        require(bytes.nonEmpty)
        require(strb.isEmpty || strb.length == bytes.length)
        require(user.isEmpty || user.length == bytes.length)
        
        val minBeats = (bytes.length - 1) / bytesPerBeat + 1
        val totalBeats = math.max(nBeats, minBeats)
        val totalRawBytes = totalBeats * bytesPerBeat
        val totalKeepBytes = bytes.length
        
        val dataArray = Array.fill(totalBeats)(BigInt(0))
        val strbArray = Array.fill(totalBeats)(strbMask)
        val keepArray = Array.fill(totalBeats)(keepMask)
        val userArray = Array.fill(totalBeats)(BigInt(0))
        
        val kbits = Random.shuffle((0 until totalRawBytes).toList).map(i => i < totalKeepBytes)
        kbits.zipWithIndex.foreach {
            case (k, i) => if(!k) {
                val beatIdx = i / bytesPerBeat
                val byteIdx = i % bytesPerBeat
                keepArray(beatIdx) = keepArray(beatIdx) & ~(BigInt(1) << byteIdx)
            }
        }
        // val nrbytes = keepArray.foldLeft(0)((acc, k) => acc + k.popCount)
        // require(nrbytes == totalKeepBytes)
        
        var byteIdx = 0
        keepArray.zipWithIndex.foreach { case(keep, beatIdx) =>
            for (i <- 0 until bytesPerBeat) {
                if (keep.testBit(i)) {
                    dataArray(beatIdx) = dataArray(beatIdx) | (BigInt(bytes(byteIdx) & 0xFF) << (i * 8))
                    if(strb.nonEmpty && !strb(byteIdx))
                        strbArray(beatIdx) &= ~(BigInt(1) << i)
                    if(user.nonEmpty)
                        userArray(beatIdx) = userArray(beatIdx) | ((user(byteIdx) & userUnitMask) << (i * userUnitWidth))
                    byteIdx += 1
                }
            }
        }
        // require(byteIdx == bytes.length)
        (dataArray.toSeq, strbArray.toSeq, keepArray.toSeq, userArray.toSeq)
    }

    /**
     * Send beats by given signals of each beat.
     *
     * @param genLastAtLastBeat Whether generating last at the last beat,
     *                          this requires io.bits has last.
     * @param dataSeq           Contains data to be sent in each beat.
     * @param strbSeq           Contains strb to be sent in each beat,
     *                          default empty and all ones will be sent.
     * @param keepSeq           Contains keep to be sent in each beat,
     *                          default empty and all ones will be sent.
     * @param idSeq             Contains id to be sent in each beat,
     *                          default empty and all zeros will be sent.
     * @param destSeq           Contains dest to be sent in each beat,
     *                          default empty and all zeros will be sent.
     * @param userSeq           Contains user to be sent in each beat
     *                          default empty and all zeros will be sent.
     * @note
     *          1. When ds.bits contains no strb, keep, id, dest or user,
     *          corresponding Seq(s) will be ignored.
     *          1. If a Seq is not empty, its length must be equal to dataSeq.
     *          1. Total number of beats is equal to length of dataSeq.
     *          1. If random data needed, use:
     *              I. randomData(), randomStrbs(), randomIds(), randomDests()
     *              and/or randomUsers(), if keep is not needed;
     *              I. randomBytes(), randomBStrbs() and/or randomBUsers() with
     *              convertBytesToBeats(), if keep is needed.
     */
    def sendBeats(genLastAtLastBeat: Boolean,
                  dataSeq: Seq[BigInt] = Seq.empty[BigInt],
                  strbSeq: Seq[BigInt] = Seq.empty[BigInt],
                  keepSeq: Seq[BigInt] = Seq.empty[BigInt],
                  idSeq: Seq[Long] = Seq.empty[Long],
                  destSeq: Seq[Long] = Seq.empty[Long],
                  userSeq: Seq[BigInt] = Seq.empty[BigInt]): TesterThreadList = {

        if (genLastAtLastBeat) require(ds.bits.hasLast)
        require(strbSeq.isEmpty || strbSeq.length == dataSeq.length)
        require(keepSeq.isEmpty || keepSeq.length == dataSeq.length)
        require(idSeq.isEmpty || idSeq.length == dataSeq.length)
        require(destSeq.isEmpty || destSeq.length == dataSeq.length)
        require(userSeq.isEmpty || userSeq.length == dataSeq.length)

        clearAllGapsAndSignals()

        val thread = fork {
            dataSeq.zipWithIndex.foreach {
                case (d, i) => {
                    val last = (i == dataSeq.length - 1) && genLastAtLastBeat
                    val strb = if (strbSeq.isEmpty) strbMask else strbSeq(i)
                    val keep = if (keepSeq.isEmpty) keepMask else keepSeq(i)
                    val id = if (idSeq.isEmpty) 0L else idSeq(i)
                    val dest = if (destSeq.isEmpty) 0L else destSeq(i)
                    val user = if (userSeq.isEmpty) BigInt(0) else userSeq(i)
                    waitGap()
                    sendBeat(d, strb, keep, last, id, dest, user)
                }
            }
        }
        thread
    }

    /**
     * Send beats by given non-removable bytes.
     *
     * @param genLastAtLastBeat Whether generating last at the last beat,
     *                          this requires io.bits has last
     * @param byteSeq           Contains valid data bytes to be sent
     * @param strbSeq           Contains strb to be sent in each beat,
     *                          default empty, all ones will be sent
     * @param keepSeq           Contains keep to be sent in each beat,
     *                          default empty, all ones will be sent
     * @param idSeq             Contains id to be sent in each beat,
     *                          default empty, all zeros will be sent
     * @param destSeq           Contains dest to be sent in each beat,
     *                          default empty, all zeros will be sent
     * @param userSeq           Contains user to be sent associated with data
     *                          bytes, length must be equal to length of
     *                          byteSeq, default empty, all zeros will be sent
     * @note
     *          - When ds.bits contains no strb, keep, id, dest or user, Seq(s)
     *          will be ignored.
     *          - {{{
     *              total_num_of_beats =
     *                  if (strbSeq.nonEmpty) strbSeq.length
     *                  else if (keepSeq.nonEmpty) keepSeq.length
     *                  else if (idSeq.nonEmpty)   idSeq.length
     *                  else if (destSeq.nonEmpty) destSeq.length
     *                  else if(!genRandomKeep)
     *                      byteSeq.length / bytesPerBeat
     *                  else
     *                      ceil( byteSeq.length
     *                            / randomKeepDensity
     *                            / bytesPerBeat)
     *          }}}
     *          - When keepSeq is not empty, total count of high bit in keepSeq
     *          must be equal to length of dataSeq
     *          - When random keep enabled, elements in keepSeq is ignored
     *
     * @note OBSOLETE, since it's too difficult to use, use:
     *       1. convertBytesToBeats() and,
     *       1. sendBeats() instead.
     *
     *       if random data needed, user randomBytes(), randomBStrbs() and/or
     *       randomBUsers() first.
     */
    def sendBeatsByBytes(genLastAtLastBeat: Boolean,
                  byteSeq: Seq[Byte] = Seq.empty[Byte],
                  strbSeq: Seq[BigInt] = Seq.empty[BigInt],
                  keepSeq: Seq[BigInt] = Seq.empty[BigInt],
                  idSeq: Seq[Long] = Seq.empty[Long],
                  destSeq: Seq[Long] = Seq.empty[Long],
                  userSeq: Seq[BigInt] = Seq.empty[BigInt]): TesterThreadList = {

        require(ds.bits.userWidth % bytesPerBeat == 0)

        if (genLastAtLastBeat) require(ds.bits.hasLast)
        val (totalBeats, totalRawBytes) = {
            if (strbSeq.nonEmpty)
                (strbSeq.length, strbSeq.length * bytesPerBeat)
            else if (keepSeq.nonEmpty)
                (keepSeq.length, keepSeq.length * bytesPerBeat)
            else if (idSeq.nonEmpty)
                (idSeq.length, idSeq.length * bytesPerBeat)
            else if (destSeq.nonEmpty)
                (destSeq.length, destSeq.length * bytesPerBeat)
            else if(!genRandomKeep) {
                val beats = (byteSeq.length - 1) / bytesPerBeat + 1
                val rawBytes = beats * bytesPerBeat
                (beats, rawBytes)
            }
            else {
                val beats = math.ceil(byteSeq.length / randomKeepDensity / bytesPerBeat).toInt
                val rawBytes = beats * bytesPerBeat
                (beats, rawBytes)
            }
        }
        val totalKeepBytes = {
            if (genRandomKeep)
                byteSeq.length
            else if (keepSeq.nonEmpty)
                keepSeq.foldLeft(0)((acc, k) => acc + k.popCount)
            else
                totalRawBytes
        }

        require(totalKeepBytes <= totalRawBytes)
        require(byteSeq.length == totalKeepBytes)
        require(strbSeq.isEmpty || strbSeq.length == totalBeats)
        require(keepSeq.isEmpty || keepSeq.length == totalBeats)
        require(idSeq.isEmpty || idSeq.length == totalBeats)
        require(destSeq.isEmpty || destSeq.length == totalBeats)
        require(userSeq.isEmpty || userSeq.length == totalKeepBytes)

        clearAllGapsAndSignals()

        val actKeepSeq =
            if(!genRandomKeep) keepSeq
            else {
                val ks: Array[BigInt] = Array.fill[BigInt](totalBeats)(BigInt(0))
                val ki = scala.util.Random.shuffle((0 until totalRawBytes).toList).take(totalKeepBytes)
                ki.foreach {
                    i => {
                        ks(i / bytesPerBeat) = ks(i / bytesPerBeat).setBit(i % bytesPerBeat)
                    }
                }
                ks.toSeq
            }

        val thread = fork {
            var byteIdx = 0
            var userIdx = 0
            (0 until totalBeats).foreach {
                i => {
                    val last = (i == totalBeats - 1) && genLastAtLastBeat
                    val strb = if (strbSeq.isEmpty) strbMask else strbSeq(i)
                    val keep = if (actKeepSeq.isEmpty) keepMask else actKeepSeq(i)
                    val id = if (idSeq.isEmpty) 0L else idSeq(i)
                    val dest = if (destSeq.isEmpty) 0L else destSeq(i)
                    val (data, bIdx) = prepareDataByKeep(byteSeq, byteIdx, keep)
                    val (user, uIdx) = {
                        if (userSeq.isEmpty) (BigInt(0), 0)
                        else prepareUserByKeep(userSeq, userIdx, keep)
                    }
                    waitGap()
                    sendBeat(data, strb, keep, last, id, dest, user)
                    
                    byteIdx = bIdx
                    userIdx = uIdx
                }
            }
        }
        thread
    }
}

/**
 * A stream sink for test-bench.
 * @param clk   Clock associated with stream IO (IrrevocableIO)
 * @param us    Up-stream IO to be tested
 * @tparam T    Type of bits in IrrevocableIO
 */
class StrTestSink[T <: StrHasData](clk: Clock, us: IrrevocableIO[T])
extends StrMonitorSignals[T](us) {

    require(us.bits.data.getWidth % 8 == 0)
    
    us.ready.poke(false)

    private var poisson = new PoissonDistribution(1.0)
    private var fixedInterval = 0
    private var isRandomInterval = false

    def setThrottle(isRandomThrottle: Boolean, throttleRatio: Double): Unit = {
        poisson = new PoissonDistribution(if (throttleRatio <= 0.0) Double.MinPositiveValue else throttleRatio)
        fixedInterval = math.round(throttleRatio).toInt
        isRandomInterval = isRandomThrottle
    }

    // private var dealKeep = true

    /**
     * Wait a number of clock cycles specified by arg `isRandomThrottle` and
     * arg `throttleRatio` in method `setThrottle`
     *
     * @return Actual cycles of clock waited
     */
    private def waitGap(): Int = {
        val interval =
            if (isRandomInterval) poisson.sample()
            else fixedInterval
        if (interval > 0) {
            clk.step(interval)
        }
        interval
    }

    /**
     * Receive a transaction beat.
     *
     * @return (last, gap):
     *         - last: if it's the last beat
     *         - gap: Clock cycles spent on waiting valid signal
     */
    private def recvBeat(): (Boolean, Int) = {
        us.ready.poke(true)
        
        var gap = 0
        while (!us.valid.peekBoolean()) {
            clk.step(1)
            gap = gap + 1
        }
        
        val (_, _, _, last, _, _, _) = appendSignalsByPeek()

        clk.step(1)
        us.ready.poke(false)
        
        appendGaps(clk.getStepCount)
        
        (last.getOrElse(false), gap)
    }

    /**
     * Receive a package by specified beats
     *
     * @param rxBeats Number of beats to be received.
     * @return The TestThread forked, user should use its `join()` method to
     *         wait the received operation finish before using any result
     */
    def recvBeats(rxBeats: Int): TesterThreadList = {
        
        clearAllGapsAndSignals()

        val thread = fork {
            for (i <- 0 until rxBeats) {
                waitGap()
                recvBeat()
            }
        }
        thread
    }

    /**
     * Receive a package to its end specified by the last signal in stream IO
     *
     * @return The TestThread forked, user should use its `join()` method to
     *         wait the received operation finish before using any result
     * @note The type of bits in IrrevocableIO must be inherited from trait
     *       `StrWithLast`
     */
    def recvBeatsToLast(): TesterThreadList = {

        require(us.bits.isInstanceOf[StrHasLast], s"In StrTestSink.recvPkgToLast(), type of bits ${us.bits.typeName} does NOT has last signal, you may prefer to use StrTestSink.recvPkgByNumBeats().")

        clearAllGapsAndSignals()

        val thread = fork {
            var last = false
            while (!last) {
                waitGap()
                val (lastBeat, _) = recvBeat()
                last = lastBeat
            }
        }
        thread
    }
}
