onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestMem/clk
add wave -noupdate -radix hexadecimal /TestMem/a
add wave -noupdate /TestMem/we
add wave -noupdate -radix hexadecimal /TestMem/d
add wave -noupdate -radix hexadecimal /TestMem/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 69
configure wave -valuecolwidth 52
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
WaveRestoreZoom {0 ps} {231800 ps}
