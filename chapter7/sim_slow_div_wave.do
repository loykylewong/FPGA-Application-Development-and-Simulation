onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestSlowDiv/clk
add wave -noupdate /TestSlowDiv/rst
add wave -noupdate -radix unsigned /TestSlowDiv/ddend
add wave -noupdate -radix unsigned /TestSlowDiv/dsor
add wave -noupdate /TestSlowDiv/start
add wave -noupdate -radix unsigned -childformat {{{/TestSlowDiv/quot[7]} -radix unsigned} {{/TestSlowDiv/quot[6]} -radix unsigned} {{/TestSlowDiv/quot[5]} -radix unsigned} {{/TestSlowDiv/quot[4]} -radix unsigned} {{/TestSlowDiv/quot[3]} -radix unsigned} {{/TestSlowDiv/quot[2]} -radix unsigned} {{/TestSlowDiv/quot[1]} -radix unsigned} {{/TestSlowDiv/quot[0]} -radix unsigned}} -subitemconfig {{/TestSlowDiv/quot[7]} {-height 15 -radix unsigned} {/TestSlowDiv/quot[6]} {-height 15 -radix unsigned} {/TestSlowDiv/quot[5]} {-height 15 -radix unsigned} {/TestSlowDiv/quot[4]} {-height 15 -radix unsigned} {/TestSlowDiv/quot[3]} {-height 15 -radix unsigned} {/TestSlowDiv/quot[2]} {-height 15 -radix unsigned} {/TestSlowDiv/quot[1]} {-height 15 -radix unsigned} {/TestSlowDiv/quot[0]} {-height 15 -radix unsigned}} /TestSlowDiv/quot
add wave -noupdate -radix unsigned /TestSlowDiv/rem
add wave -noupdate /TestSlowDiv/valid
add wave -noupdate /TestSlowDiv/busy
add wave -noupdate -divider slow_div
add wave -noupdate -radix unsigned /TestSlowDiv/theSD/bit_cnt
add wave -noupdate /TestSlowDiv/theSD/bit_co
add wave -noupdate -radix unsigned /TestSlowDiv/theSD/ddend
add wave -noupdate -radix unsigned /TestSlowDiv/theSD/dsor
add wave -noupdate -radix unsigned /TestSlowDiv/theSD/quot
add wave -noupdate -radix unsigned /TestSlowDiv/theSD/remainder
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9898200 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 95
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
WaveRestoreZoom {9878300 ps} {9899400 ps}
