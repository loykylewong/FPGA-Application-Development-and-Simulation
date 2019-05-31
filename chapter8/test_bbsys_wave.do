onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestBasebandSys/clk
add wave -noupdate /TestBasebandSys/rst
add wave -noupdate /TestBasebandSys/dr_en
add wave -noupdate /TestBasebandSys/dr_en180
add wave -noupdate /TestBasebandSys/data_bit
add wave -noupdate /TestBasebandSys/dbit_start
add wave -noupdate /TestBasebandSys/dbit_last
add wave -noupdate /TestBasebandSys/dbit_crc
add wave -noupdate /TestBasebandSys/dman
add wave -noupdate -format Analog-Step -height 40 -max 1427.0 -min -1477.0 -radix decimal /TestBasebandSys/baseband
add wave -noupdate -format Analog-Step -height 40 -max 2047.0 -min -2048.0 -radix decimal /TestBasebandSys/bb_noi
add wave -noupdate -format Analog-Step -height 40 -max 1614.0 -min -1663.0 -radix decimal /TestBasebandSys/bb_filtered
add wave -noupdate /TestBasebandSys/bb_1bit
add wave -noupdate /TestBasebandSys/decoded
add wave -noupdate /TestBasebandSys/dec_valid
add wave -noupdate /TestBasebandSys/chk_start
add wave -noupdate /TestBasebandSys/chk_last
add wave -noupdate /TestBasebandSys/err_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26846800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 94
configure wave -valuecolwidth 50
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
WaveRestoreZoom {15179600 ps} {24628200 ps}
