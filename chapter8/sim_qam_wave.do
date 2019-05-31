onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestQAM16/clk
add wave -noupdate /TestQAM16/rst
add wave -noupdate /TestQAM16/lfsr_out
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/txi
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/txq
add wave -noupdate -format Analog-Step -height 40 -min -2047.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/ilvl
add wave -noupdate -format Analog-Step -height 40 -min -2047.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/qlvl
add wave -noupdate -format Analog-Step -height 40 -max 1240.0000000000002 -min -1249.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/ilevel
add wave -noupdate -format Analog-Step -height 40 -max 1376.0 -min -1326.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/qlevel
add wave -noupdate -format Analog-Step -height 40 -max 2047.0000000000002 -min -1656.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/cos
add wave -noupdate -format Analog-Step -height 40 -max 1946.9999999999998 -min -1947.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/sin
add wave -noupdate -format Analog-Step -height 40 -max 1229.0 -min -1249.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/imix
add wave -noupdate -format Analog-Step -height 40 -max 1307.9999999999998 -min -1261.0 -radix decimal -radixshowbase 0 /TestQAM16/qamod/qmix
add wave -noupdate -format Analog-Step -height 40 -max 833.99999999999989 -min -836.0 -radix decimal -radixshowbase 0 /TestQAM16/qam_if
add wave -noupdate -format Analog-Step -height 40 -max 352.99999999999994 -min -306.0 -radix decimal -radixshowbase 0 /TestQAM16/ibb
add wave -noupdate -format Analog-Step -height 40 -max 401.0 -min -402.0 -radix decimal -radixshowbase 0 /TestQAM16/qbb
add wave -noupdate /TestQAM16/qamSJ/pedge
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/qamSJ/sp_cnt
add wave -noupdate /TestQAM16/qamSJ/sync
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/qamSJ/i
add wave -noupdate -radix unsigned -radixshowbase 0 /TestQAM16/qamSJ/q
add wave -noupdate -format Analog-Step -height 40 -max 353.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/iabs
add wave -noupdate -format Analog-Step -height 40 -max 402.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/qabs
add wave -noupdate -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/ith
add wave -noupdate -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/qth
add wave -noupdate -format Analog-Step -height 40 -max 198.0 -min -183.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/ipulse
add wave -noupdate -format Analog-Step -height 40 -max 205.0 -min -204.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/qpulse
add wave -noupdate -format Analog-Step -height 40 -max 198.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/ipabs
add wave -noupdate -format Analog-Step -height 40 -max 205.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/qpabs
add wave -noupdate -format Analog-Step -height 40 -max 199.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/pulse
add wave -noupdate -format Analog-Step -height 40 -max 199.0 -radix decimal -radixshowbase 0 /TestQAM16/qamSJ/pulse_dly
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7323000 ps} 0} {{Cursor 2} {8723000 ps} 0}
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
WaveRestoreZoom {4199706 ps} {10140298 ps}
