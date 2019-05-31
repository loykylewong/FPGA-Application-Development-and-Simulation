onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {cd clk_a}
add wave -noupdate /TestCCCnt/clk_a
add wave -noupdate /TestCCCnt/inc
add wave -noupdate /TestCCCnt/cnt_a
add wave -noupdate -divider {inner cccnt}
add wave -noupdate /TestCCCnt/theCCCnt/clk_a
add wave -noupdate /TestCCCnt/theCCCnt/inc
add wave -noupdate /TestCCCnt/theCCCnt/cnt_a
add wave -noupdate /TestCCCnt/theCCCnt/bin_next
add wave -noupdate /TestCCCnt/theCCCnt/gray_next
add wave -noupdate /TestCCCnt/theCCCnt/gray
add wave -noupdate /TestCCCnt/theCCCnt/clk_b
add wave -noupdate /TestCCCnt/theCCCnt/gray_sync
add wave -noupdate /TestCCCnt/theCCCnt/cnt_b
add wave -noupdate -divider {cd clk_b}
add wave -noupdate /TestCCCnt/clk_b
add wave -noupdate /TestCCCnt/cnt_b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 100
configure wave -valuecolwidth 64
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
WaveRestoreZoom {878 ns} {1007 ns}
