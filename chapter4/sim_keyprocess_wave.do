onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestKeyProcess/clk
add wave -noupdate /TestKeyProcess/key
add wave -noupdate /TestKeyProcess/key_en
add wave -noupdate /TestKeyProcess/theKeyProc/en_intv
add wave -noupdate -expand /TestKeyProcess/theKeyProc/key_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {162891 us} 0}
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 us} {525 ms}
