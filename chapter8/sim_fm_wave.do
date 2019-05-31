onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestFM/clk
add wave -noupdate /TestFM/rst
add wave -noupdate -format Analog-Step -height 40 -max 1950.9999999999998 -min -1911.0 -radix decimal -radixshowbase 0 /TestFM/randsig
add wave -noupdate -format Analog-Step -height 40 -max 1498.0 -min -1499.0 -radix decimal -radixshowbase 0 /TestFM/bbsig
add wave -noupdate -format Analog-Step -height 40 -max 2047.0 -min -2047.0 -radix decimal -radixshowbase 0 /TestFM/wbfm
add wave -noupdate -format Analog-Step -height 40 -max 2300.0 -min -2271.0 -radix decimal -radixshowbase 0 /TestFM/fmDemod/in_fil
add wave -noupdate -format Analog-Step -height 40 -max 2300.0 -radix decimal -childformat {{{/TestFM/fmDemod/theEnvDet/abs[13]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[12]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[11]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[10]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[9]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[8]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[7]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[6]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[5]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[4]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[3]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[2]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[1]} -radix decimal} {{/TestFM/fmDemod/theEnvDet/abs[0]} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestFM/fmDemod/theEnvDet/abs[13]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[12]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[11]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[10]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[9]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[8]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[7]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[6]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[5]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[4]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[3]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[2]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[1]} {-height 15 -radix decimal -radixshowbase 0} {/TestFM/fmDemod/theEnvDet/abs[0]} {-height 15 -radix decimal -radixshowbase 0}} /TestFM/fmDemod/theEnvDet/abs
add wave -noupdate -format Analog-Interpolated -height 40 -max 499.99999999999994 -min -600.0 -radix decimal -radixshowbase 0 /TestFM/wbfm_demod
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 106
configure wave -valuecolwidth 39
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
WaveRestoreZoom {0 ps} {10500 ns}
