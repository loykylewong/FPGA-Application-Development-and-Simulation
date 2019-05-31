onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestPID/rst
add wave -noupdate /TestPID/pwm
add wave -noupdate -format Analog-Step -height 40 -max 1536.0 -min -1536.0 -radix decimal -radixshowbase 0 /TestPID/brg_out
add wave -noupdate /TestPID/inn_res
add wave -noupdate /TestPID/load_res
add wave -noupdate /TestPID/des_amp
add wave -noupdate /TestPID/vpwr
add wave -noupdate -format Analog-Step -height 74 -max 11.234700000000002 -min -11.1768 /TestPID/out_volt
add wave -noupdate -format Analog-Step -height 74 -max 1279.0 -min -1280.0 -radix decimal -radixshowbase 0 /TestPID/inverterCtrl/sin_volt
add wave -noupdate -format Analog-Step -height 40 -max 1000.0 -min -1000.0 -radix decimal -radixshowbase 0 /TestPID/inverterCtrl/v_err
add wave -noupdate -format Analog-Step -height 74 -max 640.0 -min -860.0 -radix decimal -radixshowbase 0 /TestPID/inverterCtrl/pid_out_int
add wave -noupdate /TestPID/inverterCtrl/spwm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {44960635568 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 105
configure wave -valuecolwidth 66
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {47250003150 ps}
