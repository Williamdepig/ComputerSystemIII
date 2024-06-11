`ifndef __MMIO_STRUCT_H__
`define __MMIO_STRUCT_H__

package MMIOStruct;

    typedef struct {
        logic        store;
        logic [63:0] len;
        logic [63:0] addr;
        logic [63:0] val;
    } MMIOPack;

endpackage

`endif
