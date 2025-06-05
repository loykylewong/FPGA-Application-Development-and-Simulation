import chisel3._
import loywong.util._

class abcd {
    val _a = Wire(Bool())
    val _b = Wire(Bool())
    val _c = _a ^ _b
    val _d = !(_a ^ _b)
    def con_ac(a: Bool, c: Bool) = {
        _a := a
        c := _c
    }
    def con_bd(b: Bool, d: Bool) = {
        _b := b
        d := _d
    }
}

class test_abcd extends Module {
    //val io = FlatIO(new Bundle {
        val a = IO( Input(Bool()))
        val b = IO( Input(Bool())).suggestName{"bbb"}
        val c = IO(Output(Bool()))
        val d = IO(Output(Bool()))
    //})
    val the_abcd = new abcd
    the_abcd.con_ac(a, c)
    the_abcd.con_bd(b, d)
}

class test_catbytewise extends Module {
    val io = IO(new Bundle {
        val a = Input(UInt(3.W))
        val b = Input(SInt(9.W))
        val c = Input(UInt(8.W))
        val d = Input(SInt(12.W))
        val o = Output(UInt(48.W))
    })
    io.o := CatByteWise(io.d, io.c, io.b, io.a)
}

class test_slices extends Module {
    val io = IO(new Bundle {
        val x = Input(UInt(48.W))
        val a0 = Output(UInt(3.W))
        val b0 = Output(SInt(9.W))
        val c0 = Output(UInt(8.W))
        val d0 = Output(SInt(12.W))
        val a1 = Output(UInt(3.W))
        val b1 = Output(SInt(9.W))
        val c1 = Output(UInt(8.W))
        val d1 = Output(SInt(12.W))
        val a2 = Output(UInt(3.W))
        val b2 = Output(SInt(9.W))
        val c2 = Output(UInt(8.W))
        val d2 = Output(SInt(12.W))
        val a3 = Output(UInt(3.W))
        val b3 = Output(SInt(9.W))
        val c3 = Output(UInt(8.W))
        val d3 = Output(SInt(12.W))
    })
    io.x.sliceTo(io.d0, io.c0, io.b0, io.a0)
    io.x.sliceByteWiseTo(io.d1, io.c1, io.b1, io.a1)

    val sbits = io.x.slice(12, 8, 9, 3)
    io.d2 := sbits(0).asSInt
    io.c2 := sbits(1)
    io.b2 := sbits(2).asSInt
    io.a2 := sbits(3)

    val sbytes = io.x.sliceByteWise(12, 8, 9, 3)
    io.d3 := sbytes(0).asSInt
    io.c3 := sbytes(1)
    io.b3 := sbytes(2).asSInt
    io.a3 := sbytes(3)
}

class test_fp extends Module {
    val io = IO(new Bundle {
        val a = Input(FixPoint(10.W, 8))
        val b = Input(FixPoint(16.W, 12))
        val c = Input(SInt(10.W))
        val i = Input(FixPoint(12.W, 11))
        val q = Input(FixPoint(8.W, 7))
        val add0 = Output(FixPoint(16.W, 12))
        val sub0 = Output(FixPoint(16.W, 12))
        val prod0 = Output(FixPoint(28.W, 16))
        val add1 = Output(FixPoint(12.W, 8))
        val sub1 = Output(FixPoint(12.W, 8))
        val prod1 = Output(FixPoint(15.W, 8))
        val add2 = Output(FixPoint(12.W, 8))
        val sub2 = Output(FixPoint(12.W, 8))
        val prod2 = Output(FixPoint(15.W, 8))
        val ca = Output(FixPoint(16.W, 12))
        val cb = Output(FixPoint(12.W, 8))
        val cc = Output(FixPoint(16.W, 6))
        val c0 = Output(FixPoint(16.W, 15))
        val c1 = Output(FixPoint(16.W, 8))
        val c2 = Output(FixPoint(16.W, 8))
        val mag = Output(FixPoint(12.W, 11))
    })

    // println(s"Q2.8 min: ${io.a.lowest}, max: ${io.a.highest}")

    io.add0 := io.a + io.b
    io.sub0 := io.a - io.b
    io.prod0 := io.a * io.b
    io.add1 := (io.a + io.b).truncate(8)
    io.sub1 := (io.a - io.b).truncate(8)
    io.prod1 := (io.a * io.b).truncate(8)
    io.add2 := (io.a + io.b).round(8)
    io.sub2 := (io.a - io.b).round(8)
    io.prod2 := (io.a * io.b).round(8)
    io.ca := io.a
    io.cb := io.b
    io.cc := io.c
    io.c0 := 0.75
    io.c1 := 12.3
    io.c2 := 12.3.F(16.W, 8)
    // io.c1 := 128.0  // error

    // val zzz = RegInit(new FixPoint(SInt(8.W), 7))

    val xxx = RegInit(FixPoint(0.S(8.W), 7))
    val sqi = RegInit(FixPoint(12.W, 11, 0.5))
    val sqq = RegInit(-0.5.F(8.W, 7))

    val mag = Reg(FixPoint(12.W, 11))

    sqi := (io.i * io.i).truncate(11)
    sqq := (io.q * io.q).truncate(7)
    mag := sqi + sqq
    io.mag := mag
}