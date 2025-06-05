// temp.scala is used for some temporarily function or unit test

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import loywong._
import loywong.util._
import loywongtest._

/*class temporarilyTests extends AnyFlatSpec with ChiselScalatestTester {
    val x = BigInt("1001_1100_1011_1010_1110_1001_0001".replaceAll("_", ""), 2)
    val ss0 = x.bitSlices(6, 1, 3, 5, 4)
    println(ss0.map(s => f"0x${s}%x"))
    val ss1 = x.bitSlicesByteWise(4, 12, 5)
    println(ss1.map(s => f"0x${s}%02x"))
}*/