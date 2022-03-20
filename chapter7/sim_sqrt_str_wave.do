onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_sqrt_str/seed0
add wave -noupdate /test_sqrt_str/seed1
add wave -noupdate /test_sqrt_str/seed2
add wave -noupdate /test_sqrt_str/clk
add wave -noupdate /test_sqrt_str/rst
add wave -noupdate -radix unsigned /test_sqrt_str/num
add wave -noupdate /test_sqrt_str/us_last
add wave -noupdate /test_sqrt_str/us_ready
add wave -noupdate /test_sqrt_str/us_valid
add wave -noupdate -radix unsigned /test_sqrt_str/sqrt
add wave -noupdate -radix unsigned /test_sqrt_str/rem
add wave -noupdate /test_sqrt_str/ds_last
add wave -noupdate /test_sqrt_str/ds_ready
add wave -noupdate /test_sqrt_str/ds_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {96476772 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 62500000
configure wave -griddelta 10
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {96326090 ps} {96651381 ps}
