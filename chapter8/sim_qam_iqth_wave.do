onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestQAM16/clk
add wave -noupdate /TestQAM16/rst
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestQAM16/lfsr_out
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/txi
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/txq
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/rxi
add wave -noupdate -radix unsigned -childformat {{{/TestQAM16/rxq[1]} -radix unsigned} {{/TestQAM16/rxq[0]} -radix unsigned}} -radixshowbase 0 -subitemconfig {{/TestQAM16/rxq[1]} {-height 15 -radix unsigned -radixshowbase 0} {/TestQAM16/rxq[0]} {-height 15 -radix unsigned -radixshowbase 0}} /TestQAM16/rxq
add wave -noupdate -radix hexadecimal -childformat {{{/TestQAM16/rxd[3]} -radix hexadecimal} {{/TestQAM16/rxd[2]} -radix hexadecimal} {{/TestQAM16/rxd[1]} -radix hexadecimal} {{/TestQAM16/rxd[0]} -radix hexadecimal}} -radixshowbase 0 -subitemconfig {{/TestQAM16/rxd[3]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestQAM16/rxd[2]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestQAM16/rxd[1]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestQAM16/rxd[0]} {-height 15 -radix hexadecimal -radixshowbase 0}} /TestQAM16/rxd
add wave -noupdate -format Analog-Step -height 40 -min -2047.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/ilvl
add wave -noupdate -format Analog-Step -height 40 -min -2047.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/qlvl
add wave -noupdate -format Analog-Step -height 40 -max 1240.0000000000002 -min -1249.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/ilevel
add wave -noupdate -format Analog-Step -height 40 -max 1376.0 -min -1326.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/qlevel
add wave -noupdate -format Analog-Step -height 40 -max 833.99999999999989 -min -836.0 -radix decimal -radixshowbase 0 /TestQAM16/qam_if
add wave -noupdate -format Analog-Step -height 40 -max 352.99999999999994 -min -306.0 -radix decimal -radixshowbase 0 /TestQAM16/ibb
add wave -noupdate -format Analog-Step -height 40 -max 401.0 -min -402.0 -radix decimal -radixshowbase 0 /TestQAM16/qbb
add wave -noupdate /TestQAM16/qamSJ/pedge
add wave -noupdate /TestQAM16/qamSJ/sp_cnt
add wave -noupdate /TestQAM16/qamSJ/sync
add wave -noupdate -format Analog-Step -height 40 -max 343.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/iabs
add wave -noupdate -format Analog-Step -height 40 -max 345.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/qabs
add wave -noupdate -format Analog-Step -height 40 -max 343.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/i_peak
add wave -noupdate -format Analog-Step -height 40 -max 345.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/q_peak
add wave -noupdate -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/ith
add wave -noupdate -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/qth
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 106
configure wave -valuecolwidth 42
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
WaveRestoreZoom {3673997 ps} {12205009 ps}
