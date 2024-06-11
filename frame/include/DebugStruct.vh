`ifndef __DEBUG_STRUCT__
`define __DEBUG_STRUCT__
package DebugStruct;
    typedef struct {
        logic [63:0] ebreak_point[7:0];
        logic [63:0] ebreak_valid;
        logic [63:0] ebreak_get;
        logic [63:0] ebreak_happen;
        logic [63:0] debug_btn;
    } DebugPack;
endpackage
`endif
