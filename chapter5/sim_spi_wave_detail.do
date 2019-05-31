onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestSpi/clk
add wave -noupdate /TestSpi/rst
add wave -noupdate -divider master
add wave -noupdate /TestSpi/start
add wave -noupdate /TestSpi/ss_mask
add wave -noupdate /TestSpi/trans_len
add wave -noupdate /TestSpi/mread
add wave -noupdate /TestSpi/mtx_idx
add wave -noupdate /TestSpi/mtx_d
add wave -noupdate /TestSpi/mvalid
add wave -noupdate /TestSpi/mrx_idx
add wave -noupdate /TestSpi/mrx_d
add wave -noupdate /TestSpi/mbusy
add wave -noupdate -divider {in master}
add wave -noupdate /TestSpi/theMaster/hbr_co
add wave -noupdate -radix unsigned -radixshowbase 0 /TestSpi/theMaster/hbit_cnt_max
add wave -noupdate -radix unsigned -radixshowbase 0 /TestSpi/theMaster/hbit_cnt
add wave -noupdate /TestSpi/theMaster/miso_reg
add wave -noupdate -radix hexadecimal -childformat {{{/TestSpi/theMaster/miso_shift_reg[7]} -radix hexadecimal} {{/TestSpi/theMaster/miso_shift_reg[6]} -radix hexadecimal} {{/TestSpi/theMaster/miso_shift_reg[5]} -radix hexadecimal} {{/TestSpi/theMaster/miso_shift_reg[4]} -radix hexadecimal} {{/TestSpi/theMaster/miso_shift_reg[3]} -radix hexadecimal} {{/TestSpi/theMaster/miso_shift_reg[2]} -radix hexadecimal} {{/TestSpi/theMaster/miso_shift_reg[1]} -radix hexadecimal} {{/TestSpi/theMaster/miso_shift_reg[0]} -radix hexadecimal}} -radixshowbase 0 -subitemconfig {{/TestSpi/theMaster/miso_shift_reg[7]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestSpi/theMaster/miso_shift_reg[6]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestSpi/theMaster/miso_shift_reg[5]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestSpi/theMaster/miso_shift_reg[4]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestSpi/theMaster/miso_shift_reg[3]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestSpi/theMaster/miso_shift_reg[2]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestSpi/theMaster/miso_shift_reg[1]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestSpi/theMaster/miso_shift_reg[0]} {-height 15 -radix hexadecimal -radixshowbase 0}} /TestSpi/theMaster/miso_shift_reg
add wave -noupdate /TestSpi/theMaster/out_valid
add wave -noupdate -divider spi
add wave -noupdate {/TestSpi/ss_n[3]}
add wave -noupdate /TestSpi/sclk0
add wave -noupdate /TestSpi/mosi
add wave -noupdate /TestSpi/miso
add wave -noupdate -divider slave
add wave -noupdate /TestSpi/sread
add wave -noupdate /TestSpi/stx_idx
add wave -noupdate /TestSpi/stx_d
add wave -noupdate /TestSpi/svalid
add wave -noupdate /TestSpi/srx_idx
add wave -noupdate /TestSpi/srx_d
add wave -noupdate -divider {in slave}
add wave -noupdate /TestSpi/theSlave/ss_n_falling
add wave -noupdate /TestSpi/theSlave/ss_n_rising
add wave -noupdate /TestSpi/theSlave/sclk_rising
add wave -noupdate /TestSpi/theSlave/sclk_falling
add wave -noupdate /TestSpi/theSlave/bit_cnt_en
add wave -noupdate -radix unsigned -radixshowbase 0 /TestSpi/theSlave/bit_cnt
add wave -noupdate /TestSpi/theSlave/read
add wave -noupdate /TestSpi/theSlave/read_dly
add wave -noupdate /TestSpi/theSlave/in_shift
add wave -noupdate /TestSpi/theSlave/mosi_shift_reg
add wave -noupdate /TestSpi/theSlave/out_shift
add wave -noupdate /TestSpi/theSlave/out_valid
add wave -noupdate /TestSpi/theSlave/valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1603000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 115
configure wave -valuecolwidth 68
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
WaveRestoreZoom {0 ps} {4465650 ps}
