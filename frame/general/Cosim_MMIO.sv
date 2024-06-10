`include "MMIOStruct.vh"

module Cosim_MMIO (
    input  MMIOStruct::MMIOPack timer_mmio,
    input  MMIOStruct::MMIOPack disp_mmio,
    input  MMIOStruct::MMIOPack uart_mmio,
    input  MMIOStruct::MMIOPack mmuer_mmio,
    output MMIOStruct::MMIOPack cosim_mmio
);
    import MMIOStruct::MMIOPack;

    MMIOPack dummy = '{store: 1'b0, len: 64'b0, val: 64'b0, addr: 64'b0};

    assign cosim_mmio = timer_mmio.store ? timer_mmio :
        (disp_mmio.store ? disp_mmio : (uart_mmio.store ? uart_mmio : (mmuer_mmio.store ? mmuer_mmio : dummy)));

endmodule
