onerror {resume}
quietly virtual function -install /TestQAM16 -env /TestQAM16 { &{/TestQAM16/lfsr_out[3], /TestQAM16/lfsr_out[2], /TestQAM16/lfsr_out[1], /TestQAM16/lfsr_out[0] }} lfsr3210
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestQAM16/clk
add wave -noupdate /TestQAM16/rst
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestQAM16/lfsr_out
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/txi
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/txq
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/rxi
add wave -noupdate -radix unsigned -childformat {{{/TestQAM16/rxq[1]} -radix unsigned} {{/TestQAM16/rxq[0]} -radix unsigned}} -radixshowbase 0 -subitemconfig {{/TestQAM16/rxq[1]} {-height 15 -radix unsigned -radixshowbase 0} {/TestQAM16/rxq[0]} {-height 15 -radix unsigned -radixshowbase 0}} /TestQAM16/rxq
add wave -noupdate -radix hexadecimal -childformat {{{/TestQAM16/rxd[3]} -radix hexadecimal} {{/TestQAM16/rxd[2]} -radix hexadecimal} {{/TestQAM16/rxd[1]} -radix hexadecimal} {{/TestQAM16/rxd[0]} -radix hexadecimal}} -radixshowbase 0 -subitemconfig {{/TestQAM16/rxd[3]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestQAM16/rxd[2]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestQAM16/rxd[1]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestQAM16/rxd[0]} {-height 15 -radix hexadecimal -radixshowbase 0}} /TestQAM16/rxd
add wave -noupdate -format Analog-Step -height 40 -max 1024.0 -min -1024.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/ilvl
add wave -noupdate -format Analog-Step -height 40 -max 1024.0 -min -1024.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/qlvl
add wave -noupdate -format Analog-Step -height 40 -max 1397.9999999999998 -min -1433.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/ilevel
add wave -noupdate -format Analog-Step -height 40 -max 1580.0000000000002 -min -1471.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/qlevel
add wave -noupdate -format Analog-Step -height 40 -max 1866.0000000000002 -min -1979.0 -radix decimal -radixshowbase 0 /TestQAM16/qam_if
add wave -noupdate -format Analog-Step -height 40 -max 715.0 -min -736.0 -radix decimal -radixshowbase 0 /TestQAM16/ibb
add wave -noupdate -format Analog-Step -height 40 -max 773.99999999999989 -min -706.0 -radix decimal -radixshowbase 0 /TestQAM16/qbb
add wave -noupdate /TestQAM16/qamSJ/pedge
add wave -noupdate /TestQAM16/qamSJ/pedge_dly
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/qamSJ/sp_cnt
add wave -noupdate /TestQAM16/qamSJ/sync
add wave -noupdate -format Analog-Step -height 40 -max 411.99999999999994 -min -413.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/idiff
add wave -noupdate -format Analog-Step -height 40 -max 408.0 -min -430.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/qdiff
add wave -noupdate -max 407.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/pulse
add wave -noupdate -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/pulse_peak
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 97
configure wave -valuecolwidth 40
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
WaveRestoreZoom {6588581 ps} {7623443 ps}
