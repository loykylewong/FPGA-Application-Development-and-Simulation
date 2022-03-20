onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_str_usdiv/DW
add wave -noupdate /test_str_usdiv/seed0
add wave -noupdate /test_str_usdiv/seed1
add wave -noupdate /test_str_usdiv/seed2
add wave -noupdate /test_str_usdiv/clk
add wave -noupdate /test_str_usdiv/rst
add wave -noupdate -radix unsigned /test_str_usdiv/cnt
add wave -noupdate -radix unsigned /test_str_usdiv/num
add wave -noupdate -radix unsigned /test_str_usdiv/den
add wave -noupdate /test_str_usdiv/us_last
add wave -noupdate /test_str_usdiv/us_ready
add wave -noupdate /test_str_usdiv/us_valid
add wave -noupdate /test_str_usdiv/uhs
add wave -noupdate -radix unsigned /test_str_usdiv/n
add wave -noupdate -radix unsigned /test_str_usdiv/ref_num
add wave -noupdate -radix unsigned /test_str_usdiv/ref_den
add wave -noupdate -radix unsigned /test_str_usdiv/quo
add wave -noupdate -radix unsigned /test_str_usdiv/rem
add wave -noupdate /test_str_usdiv/ds_last
add wave -noupdate /test_str_usdiv/ds_ready
add wave -noupdate /test_str_usdiv/ds_valid
add wave -noupdate /test_str_usdiv/dhs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1232215000 ps} 0} {{Cursor 2} {35550506996 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 114
configure wave -valuecolwidth 85
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
WaveRestoreZoom {1232198054 ps} {1232435665 ps}
