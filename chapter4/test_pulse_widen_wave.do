onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestPulseWiden/clk
add wave -noupdate /TestPulseWiden/in
add wave -noupdate /TestPulseWiden/pw1/cnt
add wave -noupdate /TestPulseWiden/out
add wave -noupdate /TestPulseWiden/pw2/cnt
add wave -noupdate /TestPulseWiden/out2
add wave -noupdate /TestPulseWiden/pw3/cnt
add wave -noupdate /TestPulseWiden/out3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 76
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
WaveRestoreZoom {185140 ps} {403846 ps}
