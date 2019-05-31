
package Fixedpoint;
let max(x, y) = x > y? x : y;
`define DEF_FP_ADD(name, i0, f0, i1, f1, fr) \
    let name(x, y) = \
    ((f0) >= (f1)) ? \
        (   (  max((i0),(i1))+(f0))'(x) + \
            ( (max((i0),(i1))+(f0))'(y) <<< ((f0)-(f1)) ) \
        ) >>> ((f0)-(fr)) : \
        (   ( (max((i0),(i1))+(f1))'(x) <<< ((f1)-(f0)) ) + \
              (max((i0),(i1))+(f1))'(y) \
        ) >>> ((f1)-(fr));
`define DEF_FP_MUL(name, i0, f0, i1, f1, fr) \
    let name(x, y) = \
    (   ((i0)+(i1)+(f0)+(f1))'(x) * ((i0)+(i1)+(f0)+(f1))'(y) \
    ) >>> ((f0)+(f1)-(fr));
endpackage