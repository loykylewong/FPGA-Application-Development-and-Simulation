onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {write side}
add wave -noupdate /TestDcFifo/w_clk
add wave -noupdate /TestDcFifo/w_rst
add wave -noupdate /TestDcFifo/din
add wave -noupdate /TestDcFifo/wr
add wave -noupdate /TestDcFifo/w_wc
add wave -noupdate /TestDcFifo/w_rc
add wave -noupdate /TestDcFifo/w_dc
add wave -noupdate /TestDcFifo/w_fu
add wave -noupdate /TestDcFifo/w_em
add wave -noupdate -divider {read side}
add wave -noupdate /TestDcFifo/r_clk
add wave -noupdate /TestDcFifo/r_rst
add wave -noupdate /TestDcFifo/rd
add wave -noupdate /TestDcFifo/dout
add wave -noupdate /TestDcFifo/r_wc
add wave -noupdate /TestDcFifo/r_rc
add wave -noupdate /TestDcFifo/r_dc
add wave -noupdate /TestDcFifo/r_fu
add wave -noupdate /TestDcFifo/r_em
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {201200 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {158300 ps} {696400 ps}
