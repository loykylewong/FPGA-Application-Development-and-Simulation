onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestR2Sdf/clk
add wave -noupdate /TestR2Sdf/rst
add wave -noupdate /TestR2Sdf/sc
add wave -noupdate /TestR2Sdf/inv
add wave -noupdate -radix unsigned -childformat {{{/TestR2Sdf/cnt[3]} -radix unsigned} {{/TestR2Sdf/cnt[2]} -radix unsigned} {{/TestR2Sdf/cnt[1]} -radix unsigned} {{/TestR2Sdf/cnt[0]} -radix unsigned}} -radixshowbase 0 -subitemconfig {{/TestR2Sdf/cnt[3]} {-height 15 -radix unsigned -radixshowbase 0} {/TestR2Sdf/cnt[2]} {-height 15 -radix unsigned -radixshowbase 0} {/TestR2Sdf/cnt[1]} {-height 15 -radix unsigned -radixshowbase 0} {/TestR2Sdf/cnt[0]} {-height 15 -radix unsigned -radixshowbase 0}} /TestR2Sdf/cnt
add wave -noupdate /TestR2Sdf/isync
add wave -noupdate -radix decimal -radixshowbase 0 /TestR2Sdf/x
add wave -noupdate /TestR2Sdf/osync
add wave -noupdate -radix unsigned -radixshowbase 0 /TestR2Sdf/dataIdx
add wave -noupdate -radix decimal -childformat {{/TestR2Sdf/out.re -radix decimal} {/TestR2Sdf/out.im -radix decimal}} -radixshowbase 0 -expand -subitemconfig {/TestR2Sdf/out.re {-height 15 -radix decimal -radixshowbase 0} /TestR2Sdf/out.im {-height 15 -radix decimal -radixshowbase 0}} /TestR2Sdf/out
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_x1[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_z1[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_x0[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_z0[1]}
add wave -noupdate {/TestR2Sdf/theR2Sdf/mulStg[0]/cnt_dly}
add wave -noupdate -radix decimal -childformat {{{/TestR2Sdf/theR2Sdf/mulStg[0]/waddr[0]} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestR2Sdf/theR2Sdf/mulStg[0]/waddr[0]} {-height 15 -radix decimal -radixshowbase 0}} {/TestR2Sdf/theR2Sdf/mulStg[0]/waddr}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/mulStg[0]/w}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/mulStg[0]/mulin}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/mulStg[0]/mulout}
add wave -noupdate {/TestR2Sdf/theR2Sdf/bfStg[0]/s_dly}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_x1[0]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_z1[0]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_x0[0]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR2Sdf/theR2Sdf/bf2_z0[0]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 97
configure wave -valuecolwidth 71
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
WaveRestoreZoom {474200 ps} {586740 ps}
