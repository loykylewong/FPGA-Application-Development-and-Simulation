onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestScFifo/clk
add wave -noupdate /TestScFifo/wr
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestScFifo/din
add wave -noupdate /TestScFifo/rd
add wave -noupdate /TestScFifo/theFifo/rd_dly
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestScFifo/theFifo/qout_b
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestScFifo/theFifo/qout_b_reg
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestScFifo/dout
add wave -noupdate -radix unsigned -radixshowbase 0 /TestScFifo/wc
add wave -noupdate -radix unsigned -radixshowbase 0 /TestScFifo/rc
add wave -noupdate -radix unsigned -radixshowbase 0 /TestScFifo/dc
add wave -noupdate /TestScFifo/fu
add wave -noupdate /TestScFifo/em
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {293000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 106
configure wave -valuecolwidth 53
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
WaveRestoreZoom {72 ns} {443300 ps}
