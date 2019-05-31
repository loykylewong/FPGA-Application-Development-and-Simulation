onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestMem/clk
add wave -noupdate /TestMem/a
add wave -noupdate /TestMem/we
add wave -noupdate /TestMem/d
add wave -noupdate -format Analog-Interpolated -height 74 -max 127.0 -min -127.0 -radix decimal /TestMem/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 82
configure wave -valuecolwidth 50
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
WaveRestoreZoom {0 ps} {7273 ns}
