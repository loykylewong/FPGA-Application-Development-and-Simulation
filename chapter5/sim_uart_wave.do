onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestUart/clk
add wave -noupdate /TestUart/rst
add wave -noupdate -divider tx_fifo
add wave -noupdate /TestUart/tx_fifo_write
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestUart/tx_fifo_din
add wave -noupdate /TestUart/tx_fifo_empty
add wave -noupdate /TestUart/tx_fifo_read
add wave -noupdate -divider uart_tx
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestUart/theUartTx/din
add wave -noupdate /TestUart/theUartTx/start
add wave -noupdate /TestUart/theUartTx/br_en
add wave -noupdate /TestUart/theUartTx/bit_co
add wave -noupdate /TestUart/theUartTx/busy
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestUart/theUartTx/shift_reg
add wave -noupdate /TestUart/uart
add wave -noupdate -divider uart_rx
add wave -noupdate /TestUart/theUartRx/br_en
add wave -noupdate /TestUart/theUartRx/bit_co
add wave -noupdate /TestUart/theUartRx/busy
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestUart/theUartRx/shift_reg
add wave -noupdate /TestUart/theUartRx/dout_valid
add wave -noupdate /TestUart/theUartRx/par_err
add wave -noupdate -radix hexadecimal -childformat {{{/TestUart/theUartRx/dout[7]} -radix hexadecimal} {{/TestUart/theUartRx/dout[6]} -radix hexadecimal} {{/TestUart/theUartRx/dout[5]} -radix hexadecimal} {{/TestUart/theUartRx/dout[4]} -radix hexadecimal} {{/TestUart/theUartRx/dout[3]} -radix hexadecimal} {{/TestUart/theUartRx/dout[2]} -radix hexadecimal} {{/TestUart/theUartRx/dout[1]} -radix hexadecimal} {{/TestUart/theUartRx/dout[0]} -radix hexadecimal}} -radixshowbase 0 -subitemconfig {{/TestUart/theUartRx/dout[7]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/theUartRx/dout[6]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/theUartRx/dout[5]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/theUartRx/dout[4]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/theUartRx/dout[3]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/theUartRx/dout[2]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/theUartRx/dout[1]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/theUartRx/dout[0]} {-height 15 -radix hexadecimal -radixshowbase 0}} /TestUart/theUartRx/dout
add wave -noupdate -divider rx_fifo
add wave -noupdate /TestUart/rx_fifo_write
add wave -noupdate -radix unsigned -childformat {{{/TestUart/rx_fifo_dc[3]} -radix unsigned} {{/TestUart/rx_fifo_dc[2]} -radix unsigned} {{/TestUart/rx_fifo_dc[1]} -radix unsigned} {{/TestUart/rx_fifo_dc[0]} -radix unsigned}} -radixshowbase 0 -subitemconfig {{/TestUart/rx_fifo_dc[3]} {-height 15 -radix unsigned -radixshowbase 0} {/TestUart/rx_fifo_dc[2]} {-height 15 -radix unsigned -radixshowbase 0} {/TestUart/rx_fifo_dc[1]} {-height 15 -radix unsigned -radixshowbase 0} {/TestUart/rx_fifo_dc[0]} {-height 15 -radix unsigned -radixshowbase 0}} /TestUart/rx_fifo_dc
add wave -noupdate /TestUart/rx_fifo_read
add wave -noupdate -radix hexadecimal -childformat {{{/TestUart/rx_fifo_dout[8]} -radix hexadecimal} {{/TestUart/rx_fifo_dout[7]} -radix hexadecimal} {{/TestUart/rx_fifo_dout[6]} -radix hexadecimal} {{/TestUart/rx_fifo_dout[5]} -radix hexadecimal} {{/TestUart/rx_fifo_dout[4]} -radix hexadecimal} {{/TestUart/rx_fifo_dout[3]} -radix hexadecimal} {{/TestUart/rx_fifo_dout[2]} -radix hexadecimal} {{/TestUart/rx_fifo_dout[1]} -radix hexadecimal} {{/TestUart/rx_fifo_dout[0]} -radix hexadecimal}} -radixshowbase 0 -subitemconfig {{/TestUart/rx_fifo_dout[8]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/rx_fifo_dout[7]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/rx_fifo_dout[6]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/rx_fifo_dout[5]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/rx_fifo_dout[4]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/rx_fifo_dout[3]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/rx_fifo_dout[2]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/rx_fifo_dout[1]} {-height 15 -radix hexadecimal -radixshowbase 0} {/TestUart/rx_fifo_dout[0]} {-height 15 -radix hexadecimal -radixshowbase 0}} /TestUart/rx_fifo_dout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 111
configure wave -valuecolwidth 39
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
WaveRestoreZoom {0 ps} {39966150 ps}
