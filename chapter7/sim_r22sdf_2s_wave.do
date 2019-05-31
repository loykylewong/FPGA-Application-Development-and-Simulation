onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestR22Sdf/clk
add wave -noupdate /TestR22Sdf/rst
add wave -noupdate /TestR22Sdf/x
add wave -noupdate -radix unsigned -childformat {{{/TestR22Sdf/cnt[3]} -radix unsigned} {{/TestR22Sdf/cnt[2]} -radix unsigned} {{/TestR22Sdf/cnt[1]} -radix unsigned} {{/TestR22Sdf/cnt[0]} -radix unsigned}} -radixshowbase 0 -subitemconfig {{/TestR22Sdf/cnt[3]} {-height 15 -radix unsigned} {/TestR22Sdf/cnt[2]} {-height 15 -radix unsigned} {/TestR22Sdf/cnt[1]} {-height 15 -radix unsigned} {/TestR22Sdf/cnt[0]} {-height 15 -radix unsigned}} /TestR22Sdf/cnt
add wave -noupdate /TestR22Sdf/sync
add wave -noupdate -radix decimal -childformat {{/TestR22Sdf/out.re -radix decimal} {/TestR22Sdf/out.im -radix decimal}} -radixshowbase 0 -expand -subitemconfig {/TestR22Sdf/out.re {-height 15 -radix decimal -radixshowbase 0} /TestR22Sdf/out.im {-height 15 -radix decimal -radixshowbase 0}} /TestR22Sdf/out
add wave -noupdate -radix unsigned -radixshowbase 0 /TestR22Sdf/theR22Sdf/ccnt
add wave -noupdate {/TestR22Sdf/theR22Sdf/bfStg[1]/theBf2I/s}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bf2i_x1[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bf2i_z1[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bf2i_x0[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bf2i_z0[1]}
add wave -noupdate {/TestR22Sdf/theR22Sdf/bfStg[1]/theBf2II/t}
add wave -noupdate {/TestR22Sdf/theR22Sdf/bfStg[1]/theBf2II/s}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bf2ii_x1[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bf2ii_z1[1]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bf2ii_x0[1]}
add wave -noupdate -radix decimal -childformat {{{/TestR22Sdf/theR22Sdf/bf2ii_z0[1].re} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z0[1].im} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestR22Sdf/theR22Sdf/bf2ii_z0[1].re} {-radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z0[1].im} {-radix decimal -radixshowbase 0}} {/TestR22Sdf/theR22Sdf/bf2ii_z0[1]}
add wave -noupdate {/TestR22Sdf/theR22Sdf/bfStg[0]/theBf2I/s}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bf2i_x1[0]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bf2i_z1[0]}
add wave -noupdate -radix decimal -childformat {{{/TestR22Sdf/theR22Sdf/bf2i_x0[0].re} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2i_x0[0].im} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestR22Sdf/theR22Sdf/bf2i_x0[0].re} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2i_x0[0].im} {-height 15 -radix decimal -radixshowbase 0}} {/TestR22Sdf/theR22Sdf/bf2i_x0[0]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bf2i_z0[0]}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bfStg[0]/theBf2II/t}
add wave -noupdate -radix decimal -radixshowbase 0 {/TestR22Sdf/theR22Sdf/bfStg[0]/theBf2II/s}
add wave -noupdate -radix decimal -childformat {{{/TestR22Sdf/theR22Sdf/bf2ii_x1[0].re} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_x1[0].im} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestR22Sdf/theR22Sdf/bf2ii_x1[0].re} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_x1[0].im} {-height 15 -radix decimal -radixshowbase 0}} {/TestR22Sdf/theR22Sdf/bf2ii_x1[0]}
add wave -noupdate -radix decimal -childformat {{{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re} -radix decimal -childformat {{{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[15]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[14]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[13]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[12]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[11]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[10]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[9]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[8]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[7]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[6]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[5]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[4]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[3]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[2]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[1]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[0]} -radix decimal}}} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].im} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re} {-height 15 -radix decimal -childformat {{{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[15]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[14]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[13]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[12]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[11]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[10]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[9]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[8]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[7]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[6]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[5]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[4]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[3]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[2]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[1]} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[0]} -radix decimal}} -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[15]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[14]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[13]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[12]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[11]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[10]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[9]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[8]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[7]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[6]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[5]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[4]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[3]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[2]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[1]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].re[0]} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0].im} {-height 15 -radix decimal -radixshowbase 0}} {/TestR22Sdf/theR22Sdf/bf2ii_z1[0]}
add wave -noupdate -radix decimal -childformat {{{/TestR22Sdf/theR22Sdf/bf2ii_x0[0].re} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_x0[0].im} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestR22Sdf/theR22Sdf/bf2ii_x0[0].re} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_x0[0].im} {-height 15 -radix decimal -radixshowbase 0}} {/TestR22Sdf/theR22Sdf/bf2ii_x0[0]}
add wave -noupdate -radix decimal -childformat {{{/TestR22Sdf/theR22Sdf/bf2ii_z0[0].re} -radix decimal} {{/TestR22Sdf/theR22Sdf/bf2ii_z0[0].im} -radix decimal}} -radixshowbase 0 -subitemconfig {{/TestR22Sdf/theR22Sdf/bf2ii_z0[0].re} {-height 15 -radix decimal -radixshowbase 0} {/TestR22Sdf/theR22Sdf/bf2ii_z0[0].im} {-height 15 -radix decimal -radixshowbase 0}} {/TestR22Sdf/theR22Sdf/bf2ii_z0[0]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {763000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 278
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {653919 ps} {857115 ps}
