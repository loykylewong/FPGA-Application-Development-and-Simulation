# 《FPGA应用开发和仿真》源码和勘误表

## 说明

此仓库中的内容为《FPGA应用开发和仿真》（机械工业出版社2018年第1版 ISBN:9787111582786）的源码。

The content in this repository are the source code and errata for the book *FPGA Application Development and Simulation* (CHS).

所有SystemVerilog模块均可综合，除了：

1. Testbench模块；
2. 多数FPGA开发工具不支持let表达，可替换为任务;
3. 一些FPGA开发工具不支持参数表达式的解算(比如较老版本的Quartus)，可自行计算后替换。

All modules are synthesizable, EXCEPT:

1. Modules for testbenches;
2. Most FPGA Dev. tools does not support "let" construct, which can be converted to task;
3. Some FPGA Dev. tools (i.e.: old versions of quartus) does not support the evaluation of real parameter expressions, you may calculate and replace them by yourself.

## 源码说明

源码内有Modelsim工程，其工程文件（mpf文件，实为文本文件）内对源文件等的引用采用的是绝对路径，如需要打开mpf工程复现仿真过程，需要先用文本编辑器打开mpf文件，查找替换文件路径至您下载解压后的文件路径。

There ara Modelsim projects(created by ModelSim PE Student Edition 10.4a) in the source code. References to the source files in those project file (".mpf" file, a kind of text file) are absolute paths.
If you need to open a mpf project to reproduce the simulation process, you have to open the mpf file with a text editor, find and replace those file paths to the paths of the files in your computer.