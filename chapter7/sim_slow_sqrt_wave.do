onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestSlowSqrt/clk
add wave -noupdate /TestSlowSqrt/rst
add wave -noupdate -radix unsigned -childformat {{{/TestSlowSqrt/sq[15]} -radix unsigned} {{/TestSlowSqrt/sq[14]} -radix unsigned} {{/TestSlowSqrt/sq[13]} -radix unsigned} {{/TestSlowSqrt/sq[12]} -radix unsigned} {{/TestSlowSqrt/sq[11]} -radix unsigned} {{/TestSlowSqrt/sq[10]} -radix unsigned} {{/TestSlowSqrt/sq[9]} -radix unsigned} {{/TestSlowSqrt/sq[8]} -radix unsigned} {{/TestSlowSqrt/sq[7]} -radix unsigned} {{/TestSlowSqrt/sq[6]} -radix unsigned} {{/TestSlowSqrt/sq[5]} -radix unsigned} {{/TestSlowSqrt/sq[4]} -radix unsigned} {{/TestSlowSqrt/sq[3]} -radix unsigned} {{/TestSlowSqrt/sq[2]} -radix unsigned} {{/TestSlowSqrt/sq[1]} -radix unsigned} {{/TestSlowSqrt/sq[0]} -radix unsigned}} -subitemconfig {{/TestSlowSqrt/sq[15]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[14]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[13]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[12]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[11]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[10]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[9]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[8]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[7]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[6]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[5]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[4]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[3]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[2]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[1]} {-height 15 -radix unsigned} {/TestSlowSqrt/sq[0]} {-height 15 -radix unsigned}} /TestSlowSqrt/sq
add wave -noupdate /TestSlowSqrt/start
add wave -noupdate -radix unsigned /TestSlowSqrt/rt
add wave -noupdate -radix unsigned /TestSlowSqrt/rem
add wave -noupdate /TestSlowSqrt/valid
add wave -noupdate -divider {slow sqrt}
add wave -noupdate -radix unsigned /TestSlowSqrt/theSqrt/num
add wave -noupdate -radix unsigned /TestSlowSqrt/theSqrt/sub
add wave -noupdate -radix unsigned /TestSlowSqrt/theSqrt/bm
add wave -noupdate -radix unsigned /TestSlowSqrt/theSqrt/res
add wave -noupdate -radix unsigned /TestSlowSqrt/crt
add wave -noupdate -radix unsigned /TestSlowSqrt/crem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5047100 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 71
configure wave -valuecolwidth 39
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
WaveRestoreZoom {5030300 ps} {5052300 ps}
