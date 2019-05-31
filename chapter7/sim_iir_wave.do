onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestIir/clk
add wave -noupdate /TestIir/rst
add wave -noupdate -format Analog-Step -height 74 -max 511.0 -min -511.0 -radix decimal -radixshowbase 0 /TestIir/swave
add wave -noupdate -format Analog-Step -height 74 -max 511.00000000000006 -min -512.0 -radix decimal -radixshowbase 0 /TestIir/filtered
add wave -noupdate /TestIir/square
add wave -noupdate -format Analog-Step -height 74 -max 233.99999999999997 -min -228.0 -radix decimal -radixshowbase 0 /TestIir/harm3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {138393000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {525001100 ps}
