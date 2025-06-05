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

import chisel3.RawModule
import circt.stage.{ChiselStage, FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation

import java.nio.file.{Files, Paths}
import scala.util.matching.Regex
import loywong._
import loywong.examples._

object gen_verilog extends App {
    
    /**
     * Top level module(s) specified here.
     */
    val genModules = Array[() => RawModule](
        () => new test_fp,
        () => new encoder_example(),
        () => new decoder_example(),
        () => new shift_reg_example,
        () => new delay_chain_example,
        () => new counter_example(),
        () => new counter_oneshot_example(),
        () => new counter_max_example(),
        () => new count_down_example,
        () => new counterHrMinSec,
        () => new accumulator_example,
        () => new spram_example,
        () => new spram_with_init_example,
        () => new spramrf_example,
        () => new spramrf_with_init_example,
        () => new spramwf_example,
        () => new spramra_example,
        () => new sdpram_example,
        () => new sdpramrf_example,
        () => new sdpramwf_example,
        () => new sdpramra_example,
        () => new dpram_example,
        () => new sdcram_example,
        () => new dcram_example,
        () => new scfifo2_example,
        () => new anti_metastable_example,
        () => new edge2en_example,
        () => new ccd_trigger_example,
        () => new ccd_counter_example,
        () => new dcfifo_example,
        () => new str_frs_example,
        () => new str_birs_example,
        () => new hscomb1_example,
        () => new hscomb2_example,
        () => new str_dwc_example,
        () => new str_keep_remover_example,
        () => new str_dcfifo_example,
        () => new str_stage_example_0(),
        () => new str_stage_example_1(),
        () => new str_stage_example_2(),
        () => new Axi4LiteToLocalMemoryMapWrapper(6, 4),
        () => new cordic_example
    )
    
    /**
     * Directory where generated verilog/systemverilog file placed,
     * default using value predefined in build.sbt.
     */
    val targetDir: String = ProjectInfo.BuildInfo.targetVerilogDir
    
    /**
     * Whether generate "old school" verilog for compatible with old hdl
     * synthesis tools. It's useful for directly "Add Module ..." in Vivado
     * block design.
     */
    val genOldSchoolVerilog: Boolean = true
    
    /**
     * Whether generate split files for each module.
     */
    val genSplitFiles: Boolean = false
    
    println("================================")
    println(s"Project Info: ${ProjectInfo.BuildInfo.toString}")
    println("--------------------------------")
    println("Pre-processing...")
    
    private val chiselStageArgs = Array(
        "--target-dir", targetDir,
        "--target", if (genOldSchoolVerilog) "verilog" else "systemverilog",
        if (genSplitFiles) "--split-verilog" else ""
    )
    
    private val chiselStageAnnotations =
        if (genOldSchoolVerilog)
            Seq(
                // ChiselGeneratorAnnotation(genModule),
                FirtoolOption("-strip-debug-info"),
                FirtoolOption("--disable-all-randomization"),
                FirtoolOption("--lowering-options=" +
                        "noAlwaysComb," +
                        "disallowLocalVariables," +
                        "disallowPortDeclSharing," +
                        "disallowPackedArrays," +
                        "disallowPackedStructAssignments"),
                FirtoolOption("--verilog"),
                FirtoolOption("-format=fir")
            )
        else
            Seq(
                // ChiselGeneratorAnnotation(genModule),
                FirtoolOption("-strip-debug-info"),
                FirtoolOption("--disable-all-randomization"),
                FirtoolOption("--lowering-options=" +
                        "disallowLocalVariables," +
                        "disallowPortDeclSharing," +
                        "explicitBitcast"),
                FirtoolOption("-format=fir")
            )
    
    println("Done.")
    println("--------------------------------")
    println("Emitting Verilog...")
    
    genModules.zipWithIndex.foreach {
        case (genModule, i) => {
            (new ChiselStage).execute(
                chiselStageArgs,
                Seq(ChiselGeneratorAnnotation(genModule)) ++ chiselStageAnnotations
            )
            println(s"${1+i}/${genModules.length} done.")
        }
    }
    
    println("Done.")
    println("--------------------------------")
    println("Post-processing...")
    
    /**
     * In which file(s), chisel style AXI4, AXI4-Lite and AXI4-Stream IO ports
     * name will be renamed to AMBA & Vivado IP conventions.
     */
    val filesToBeRenamed = List(
        "str_frs_example",
        "Axi4LiteToLocalMemoryMapWrapper_64x32"
    ).map(targetDir + "/" + _)
    RenamePorts2AmbaConventions(false, filesToBeRenamed: _*)
    
    println("Done.")
    println("================================")
}

object RenamePorts2AmbaConventions {
    /**
     * rename ports to AMBA conventions,
     * see `RenamePorts2AmbaConventions.md` for details.
     * @param deleteOriginal whether delete original file(s)
     * @param files          in these files (file names with path without
     *                       extension), all eligible identifiers will be
     *                       renamed
     */
    def apply(deleteOriginal: Boolean, files: String*): Unit = {
        
        val axi4sPattern: Regex = """([sm][^\W_]*(_[^\W_]+)*_axis[^\W_]*(_[^\W_]+)*)_(t?(valid|ready)|[^\W_]+_t?(last|data|user|id|keep|strb))\b""".r
        val axi4sReplace: String = "$1_t$5$6"
        val axi4Pattern: Regex = """([sm][^\W_]*(_[^\W_]+)*_(axi|axi[^\W_s][^\W_]*)(_[^\W_]+)*)_(aw|w|b|ar|r)(_[^\W_]+)?_t?(ready|valid|addr|prot|data|strb|resp|id|len|size|burst|lock|cache|qos|region|user)\b""".r
        val axi4Replace: String = "$1_$5$7"
        files.foreach {
            file => {
                val ext: String =
                    if (Files.exists(Paths.get(file + ".v"))) {
                        ".v"
                    }
                    else if (Files.exists(Paths.get(file + ".sv"))) {
                        ".sv"
                    }
                    else {
                        ""
                    }
                if (ext.isEmpty) {
                    println(s"\u001b[33m[warning]\u001b[0m in Rename2AmbaConventions: file \"${file}.v\" or \"${file}.sv\" not found.")
                }
                else {
                    var source = Files.readString(Paths.get(file + ext))
                    source = axi4sPattern.replaceAllIn(source, axi4sReplace)
                    source = axi4Pattern.replaceAllIn(source, axi4Replace)
                    Files.writeString(Paths.get(file + "_renamed" + ext), source)
                    println(s"\u001b[32m[info]\u001b[0m File \"${file}_renamed${ext}\" created.")
                    if (deleteOriginal) {
                        Files.delete(Paths.get(file + ext))
                        println(s"\u001b[32m[info]\u001b[0m File \"${file}${ext}\" deleted.")
                    }
                }
            }
        }
    }
}
