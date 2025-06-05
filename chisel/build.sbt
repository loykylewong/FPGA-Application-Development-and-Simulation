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

ThisBuild / version := "0.1.0"
ThisBuild / organization := "loywong"
Test / parallelExecution := false   // run test cases one by one

val chiselProjectName = "fpga_book_2017_chisel"
val targetVerilogDir = "verilog"

resolvers ++= Seq(
    "Aliyun Maven" at "https://maven.aliyun.com/repository/public",
    "Huawei Cloud" at "https://repo.huaweicloud.com/repository/maven/",
    Resolver.mavenLocal
)
externalResolvers := Resolver.combineDefaultResolvers(
    resolvers.value.toVector,
    mavenCentral = false  // Disable default Maven Central
)

scalacOptions ++= Seq(
    "-deprecation",
    "-feature",
    "-unchecked",
    // "-Xfatal-warnings",
    // "-Xcheckinit",
    // "-Ymacro-annotations",
    "-language:reflectiveCalls",
)

// ---- use chisel from org.chipsalliance ----
scalaVersion := "2.13.14"
val chiselVersion = "6.6.0"
val chiseltestVersion = "6.0.0"
addCompilerPlugin("org.chipsalliance" % "chisel-plugin" % chiselVersion cross CrossVersion.full)
libraryDependencies += "org.chipsalliance" %% "chisel" % chiselVersion
libraryDependencies += "edu.berkeley.cs" %% "chiseltest" % chiseltestVersion

// ---- use chisel from edu.berkeley.cs ----
// scalaVersion := "2.13.14"
// val chiselVersion = "3.6.1"
// val chiseltestVersion = "0.6.2"
// addCompilerPlugin("edu.berkeley.cs" %% "chisel3-plugin" % chiselVersion cross CrossVersion.full)
// libraryDependencies += "edu.berkeley.cs" %% "chisel3" % chiselVersion
// libraryDependencies += "edu.berkeley.cs" %% "chiseltest" % chiseltestVersion

// ---- other libs ----
libraryDependencies += "org.apache.commons" % "commons-math3" % "3.6.1"

// ---- extra source dir and test source dir ----
// extra source dir, if needed
// Compile / unmanagedSourceDirectories += baseDirectory.value / "external_src_dir"
// extra test source dir, if needed
// Test / unmanagedSourceDirectories += baseDirectory.value / "external_test_src_dir"

// ---- project build infos ----
enablePlugins(BuildInfoPlugin)
val buildInfo_chiselProjectName = BuildInfoKey("chiselProjectName", chiselProjectName)
val buildInfo_chiselVersion = BuildInfoKey("chiselVersion", chiselVersion)
val buildInfo_chiseltestVersion = BuildInfoKey("chiseltestVersion", chiseltestVersion)
val buildInfo_targetVerilogDir = BuildInfoKey("targetVerilogDir", targetVerilogDir)
buildInfoKeys := Seq[BuildInfoKey](
    name, version, scalaVersion, sbtVersion,
    buildInfo_chiselProjectName,
    buildInfo_chiselVersion,
    buildInfo_chiseltestVersion,
    buildInfo_targetVerilogDir)
buildInfoPackage := "ProjectInfo"
