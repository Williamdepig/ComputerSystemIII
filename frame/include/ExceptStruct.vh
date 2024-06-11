`ifndef __EXCEPT_STRUCT__
`define __EXCEPT_STRUCT__
package ExceptStruct;

    typedef struct {
        logic        except;
        logic [63:0] epc;
        logic [63:0] ecause;
        logic [63:0] etval;
    } ExceptPack;

endpackage
`endif
