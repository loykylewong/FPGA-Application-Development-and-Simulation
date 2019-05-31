onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestMem/a
add wave -noupdate /TestMem/clk
add wave -noupdate -format Analog-Step -height 74 -max 127.0 -min -127.0 -radix decimal /TestMem/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4457000 ps} 0}
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
WaveRestoreZoom {2691 ns} {6485500 ps}
