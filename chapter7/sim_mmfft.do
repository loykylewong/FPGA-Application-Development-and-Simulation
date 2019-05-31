onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestMmFFT/clk
add wave -noupdate /TestMmFFT/rst
add wave -noupdate /TestMmFFT/irq
add wave -noupdate /TestMmFFT/irq_ack
add wave -noupdate /TestMmFFT/x
add wave -noupdate -divider data_if
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/dataIf/addr
add wave -noupdate /TestMmFFT/dataIf/write
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/dataIf/wrdata
add wave -noupdate /TestMmFFT/dataIf/read
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/dataIf/rddata
add wave -noupdate -divider ctrl_if
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/ctrlIf/addr
add wave -noupdate /TestMmFFT/ctrlIf/write
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/ctrlIf/wrdata
add wave -noupdate /TestMmFFT/ctrlIf/read
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/ctrlIf/rddata
add wave -noupdate -divider {fft fsm}
add wave -noupdate /TestMmFFT/theMmFFT/busy
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/theMmFFT/mode
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/theMmFFT/step
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/theMmFFT/grp
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/theMmFFT/grpLen
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/theMmFFT/i
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/theMmFFT/j
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/theMmFFT/k
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/theMmFFT/cyc
add wave -noupdate -divider calcs
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/data_real_q
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/data_imag_q
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/j_real
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/j_imag
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/coef_real_q
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/coef_imag_q
add wave -noupdate -radix decimal -childformat {{{/TestMmFFT/theMmFFT/sub_real[15]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[14]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[13]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[12]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[11]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[10]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[9]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[8]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[7]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[6]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[5]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[4]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[3]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[2]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[1]} -radix decimal} {{/TestMmFFT/theMmFFT/sub_real[0]} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestMmFFT/theMmFFT/sub_real[15]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[14]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[13]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[12]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[11]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[10]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[9]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[8]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[7]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[6]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[5]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[4]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[3]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[2]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[1]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/sub_real[0]} {-height 15 -radix decimal -radixshowbase 0}} /TestMmFFT/theMmFFT/sub_real
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/sub_imag
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/mprr
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/mpii
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/mpri
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/mpir
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/fft_real_d
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/fft_imag_d
add wave -noupdate -divider {real ram}
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/theMmFFT/realDataRam/addr
add wave -noupdate /TestMmFFT/theMmFFT/realDataRam/we
add wave -noupdate -radix decimal -childformat {{{/TestMmFFT/theMmFFT/realDataRam/din[15]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[14]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[13]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[12]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[11]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[10]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[9]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[8]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[7]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[6]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[5]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[4]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[3]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[2]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[1]} -radix decimal} {{/TestMmFFT/theMmFFT/realDataRam/din[0]} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestMmFFT/theMmFFT/realDataRam/din[15]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[14]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[13]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[12]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[11]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[10]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[9]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[8]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[7]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[6]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[5]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[4]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[3]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[2]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[1]} {-height 15 -radix decimal -radixshowbase 0} {/TestMmFFT/theMmFFT/realDataRam/din[0]} {-height 15 -radix decimal -radixshowbase 0}} /TestMmFFT/theMmFFT/realDataRam/din
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/realDataRam/qout
add wave -noupdate -divider {imag ram}
add wave -noupdate -radix unsigned -radixshowbase 0 /TestMmFFT/theMmFFT/imagDataRam/addr
add wave -noupdate /TestMmFFT/theMmFFT/imagDataRam/we
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/imagDataRam/din
add wave -noupdate -radix decimal -radixshowbase 0 /TestMmFFT/theMmFFT/imagDataRam/qout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30837900 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 110
configure wave -valuecolwidth 57
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {138500 ps}
