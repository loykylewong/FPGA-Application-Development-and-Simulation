onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestOscopeTrigSmp/clk
add wave -noupdate /TestOscopeTrigSmp/rst
add wave -noupdate -format Analog-Step -height 74 -max 127.0 -min -127.0 -radix decimal -radixshowbase 0 /TestOscopeTrigSmp/sig
add wave -noupdate /TestOscopeTrigSmp/smpEn
add wave -noupdate -radix decimal -radixshowbase 0 /TestOscopeTrigSmp/level
add wave -noupdate -radix unsigned -radixshowbase 0 /TestOscopeTrigSmp/hpos
add wave -noupdate -radix unsigned -radixshowbase 0 /TestOscopeTrigSmp/to
add wave -noupdate /TestOscopeTrigSmp/start
add wave -noupdate /TestOscopeTrigSmp/busy
add wave -noupdate /TestOscopeTrigSmp/read
add wave -noupdate -format Analog-Step -height 74 -max 127.0 -min -127.0 -radix decimal -radixshowbase 0 /TestOscopeTrigSmp/dout
add wave -noupdate -divider {in fsm}
add wave -noupdate /TestOscopeTrigSmp/theOscpTrigSmp/theFsm/trigger
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestOscopeTrigSmp/theOscpTrigSmp/theFsm/state
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestOscopeTrigSmp/theOscpTrigSmp/theFsm/state_nxt
add wave -noupdate /TestOscopeTrigSmp/theOscpTrigSmp/theFsm/data_cnting
add wave -noupdate /TestOscopeTrigSmp/theOscpTrigSmp/theFsm/data_cnt_clr
add wave -noupdate -radix unsigned -radixshowbase 0 /TestOscopeTrigSmp/theOscpTrigSmp/theFsm/data_cnt
add wave -noupdate /TestOscopeTrigSmp/theOscpTrigSmp/theFsm/trigger_flag
add wave -noupdate /TestOscopeTrigSmp/theOscpTrigSmp/theFsm/trigger_flag_clr
add wave -noupdate /TestOscopeTrigSmp/theOscpTrigSmp/theFsm/trigger_flag_set
add wave -noupdate /TestOscopeTrigSmp/theOscpTrigSmp/theFsm/fifo_write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 131
configure wave -valuecolwidth 60
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
WaveRestoreZoom {0 ps} {211509700 ps}
