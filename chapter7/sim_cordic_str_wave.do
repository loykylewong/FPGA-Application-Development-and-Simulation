onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /TestCordicStr/clk
add wave -noupdate -radix binary /TestCordicStr/rst
add wave -noupdate -format Analog-Step -height 74 -max 32766.999999999993 -min -32768.0 -radix decimal /TestCordicStr/ang
add wave -noupdate -radix binary /TestCordicStr/rot_ready
add wave -noupdate -format Analog-Step -height 74 -max 30002.000000000007 -min -30003.0 -radix decimal /TestCordicStr/cos
add wave -noupdate -format Analog-Step -height 74 -max 30002.000000000007 -min -30003.0 -radix decimal /TestCordicStr/sin
add wave -noupdate -radix decimal /TestCordicStr/arem
add wave -noupdate -radix binary /TestCordicStr/inter_valid
add wave -noupdate -radix binary /TestCordicStr/inter_ready
add wave -noupdate -radix decimal /TestCordicStr/xrem
add wave -noupdate -radix decimal /TestCordicStr/yrem
add wave -noupdate -format Analog-Step -height 74 -max 32767.0 -min -32767.0 -radix decimal /TestCordicStr/aout
add wave -noupdate -radix binary /TestCordicStr/vec_valid
add wave -noupdate /TestCordicStr/angle_out
add wave -noupdate /TestCordicStr/angle_ref
add wave -noupdate -group rot_stgs /TestCordicStr/theRotCordic/a
add wave -noupdate -group rot_stgs /TestCordicStr/theRotCordic/x
add wave -noupdate -group rot_stgs /TestCordicStr/theRotCordic/y
add wave -noupdate -group rot_stgs /TestCordicStr/theRotCordic/r
add wave -noupdate -group rot_stgs /TestCordicStr/theRotCordic/v
add wave -noupdate -expand -group vec_stgs /TestCordicStr/theVecCordic/a
add wave -noupdate -expand -group vec_stgs /TestCordicStr/theVecCordic/x
add wave -noupdate -expand -group vec_stgs /TestCordicStr/theVecCordic/y
add wave -noupdate -expand -group vec_stgs -expand /TestCordicStr/theVecCordic/r
add wave -noupdate -expand -group vec_stgs -expand /TestCordicStr/theVecCordic/v
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {634393000 ps} 0} {{Cursor 2} {327913000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {980 us}
