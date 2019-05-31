onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestBPSK/clk
add wave -noupdate /TestBPSK/rst
add wave -noupdate /TestBPSK/bb_en
add wave -noupdate {/TestBPSK/lfsr_out[0]}
add wave -noupdate /TestBPSK/dman
add wave -noupdate -format Analog-Step -height 40 -max 381.0 -min -393.0 -radix decimal -childformat {{{/TestBPSK/bpskMod/ph_if[11]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[10]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[9]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[8]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[7]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[6]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[5]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[4]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[3]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[2]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[1]} -radix decimal} {{/TestBPSK/bpskMod/ph_if[0]} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestBPSK/bpskMod/ph_if[11]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[10]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[9]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[8]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[7]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[6]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[5]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[4]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[3]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[2]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[1]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/ph_if[0]} {-height 15 -radix decimal -radixshowbase 0}} /TestBPSK/bpskMod/ph_if
add wave -noupdate -format Analog-Step -height 40 -max 8372220.0 -min -8372220.0 -radix decimal -childformat {{{/TestBPSK/bpskMod/dds_phase[23]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[22]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[21]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[20]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[19]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[18]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[17]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[16]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[15]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[14]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[13]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[12]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[11]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[10]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[9]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[8]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[7]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[6]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[5]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[4]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[3]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[2]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[1]} -radix decimal} {{/TestBPSK/bpskMod/dds_phase[0]} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestBPSK/bpskMod/dds_phase[23]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[22]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[21]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[20]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[19]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[18]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[17]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[16]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[15]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[14]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[13]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[12]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[11]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[10]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[9]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[8]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[7]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[6]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[5]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[4]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[3]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[2]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[1]} {-height 15 -radix decimal -radixshowbase 0} {/TestBPSK/bpskMod/dds_phase[0]} {-height 15 -radix decimal -radixshowbase 0}} /TestBPSK/bpskMod/dds_phase
add wave -noupdate -format Analog-Step -height 40 -max 2047.0 -min -2047.0 -radix decimal /TestBPSK/bpsk_if
add wave -noupdate -format Analog-Step -height 40 -max 1182.0 -min -1317.0 -radix decimal -radixshowbase 0 /TestBPSK/bpsk_if_fil
add wave -noupdate -format Analog-Step -height 40 -max 1946.9999999999998 -min -1947.0 -radix decimal -radixshowbase 0 /TestBPSK/locar
add wave -noupdate -format Analog-Step -height 40 -max 1114.0 -min -1207.0 -radix decimal -radixshowbase 0 /TestBPSK/bpskDemod/mix
add wave -noupdate -format Analog-Interpolated -height 40 -max 420.0 -min -790.0 -radix decimal -radixshowbase 0 /TestBPSK/bpskDemod/bb_ana
add wave -noupdate /TestBPSK/dman_recv
add wave -noupdate /TestBPSK/bs_recv
add wave -noupdate /TestBPSK/bs_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 98
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
