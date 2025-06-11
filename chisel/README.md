# About this `chisel` directory

I have started learning Chisel, code in this book will be gradually rewritten in Chisel. However, "rewriting" here does not mean a simple one-to-one translation:

1. Not all modules will be rewritten, commonly used modules will be rewritten first, and uncommon ones may not be rewritten.
2. Some modules may not remain as independent modules after conversion (for example, they may become utility classes).
3. The abstract capabilities and language features of Scala and Chisel (such as traits, generics, collections, etc.) will be used as much as possible.

# HOW TO USE

**All the following steps are tested on Ubuntu 22.04.**

## 1. Install Scala Environment

Below are instructions for Ubuntu users, for users of other linux release versions
steps are similar.

For users of Windows please search, download and run exe or msi
installation files:

1. Java JDK (ref link: https://www.oracle.com/java/technologies/downloads/#java8)
2. Scala (ref link: https://www.scala-lang.org/download/)
3. SBT (ref link: https://www.scala-sbt.org/download/)

And there is no native `verilator` on Windows, it's recommended not using
`verilator` simulation backend on Windows.

### 1.1. Install Java Runtime and SDK

**Scala** is an script lang base on java, so we must install java runtime and SDK first.

```bash
$ apt list openjdk-*-jdk
$ sudo apt install openjdk-<version>-jdk
```

In which "`<version>`" is the latest version list in `apt list` command.

### 1.2. Install Scala and SBT

**Chisel** is a language base on Scala (acturaly libraries and extentions).

#### 1.2.1. Method 1: Use apt

Install scala:

```bash
$ sudo apt install scala
```

Install sbt (ref. https://www.scala-sbt.org/download/):

```bash
$ echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
$ echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
$ curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo tee /etc/apt/trusted.gpg.d/sbt.asc
$ sudo apt update
$ sudo apt install sbt
```

#### 1.2.2. Method 2: download installation exec file and run

Install `curl` fist:

```bash
$ sudo apt install curl
```

Then, follow the instructions on https://www.scala-lang.org/download/, commomly:

```bash
$ curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > cs && chmod +x cs && ./cs setup
```

After installation, we can delete the downloaded installation file `cs`:

```bash
$ rm cs
```

### 1.3. Install Verilator

`Verilator` is an open-source simulation backend much faster than chiseltest itself.

Install verilator:

```bash
$ sudo apt install verilator
```

**CAUTION**: If you are using a newly released version of linux, you may need to manually install the latest version of
Verilator to avoid errors while Verilator compiling HDL to c++, see: https://verilator.org/guide/latest/install.html,
or you can just try running the tests without the Verilator backend, by not using the
`VerilatorBackendAnnotation` in `test().withAnnotations(...)`.

## 2. Compile, Run and Test

Compile chisel and run the code to **generate verilog code**.

Verilog source files will be generated in `verilog` directory, which is specified in `build.sbt` file:

```java
val targetVerilogDir = "verilog"
```

You can change it as you wish.

**Compile**, in the directory where `build.sbt` file is located:

```bash
$ sbt compile
```

**Caution**: It may take a long time to download depencies from *Maven* repositories when first time using `sbt`, just wait.

**Run**, in the directory where `build.sbt` file is located:

```bash
$ sbt run
```

Now, verilog files will be generated in the directory `verilog`.

**Test**:

```bash
$ sbt test
```

If you are using Windows, tests are using `chiseltest` itself which is much
slower than `verilator` used in Linux, you may need to wait a long time
before test finish.
