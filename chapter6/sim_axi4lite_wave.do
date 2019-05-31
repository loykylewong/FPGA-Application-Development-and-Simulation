onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestAxi4Lite/theIf/clk
add wave -noupdate /TestAxi4Lite/theIf/reset_n
add wave -noupdate -radix unsigned /TestAxi4Lite/theIf/araddr
add wave -noupdate /TestAxi4Lite/theIf/arprot
add wave -noupdate /TestAxi4Lite/theIf/arvalid
add wave -noupdate /TestAxi4Lite/theIf/arready
add wave -noupdate -radix decimal /TestAxi4Lite/theIf/rdata
add wave -noupdate /TestAxi4Lite/theIf/rresp
add wave -noupdate /TestAxi4Lite/theIf/rvalid
add wave -noupdate /TestAxi4Lite/theIf/rready
add wave -noupdate -radix unsigned /TestAxi4Lite/theIf/awaddr
add wave -noupdate /TestAxi4Lite/theIf/awprot
add wave -noupdate /TestAxi4Lite/theIf/awvalid
add wave -noupdate /TestAxi4Lite/theIf/awready
add wave -noupdate -radix decimal /TestAxi4Lite/theIf/wdata
add wave -noupdate /TestAxi4Lite/theIf/wstrb
add wave -noupdate /TestAxi4Lite/theIf/wvalid
add wave -noupdate /TestAxi4Lite/theIf/wready
add wave -noupdate /TestAxi4Lite/theIf/bresp
add wave -noupdate /TestAxi4Lite/theIf/bvalid
add wave -noupdate /TestAxi4Lite/theIf/bready
add wave -noupdate -radix hexadecimal -childformat {{{/TestAxi4Lite/theSla/raddr_reg[2]} -radix hexadecimal} {{/TestAxi4Lite/theSla/raddr_reg[1]} -radix hexadecimal} {{/TestAxi4Lite/theSla/raddr_reg[0]} -radix hexadecimal}} -subitemconfig {{/TestAxi4Lite/theSla/raddr_reg[2]} {-height 15 -radix hexadecimal} {/TestAxi4Lite/theSla/raddr_reg[1]} {-height 15 -radix hexadecimal} {/TestAxi4Lite/theSla/raddr_reg[0]} {-height 15 -radix hexadecimal}} /TestAxi4Lite/theSla/raddr_reg
add wave -noupdate -radix hexadecimal -childformat {{{/TestAxi4Lite/theSla/waddr_reg[2]} -radix hexadecimal} {{/TestAxi4Lite/theSla/waddr_reg[1]} -radix hexadecimal} {{/TestAxi4Lite/theSla/waddr_reg[0]} -radix hexadecimal}} -subitemconfig {{/TestAxi4Lite/theSla/waddr_reg[2]} {-height 15 -radix hexadecimal} {/TestAxi4Lite/theSla/waddr_reg[1]} {-height 15 -radix hexadecimal} {/TestAxi4Lite/theSla/waddr_reg[0]} {-height 15 -radix hexadecimal}} /TestAxi4Lite/theSla/waddr_reg
add wave -noupdate -radix decimal -childformat {{{/TestAxi4Lite/regs[0]} -radix decimal} {{/TestAxi4Lite/regs[1]} -radix decimal} {{/TestAxi4Lite/regs[2]} -radix decimal} {{/TestAxi4Lite/regs[3]} -radix decimal} {{/TestAxi4Lite/regs[4]} -radix decimal} {{/TestAxi4Lite/regs[5]} -radix decimal} {{/TestAxi4Lite/regs[6]} -radix decimal} {{/TestAxi4Lite/regs[7]} -radix decimal}} -expand -subitemconfig {{/TestAxi4Lite/regs[0]} {-height 15 -radix decimal} {/TestAxi4Lite/regs[1]} {-height 15 -radix decimal} {/TestAxi4Lite/regs[2]} {-height 15 -radix decimal} {/TestAxi4Lite/regs[3]} {-height 15 -radix decimal} {/TestAxi4Lite/regs[4]} {-height 15 -radix decimal} {/TestAxi4Lite/regs[5]} {-height 15 -radix decimal} {/TestAxi4Lite/regs[6]} {-height 15 -radix decimal} {/TestAxi4Lite/regs[7]} {-height 15 -radix decimal}} /TestAxi4Lite/regs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16300 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 115
configure wave -valuecolwidth 86
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 7500
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {83200 ps}
