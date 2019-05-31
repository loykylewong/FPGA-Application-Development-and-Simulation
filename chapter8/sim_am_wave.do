onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestAM/clk
add wave -noupdate /TestAM/rst
add wave -noupdate -format Analog-Step -height 40 -max 1951.0000000000005 -min -1971.0 -radix decimal -radixshowbase 0 /TestAM/randsig
add wave -noupdate -format Analog-Interpolated -height 40 -max 1030.0 -min -1230.0 -radix decimal -radixshowbase 0 /TestAM/bbsig
add wave -noupdate -format Analog-Step -height 40 -max 1947.0 -min -1947.0 -radix decimal -radixshowbase 0 /TestAM/carrier
add wave -noupdate -format Analog-Step -height 40 -max 2417.0 -min -2432.0 -radix decimal -radixshowbase 0 /TestAM/reg_am
add wave -noupdate -format Analog-Step -height 40 -max 1257.0000000000002 -min -1204.0 -radix decimal -radixshowbase 0 /TestAM/reg_am_noi
add wave -noupdate -format Analog-Step -height 40 -max 1200.0 -radix decimal -radixshowbase 0 /TestAM/envDemod/abs
add wave -noupdate -format Analog-Interpolated -height 40 -max 400.0 -min -400.0 -radix decimal -radixshowbase 0 /TestAM/reg_am_demod
add wave -noupdate -format Analog-Step -height 40 -max 1154.0 -min -1138.0 -radix decimal -childformat {{{/TestAM/dsb_am[12]} -radix decimal} {{/TestAM/dsb_am[11]} -radix decimal} {{/TestAM/dsb_am[10]} -radix decimal} {{/TestAM/dsb_am[9]} -radix decimal} {{/TestAM/dsb_am[8]} -radix decimal} {{/TestAM/dsb_am[7]} -radix decimal} {{/TestAM/dsb_am[6]} -radix decimal} {{/TestAM/dsb_am[5]} -radix decimal} {{/TestAM/dsb_am[4]} -radix decimal} {{/TestAM/dsb_am[3]} -radix decimal} {{/TestAM/dsb_am[2]} -radix decimal} {{/TestAM/dsb_am[1]} -radix decimal} {{/TestAM/dsb_am[0]} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestAM/dsb_am[12]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[11]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[10]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[9]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[8]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[7]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[6]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[5]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[4]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[3]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[2]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[1]} {-height 15 -radix decimal -radixshowbase 0} {/TestAM/dsb_am[0]} {-height 15 -radix decimal -radixshowbase 0}} /TestAM/dsb_am
add wave -noupdate -format Analog-Step -height 40 -max 562.0 -min -640.0 -radix decimal -radixshowbase 0 /TestAM/ssb_am
add wave -noupdate -format Analog-Step -height 40 -max 536.00000000000011 -min -651.0 -radix decimal -radixshowbase 0 /TestAM/ssb_am_noi
add wave -noupdate -format Analog-Step -height 40 -max 489.00000000000011 -min -584.0 -radix decimal /TestAM/cohDemod/mix
add wave -noupdate -format Analog-Interpolated -height 40 -max 448.0 -min -528.0 -radix decimal -radixshowbase 0 /TestAM/ssb_am_demod
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 116
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
WaveRestoreZoom {0 ps} {14700 ns}
