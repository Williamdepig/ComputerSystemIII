`ifndef __TIMER_STRUCT__
`define __TIMER_STRUCT__
package TimerStruct;
    typedef struct {
        logic [63:0] _time;
        logic        time_int;
    } TimerPack;
endpackage
`endif
