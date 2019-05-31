onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestR2Sdf/clk
add wave -noupdate /TestR2Sdf/rst
add wave -noupdate /TestR2Sdf/sc
add wave -noupdate /TestR2Sdf/inv
add wave -noupdate /TestR2Sdf/sync
add wave -noupdate -radix unsigned -radixshowbase 0 /TestR2Sdf/cnt
add wave -noupdate -radix unsigned -radixshowbase 0 /TestR2Sdf/cntidx
add wave -noupdate -radix decimal -radixshowbase 0 /TestR2Sdf/x
add wave -noupdate -radix decimal -childformat {{/TestR2Sdf/out.re -radix decimal} {/TestR2Sdf/out.im -radix decimal}} -radixshowbase 0 -expand -subitemconfig {/TestR2Sdf/out.re {-height 15 -radix decimal -radixshowbase 0} /TestR2Sdf/out.im {-height 15 -radix decimal -radixshowbase 0}} /TestR2Sdf/out
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_x1[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_z1[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_x0[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_z0[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/mulStg[0]/waddr}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/mulStg[0]/w}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/mulStg[0]/mulin}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/mulStg[0]/mulout}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_x1[0]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_z1[0]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_x0[0]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_z0[0]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {929054 ps} 0}
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
WaveRestoreZoom {887099 ps} {1005943 ps}
