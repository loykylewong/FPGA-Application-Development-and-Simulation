onerror {resume}
quietly virtual function -install /TestQAM16 -env /TestQAM16 { &{/TestQAM16/lfsr_out[3], /TestQAM16/lfsr_out[2], /TestQAM16/lfsr_out[1], /TestQAM16/lfsr_out[0] }} lfsr3210
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestQAM16/clk
add wave -noupdate /TestQAM16/rst
add wave -noupdate -radix hexadecimal -childformat {{(3) -radix hexadecimal} {(2) -radix hexadecimal} {(1) -radix hexadecimal} {(0) -radix hexadecimal}} -radixshowbase 0 -subitemconfig {{/TestQAM16/lfsr_out[3]} {-radix hexadecimal -radixshowbase 0} {/TestQAM16/lfsr_out[2]} {-radix hexadecimal -radixshowbase 0} {/TestQAM16/lfsr_out[1]} {-radix hexadecimal -radixshowbase 0} {/TestQAM16/lfsr_out[0]} {-radix hexadecimal -radixshowbase 0}} /TestQAM16/lfsr3210
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/txi
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/txq
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/rxi
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/rxq
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestQAM16/rxd
add wave -noupdate -format Analog-Step -height 40 -max 1024.0 -min -1024.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/ilvl
add wave -noupdate -format Analog-Step -height 40 -max 1024.0 -min -1024.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/qlvl
add wave -noupdate -format Analog-Step -height 40 -max 1397.9999999999998 -min -1433.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/ilevel
add wave -noupdate -format Analog-Step -height 40 -max 1580.0000000000002 -min -1471.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/qlevel
add wave -noupdate -format Analog-Step -height 40 -max 1866.0000000000002 -min -1979.0 -radix decimal -childformat {{{/TestQAM16/qam_if[11]} -radix decimal} {{/TestQAM16/qam_if[10]} -radix decimal} {{/TestQAM16/qam_if[9]} -radix decimal} {{/TestQAM16/qam_if[8]} -radix decimal} {{/TestQAM16/qam_if[7]} -radix decimal} {{/TestQAM16/qam_if[6]} -radix decimal} {{/TestQAM16/qam_if[5]} -radix decimal} {{/TestQAM16/qam_if[4]} -radix decimal} {{/TestQAM16/qam_if[3]} -radix decimal} {{/TestQAM16/qam_if[2]} -radix decimal} {{/TestQAM16/qam_if[1]} -radix decimal} {{/TestQAM16/qam_if[0]} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestQAM16/qam_if[11]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[10]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[9]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[8]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[7]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[6]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[5]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[4]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[3]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[2]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[1]} {-height 15 -radix decimal -radixshowbase 0} {/TestQAM16/qam_if[0]} {-height 15 -radix decimal -radixshowbase 0}} /TestQAM16/qam_if
add wave -noupdate -format Analog-Step -height 40 -max 1430.0 -min -1472.0 -radix decimal -radixshowbase 0 /TestQAM16/ibb
add wave -noupdate -format Analog-Step -height 40 -max 1547.9999999999998 -min -1412.0 -radix decimal -radixshowbase 0 /TestQAM16/qbb
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/rxi
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/rxq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7203000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 83
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
WaveRestoreZoom {2537770 ps} {20919065 ps}
