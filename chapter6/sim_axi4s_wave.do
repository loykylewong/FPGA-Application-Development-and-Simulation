onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestAxi4StreamFifo/clk
add wave -noupdate /TestAxi4StreamFifo/rst
add wave -noupdate -divider upstream
add wave -noupdate -radix unsigned /TestAxi4StreamFifo/updata
add wave -noupdate -radix unsigned -childformat {{{/TestAxi4StreamFifo/us/tdata[31]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[30]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[29]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[28]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[27]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[26]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[25]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[24]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[23]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[22]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[21]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[20]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[19]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[18]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[17]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[16]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[15]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[14]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[13]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[12]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[11]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[10]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[9]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[8]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[7]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[6]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[5]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[4]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[3]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[2]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[1]} -radix hexadecimal} {{/TestAxi4StreamFifo/us/tdata[0]} -radix hexadecimal}} -subitemconfig {{/TestAxi4StreamFifo/us/tdata[31]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[30]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[29]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[28]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[27]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[26]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[25]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[24]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[23]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[22]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[21]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[20]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[19]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[18]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[17]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[16]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[15]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[14]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[13]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[12]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[11]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[10]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[9]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[8]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[7]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[6]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[5]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[4]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[3]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[2]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[1]} {-height 15 -radix hexadecimal} {/TestAxi4StreamFifo/us/tdata[0]} {-height 15 -radix hexadecimal}} /TestAxi4StreamFifo/us/tdata
add wave -noupdate /TestAxi4StreamFifo/us/tvalid
add wave -noupdate /TestAxi4StreamFifo/us/tready
add wave -noupdate -divider fifo
add wave -noupdate /TestAxi4StreamFifo/theAxi4sFifo/wr
add wave -noupdate /TestAxi4StreamFifo/theAxi4sFifo/full
add wave -noupdate /TestAxi4StreamFifo/theAxi4sFifo/empty
add wave -noupdate /TestAxi4StreamFifo/theAxi4sFifo/rd
add wave -noupdate -divider downstream
add wave -noupdate -radix decimal /TestAxi4StreamFifo/ds/tdata
add wave -noupdate /TestAxi4StreamFifo/ds/tvalid
add wave -noupdate /TestAxi4StreamFifo/ds/tready
add wave -noupdate -radix decimal /TestAxi4StreamFifo/downdata
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 93
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
WaveRestoreZoom {1193100 ps} {1222 ns}
