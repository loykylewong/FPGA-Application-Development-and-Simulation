onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestBasebandSys/clk
add wave -noupdate /TestBasebandSys/rst
add wave -noupdate /TestBasebandSys/dr_en
add wave -noupdate /TestBasebandSys/dr_en180
add wave -noupdate /TestBasebandSys/lfsr_en
add wave -noupdate /TestBasebandSys/lfsr_out
add wave -noupdate -radix unsigned -radixshowbase 0 /TestBasebandSys/bit_cnt
add wave -noupdate /TestBasebandSys/data_bit
add wave -noupdate /TestBasebandSys/dbit_start
add wave -noupdate /TestBasebandSys/dbit_last
add wave -noupdate /TestBasebandSys/crcGen/crc
add wave -noupdate /TestBasebandSys/crcGen/crc_end
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestBasebandSys/crcGen/lfsr
add wave -noupdate /TestBasebandSys/dbit_crc
add wave -noupdate /TestBasebandSys/dr_en
add wave -noupdate /TestBasebandSys/dr_en180
add wave -noupdate /TestBasebandSys/dman
add wave -noupdate -format Analog-Step -height 74 -max 1426.9999999999998 -min -1477.0 -radix decimal /TestBasebandSys/baseband
add wave -noupdate -format Analog-Step -height 74 -max 2046.9999999999995 -min -2048.0 -radix decimal /TestBasebandSys/bb_noi
add wave -noupdate -format Analog-Step -height 74 -max 1614.0 -min -1663.0 -radix decimal /TestBasebandSys/bb_filtered
add wave -noupdate -radix decimal /TestBasebandSys/theHystComp/hyst
add wave -noupdate /TestBasebandSys/bb_1bit
add wave -noupdate -radix unsigned -radixshowbase 0 /TestBasebandSys/theDmanDec/pcnt
add wave -noupdate /TestBasebandSys/theDmanDec/trans
add wave -noupdate /TestBasebandSys/decoded
add wave -noupdate /TestBasebandSys/dec_valid
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestBasebandSys/dec_reg
add wave -noupdate -radix unsigned -radixshowbase 0 /TestBasebandSys/dec_bcnt
add wave -noupdate /TestBasebandSys/chk_start
add wave -noupdate /TestBasebandSys/chk_last
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestBasebandSys/crcChk/lfsr
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestBasebandSys/crcChk/lfsr_nxt
add wave -noupdate /TestBasebandSys/err_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {48933000 ps} 0}
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
WaveRestoreZoom {0 ps} {52500 ns}
