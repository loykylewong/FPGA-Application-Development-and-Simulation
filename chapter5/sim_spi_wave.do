onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestSpi/clk
add wave -noupdate /TestSpi/rst
add wave -noupdate -divider master
add wave -noupdate /TestSpi/start
add wave -noupdate /TestSpi/ss_mask
add wave -noupdate /TestSpi/trans_len
add wave -noupdate /TestSpi/mread
add wave -noupdate /TestSpi/mtx_d
add wave -noupdate /TestSpi/mvalid
add wave -noupdate /TestSpi/mrx_d
add wave -noupdate /TestSpi/mbusy
add wave -noupdate -divider spi
add wave -noupdate {/TestSpi/ss_n[3]}
add wave -noupdate /TestSpi/sclk0
add wave -noupdate /TestSpi/mosi
add wave -noupdate /TestSpi/miso
add wave -noupdate -divider slave
add wave -noupdate /TestSpi/sread
add wave -noupdate /TestSpi/stx_d
add wave -noupdate /TestSpi/svalid
add wave -noupdate /TestSpi/srx_d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {682142 ps} 0}
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
WaveRestoreZoom {0 ps} {4980150 ps}
