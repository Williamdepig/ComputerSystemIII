`ifndef _PAGE_STRUCT_
`define _PAGE_STRUCT_

package PageStruct

    typedef struct{
        logic v;
        logic r;
        logic w;
        logic x;
        logic u;
        logic g;
        logci a;
        logic d;
        logic [1:0] rsw;
        logic [63:0] ppn;
    } PTEPack;

endpackage

`endif 