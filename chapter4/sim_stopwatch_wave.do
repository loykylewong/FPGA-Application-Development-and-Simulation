onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestStopWatchFsm/clk
add wave -noupdate /TestStopWatchFsm/rst
add wave -noupdate /TestStopWatchFsm/k0
add wave -noupdate /TestStopWatchFsm/k0en
add wave -noupdate /TestStopWatchFsm/k1
add wave -noupdate /TestStopWatchFsm/k1en
add wave -noupdate -divider fsm
add wave -noupdate -radix unsigned -radixshowbase 0 /TestStopWatchFsm/sw_sm/state
add wave -noupdate /TestStopWatchFsm/t
add wave -noupdate /TestStopWatchFsm/f
add wave -noupdate /TestStopWatchFsm/r
add wave -noupdate /TestStopWatchFsm/u
add wave -noupdate -divider counters
add wave -noupdate -radix unsigned -radixshowbase 0 /TestStopWatchFsm/cnt_centisec
add wave -noupdate -radix unsigned -radixshowbase 0 /TestStopWatchFsm/cnt_sec
add wave -noupdate -divider outputs
add wave -noupdate -radix unsigned -radixshowbase 0 /TestStopWatchFsm/centisec
add wave -noupdate -radix unsigned -radixshowbase 0 /TestStopWatchFsm/sec
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 111
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 us} {4417875 us}
