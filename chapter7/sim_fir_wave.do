onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestFir/clk
add wave -noupdate -format Analog-Step -height 74 -max 511.0 -min -511.0 -radix decimal -radixshowbase 1 /TestFir/swave
add wave -noupdate -format Analog-Step -height 74 -max 511.0 -min -512.0 -radix decimal -radixshowbase 1 /TestFir/filtered
add wave -noupdate /TestFir/square
add wave -noupdate -format Analog-Step -height 74 -max 202.0 -min -229.0 -radix decimal -radixshowbase 0 /TestFir/harm3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {90563000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 81
configure wave -valuecolwidth 49
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
WaveRestoreZoom {90132 ns} {91470800 ps}
