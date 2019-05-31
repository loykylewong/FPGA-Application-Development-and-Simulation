onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestIicMasterSlave/clk
add wave -noupdate /TestIicMasterSlave/rst
add wave -noupdate -divider iic
add wave -noupdate /TestIicMasterSlave/sda
add wave -noupdate /TestIicMasterSlave/scl
add wave -noupdate -divider miic
add wave -noupdate /TestIicMasterSlave/miic/sda_o
add wave -noupdate -divider siic
add wave -noupdate /TestIicMasterSlave/siic/sda_o
add wave -noupdate -divider {master side}
add wave -noupdate /TestIicMasterSlave/cfifo_write
add wave -noupdate -radix hexadecimal -childformat {{{/TestIicMasterSlave/cfifo_din[9]} -radix hexadecimal} {{/TestIicMasterSlave/cfifo_din[8]} -radix hexadecimal} {{/TestIicMasterSlave/cfifo_din[7]} -radix hexadecimal} {{/TestIicMasterSlave/cfifo_din[6]} -radix hexadecimal} {{/TestIicMasterSlave/cfifo_din[5]} -radix hexadecimal} {{/TestIicMasterSlave/cfifo_din[4]} -radix hexadecimal} {{/TestIicMasterSlave/cfifo_din[3]} -radix hexadecimal} {{/TestIicMasterSlave/cfifo_din[2]} -radix hexadecimal} {{/TestIicMasterSlave/cfifo_din[1]} -radix hexadecimal} {{/TestIicMasterSlave/cfifo_din[0]} -radix hexadecimal}} -radixshowbase 0 -subitemconfig {{/TestIicMasterSlave/cfifo_din[9]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestIicMasterSlave/cfifo_din[8]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestIicMasterSlave/cfifo_din[7]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestIicMasterSlave/cfifo_din[6]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestIicMasterSlave/cfifo_din[5]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestIicMasterSlave/cfifo_din[4]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestIicMasterSlave/cfifo_din[3]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestIicMasterSlave/cfifo_din[2]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestIicMasterSlave/cfifo_din[1]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestIicMasterSlave/cfifo_din[0]} {-height 15 -radix hexadecimal -radixshowbase 0}} /TestIicMasterSlave/cfifo_din
add wave -noupdate /TestIicMasterSlave/cfifo_read
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestIicMasterSlave/cfifo_dout
add wave -noupdate /TestIicMasterSlave/cfifo_empty
add wave -noupdate /TestIicMasterSlave/dfifo_write
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestIicMasterSlave/dfifo_din
add wave -noupdate -radix unsigned -radixshowbase 0 /TestIicMasterSlave/dfifo_dc
add wave -noupdate /TestIicMasterSlave/dfifo_read
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestIicMasterSlave/dfifo_dout
add wave -noupdate -divider {slave side}
add wave -noupdate /TestIicMasterSlave/iaddr
add wave -noupdate /TestIicMasterSlave/iwr
add wave -noupdate /TestIicMasterSlave/iwrdata
add wave -noupdate /TestIicMasterSlave/ird
add wave -noupdate /TestIicMasterSlave/irddata
add wave -noupdate -divider mas_byte_eng
add wave -noupdate /TestIicMasterSlave/theMas/theByteEngine/state
add wave -noupdate /TestIicMasterSlave/theMas/theByteEngine/state_nxt
add wave -noupdate /TestIicMasterSlave/theMas/theByteEngine/bit_cnt
add wave -noupdate /TestIicMasterSlave/theMas/theByteEngine/data
add wave -noupdate /TestIicMasterSlave/theMas/theByteEngine/w9bit_end
add wave -noupdate -divider mas_bit_eng
add wave -noupdate /TestIicMasterSlave/theMas/theBitEngine/state
add wave -noupdate /TestIicMasterSlave/theMas/theBitEngine/state_nxt
add wave -noupdate /TestIicMasterSlave/theMas/theBitEngine/idle
add wave -noupdate /TestIicMasterSlave/theMas/theBitEngine/go
add wave -noupdate -radix binary /TestIicMasterSlave/theMas/theBitEngine/iic_bit
add wave -noupdate /TestIicMasterSlave/theMas/theBitEngine/t_cnt
add wave -noupdate /TestIicMasterSlave/theMas/theBitEngine/scl
add wave -noupdate /TestIicMasterSlave/theMas/theBitEngine/scl_out
add wave -noupdate /TestIicMasterSlave/theMas/theBitEngine/sda_out
add wave -noupdate -divider {in slave}
add wave -noupdate /TestIicMasterSlave/theSla/start
add wave -noupdate /TestIicMasterSlave/theSla/stop
add wave -noupdate /TestIicMasterSlave/theSla/scl_falling
add wave -noupdate /TestIicMasterSlave/theSla/scl_rising
add wave -noupdate /TestIicMasterSlave/theSla/sda_falling
add wave -noupdate /TestIicMasterSlave/theSla/sda_rising
add wave -noupdate /TestIicMasterSlave/theSla/state
add wave -noupdate /TestIicMasterSlave/theSla/state_nxt
add wave -noupdate /TestIicMasterSlave/theSla/bitcnt
add wave -noupdate /TestIicMasterSlave/theSla/bitcnt_nxt
add wave -noupdate /TestIicMasterSlave/theSla/ia_bitcnt
add wave -noupdate /TestIicMasterSlave/theSla/ia_bitcnt_nxt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {679975 ps} 0} {{Cursor 3} {50089154 ps} 0} {{Cursor 4} {144610442 ps} 0} {{Cursor 5} {282669706 ps} 0}
quietly wave cursor active 4
configure wave -namecolwidth 104
configure wave -valuecolwidth 41
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
WaveRestoreZoom {282589667 ps} {282902689 ps}
