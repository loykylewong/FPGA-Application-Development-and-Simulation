onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestDelayChainMem/clk
add wave -noupdate /TestDelayChainMem/en
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestDelayChainMem/a
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestDelayChainMem/y
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestDelayChainMem/dc/addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 79
configure wave -valuecolwidth 45
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
WaveRestoreZoom {0 ps} {343216 ps}
