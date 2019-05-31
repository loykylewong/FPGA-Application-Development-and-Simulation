onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestQamCarRec/rxd
add wave -noupdate /TestQamCarRec/pilot_time
add wave -noupdate /TestQamCarRec/pilot
add wave -noupdate -format Analog-Step -height 40 -max 1935.9999999999998 -min -2021.0 -radix decimal /TestQamCarRec/qam_if_fil
add wave -noupdate -format Analog-Step -height 40 -max 1861.9999999999998 -min -1726.0 -radix decimal /TestQamCarRec/theCarrRecov/mix
add wave -noupdate -max 1017.0 -min -900.0 -radix decimal -radixshowbase 0 /TestQamCarRec/theCarrRecov/mix_fil
add wave -noupdate -radix decimal -childformat {{{/TestQamCarRec/theCarrRecov/ph_err[23]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[22]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[21]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[20]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[19]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[18]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[17]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[16]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[15]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[14]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[13]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[12]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[11]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[10]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[9]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[8]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[7]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[6]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[5]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[4]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[3]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[2]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[1]} -radix decimal} {{/TestQamCarRec/theCarrRecov/ph_err[0]} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestQamCarRec/theCarrRecov/ph_err[23]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[22]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[21]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[20]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[19]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[18]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[17]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[16]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[15]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[14]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[13]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[12]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[11]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[10]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[9]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[8]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[7]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[6]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[5]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[4]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[3]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[2]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[1]} {-height 15 -radix decimal} {/TestQamCarRec/theCarrRecov/ph_err[0]} {-height 15 -radix decimal}} /TestQamCarRec/theCarrRecov/ph_err
add wave -noupdate -radix decimal -radixshowbase 0 /TestQamCarRec/theCarrRecov/freq_vari
add wave -noupdate -radix decimal -radixshowbase 0 /TestQamCarRec/theCarrRecov/freq
add wave -noupdate -format Analog-Step -height 40 -max 2047.0 -min -2047.0 -radix decimal /TestQamCarRec/lccos_ref
add wave -noupdate -format Analog-Step -height 40 -max 2047.0 -min -2047.0 -radix decimal /TestQamCarRec/loc_cos
add wave -noupdate -format Analog-Step -height 40 -max 1946.9999999999998 -min -1947.0 -radix decimal /TestQamCarRec/lcsin_ref
add wave -noupdate -format Analog-Step -height 40 -max 2046.0000000000002 -min -2047.0 -radix decimal /TestQamCarRec/loc_sin
add wave -noupdate -format Analog-Step -height 40 -max 1017.0 -min -900.0 -radix decimal /TestQamCarRec/theCarrRecov/mix_fil_dly
add wave -noupdate -format Analog-Step -height 40 -max 141.0 -min -167.0 -radix decimal /TestQamCarRec/theCarrRecov/ph_diff
add wave -noupdate -format Analog-Step -height 40 -max 167.0 -radix decimal /TestQamCarRec/theCarrRecov/phd_abs
add wave -noupdate -format Analog-Step -height 40 -max 167.00000000000006 -min -2048.0 -radix decimal /TestQamCarRec/theCarrRecov/phd_peak
add wave -noupdate -format Analog-Step -height 40 -max 20.000000000000007 -min -256.0 -radix decimal /TestQamCarRec/theCarrRecov/phd_th
add wave -noupdate /TestQamCarRec/theCarrRecov/pp_cnt
add wave -noupdate /TestQamCarRec/theCarrRecov/pp_end
add wave -noupdate /TestQamCarRec/theCarrRecov/pp_start
add wave -noupdate -format Analog-Step -height 74 -max 891.99999999999989 -min -777.0 -radix decimal /TestQamCarRec/ibb
add wave -noupdate /TestQamCarRec/sync
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 91
configure wave -valuecolwidth 72
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
WaveRestoreZoom {108281250 ps} {118295138 ps}
