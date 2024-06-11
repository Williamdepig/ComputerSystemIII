`ifndef __DDR_DEBUG_STRUCT__
`define __DDR_DEBUG_STRUCT__
package DDRStruct;
    typedef struct {
        logic [1:0]  debug_axi_wstate;
        logic [1:0]  debug_axi_rstate;
        logic        debug_wen_mem;
        logic        debug_ren_mem;
        logic        debug_rvalid_mem;
        logic        debug_wvalid_mem;
        logic [63:0] debug_visit_times;
    } DDRDebugCorePack;

    typedef struct {
        logic [2:0]      debug_ddrctrl_state;
        logic            debug_app_en;
        logic            debug_app_wdf_wren;
        logic            debug_app_rdy;
        logic            debug_app_wdf_rdy;
        logic            debug_app_rd_data_valid;
        DDRDebugCorePack ddr_debug_core;
    } DDRDebugPack;
endpackage
`endif
