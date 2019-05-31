onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestSlowMult/clk
add wave -noupdate /TestSlowMult/rst
add wave -noupdate -radix unsigned /TestSlowMult/mcand
add wave -noupdate -radix unsigned /TestSlowMult/mer
add wave -noupdate /TestSlowMult/start
add wave -noupdate -radix unsigned /TestSlowMult/prod
add wave -noupdate /TestSlowMult/valid
add wave -noupdate /TestSlowMult/busy
add wave -noupdate -divider slow_mult
add wave -noupdate /TestSlowMult/theSM/bit_cnt
add wave -noupdate /TestSlowMult/theSM/bit_co
add wave -noupdate -radix unsigned /TestSlowMult/theSM/mcand
add wave -noupdate -radix unsigned -childformat {{{/TestSlowMult/theSM/mer[7]} -radix unsigned} {{/TestSlowMult/theSM/mer[6]} -radix unsigned} {{/TestSlowMult/theSM/mer[5]} -radix unsigned} {{/TestSlowMult/theSM/mer[4]} -radix unsigned} {{/TestSlowMult/theSM/mer[3]} -radix unsigned} {{/TestSlowMult/theSM/mer[2]} -radix unsigned} {{/TestSlowMult/theSM/mer[1]} -radix unsigned} {{/TestSlowMult/theSM/mer[0]} -radix unsigned}} -subitemconfig {{/TestSlowMult/theSM/mer[7]} {-height 15 -radix unsigned} {/TestSlowMult/theSM/mer[6]} {-height 15 -radix unsigned} {/TestSlowMult/theSM/mer[5]} {-height 15 -radix unsigned} {/TestSlowMult/theSM/mer[4]} {-height 15 -radix unsigned} {/TestSlowMult/theSM/mer[3]} {-height 15 -radix unsigned} {/TestSlowMult/theSM/mer[2]} {-height 15 -radix unsigned} {/TestSlowMult/theSM/mer[1]} {-height 15 -radix unsigned} {/TestSlowMult/theSM/mer[0]} {-height 15 -radix unsigned}} /TestSlowMult/theSM/mer
add wave -noupdate -radix unsigned /TestSlowMult/theSM/sum
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10650100 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 97
configure wave -valuecolwidth 64
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
WaveRestoreZoom {10648300 ps} {10669200 ps}
