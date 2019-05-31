onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestPwm/clk
add wave -noupdate /TestPwm/rst
add wave -noupdate -divider pwm
add wave -noupdate /TestPwm/co
add wave -noupdate -radix unsigned -radixshowbase 0 /TestPwm/udata
add wave -noupdate /TestPwm/pwm
add wave -noupdate -divider {pwm signed}
add wave -noupdate /TestPwm/co_s
add wave -noupdate -radix decimal -radixshowbase 0 /TestPwm/sdata
add wave -noupdate /TestPwm/pwm_s
add wave -noupdate -divider {diff time}
add wave -noupdate /TestPwm/co_dt
add wave -noupdate -radix decimal -radixshowbase 0 /TestPwm/sdata_dt
add wave -noupdate /TestPwm/pwm_dt_p
add wave -noupdate /TestPwm/pwm_dt_n
add wave -noupdate -divider {diff fixed low}
add wave -noupdate /TestPwm/co_fl
add wave -noupdate -radix decimal -radixshowbase 0 /TestPwm/sdata_fl
add wave -noupdate /TestPwm/pwm_fl_p
add wave -noupdate /TestPwm/pwm_fl_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 98
configure wave -valuecolwidth 53
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
WaveRestoreZoom {0 ps} {5751531 ps}
