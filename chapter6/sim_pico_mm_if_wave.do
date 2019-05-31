onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider cu2ic
add wave -noupdate /TestPicoMmIf/pico_cu2ic/clk
add wave -noupdate /TestPicoMmIf/pico_cu2ic/rst
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestPicoMmIf/pico_cu2ic/addr
add wave -noupdate /TestPicoMmIf/pico_cu2ic/write
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestPicoMmIf/pico_cu2ic/wrdata
add wave -noupdate /TestPicoMmIf/pico_cu2ic/read
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestPicoMmIf/pico_cu2ic/rddata
add wave -noupdate -divider ic2mem
add wave -noupdate {/TestPicoMmIf/pico_ic2per[0]/clk}
add wave -noupdate {/TestPicoMmIf/pico_ic2per[0]/rst}
add wave -noupdate -radix hexadecimal -radixshowbase 0 {/TestPicoMmIf/pico_ic2per[0]/addr}
add wave -noupdate {/TestPicoMmIf/pico_ic2per[0]/write}
add wave -noupdate -radix hexadecimal -radixshowbase 0 {/TestPicoMmIf/pico_ic2per[0]/wrdata}
add wave -noupdate {/TestPicoMmIf/pico_ic2per[0]/read}
add wave -noupdate -radix hexadecimal -radixshowbase 0 {/TestPicoMmIf/pico_ic2per[0]/rddata}
add wave -noupdate -divider ic2pwm
add wave -noupdate {/TestPicoMmIf/pico_ic2per[1]/clk}
add wave -noupdate {/TestPicoMmIf/pico_ic2per[1]/rst}
add wave -noupdate -radix hexadecimal -radixshowbase 0 {/TestPicoMmIf/pico_ic2per[1]/addr}
add wave -noupdate {/TestPicoMmIf/pico_ic2per[1]/write}
add wave -noupdate -radix hexadecimal -radixshowbase 0 {/TestPicoMmIf/pico_ic2per[1]/wrdata}
add wave -noupdate {/TestPicoMmIf/pico_ic2per[1]/read}
add wave -noupdate -radix hexadecimal -radixshowbase 0 {/TestPicoMmIf/pico_ic2per[1]/rddata}
add wave -noupdate -divider pwm
add wave -noupdate /TestPicoMmIf/pwm
add wave -noupdate -divider ic2spim
add wave -noupdate {/TestPicoMmIf/pico_ic2per[2]/clk}
add wave -noupdate {/TestPicoMmIf/pico_ic2per[2]/rst}
add wave -noupdate -radix hexadecimal -radixshowbase 0 {/TestPicoMmIf/pico_ic2per[2]/addr}
add wave -noupdate {/TestPicoMmIf/pico_ic2per[2]/write}
add wave -noupdate -radix hexadecimal -radixshowbase 0 {/TestPicoMmIf/pico_ic2per[2]/wrdata}
add wave -noupdate {/TestPicoMmIf/pico_ic2per[2]/read}
add wave -noupdate -radix hexadecimal -radixshowbase 0 {/TestPicoMmIf/pico_ic2per[2]/rddata}
add wave -noupdate -divider spim
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TestPicoMmIf/ss_n
add wave -noupdate /TestPicoMmIf/sclk0
add wave -noupdate /TestPicoMmIf/sclk1
add wave -noupdate /TestPicoMmIf/mosi
add wave -noupdate /TestPicoMmIf/mosi_tri
add wave -noupdate /TestPicoMmIf/miso
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {48900 ps} 0}
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
WaveRestoreZoom {9100 ps} {17200 ps}
