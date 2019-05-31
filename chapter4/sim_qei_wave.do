onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestQuadEncIf/clk
add wave -noupdate /TestQuadEncIf/rst
add wave -noupdate -divider ch0
add wave -noupdate /TestQuadEncIf/a0
add wave -noupdate /TestQuadEncIf/b0
add wave -noupdate {/TestQuadEncIf/theQei/a_rising[0]}
add wave -noupdate {/TestQuadEncIf/theQei/a_falling[0]}
add wave -noupdate {/TestQuadEncIf/theQei/b_rising[0]}
add wave -noupdate {/TestQuadEncIf/theQei/b_falling[0]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestQuadEncIf/theQei/iacc[0]}
add wave -noupdate -radix decimal -radixshowbase 0 /TestQuadEncIf/acc0
add wave -noupdate /TestQuadEncIf/acc_valid
add wave -noupdate -divider ch1
add wave -noupdate /TestQuadEncIf/a1
add wave -noupdate /TestQuadEncIf/b1
add wave -noupdate {/TestQuadEncIf/theQei/a_rising[1]}
add wave -noupdate {/TestQuadEncIf/theQei/a_falling[1]}
add wave -noupdate {/TestQuadEncIf/theQei/b_rising[1]}
add wave -noupdate {/TestQuadEncIf/theQei/b_falling[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestQuadEncIf/theQei/iacc[1]}
add wave -noupdate -radix decimal -radixshowbase 0 /TestQuadEncIf/acc1
add wave -noupdate /TestQuadEncIf/acc_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 102
configure wave -valuecolwidth 38
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
WaveRestoreZoom {0 ps} {34650 ns}
