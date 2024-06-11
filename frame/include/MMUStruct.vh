`ifndef __MMU_STRUCT__
`define __MMU_STRUCT__
package MMUStruct;

    typedef struct {logic icache_enable;} IcacheCtrl;

    typedef struct {logic dcache_enable;} DcacheCtrl;

    typedef struct {
        IcacheCtrl icache_ctrl;
        DcacheCtrl dcache_ctrl;
    } MMUPack;

endpackage
`endif
