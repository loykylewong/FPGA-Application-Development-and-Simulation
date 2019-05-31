onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestCCEvent/theCCEvent/clk_a
add wave -noupdate /TestCCEvent/theCCEvent/in
add wave -noupdate /TestCCEvent/theCCEvent/ra0
add wave -noupdate /TestCCEvent/theCCEvent/ra1
add wave -noupdate /TestCCEvent/theCCEvent/ra2
add wave -noupdate /TestCCEvent/theCCEvent/busy
add wave -noupdate /TestCCEvent/theCCEvent/clk_b
add wave -noupdate /TestCCEvent/theCCEvent/rb0
add wave -noupdate /TestCCEvent/theCCEvent/rb1
add wave -noupdate /TestCCEvent/theCCEvent/rb2
add wave -noupdate /TestCCEvent/theCCEvent/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {354 ns} 0}
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
WaveRestoreZoom {0 ns} {992 ns}
