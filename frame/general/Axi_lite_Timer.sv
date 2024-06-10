`include "MMIOStruct.vh"
`include "TimerStruct.vh"

module Axi_lite_Timer #(
    parameter integer C_S_AXI_DATA_WIDTH = 64,
    parameter integer C_S_AXI_ADDR_WIDTH = 64
) (
    AXI_ift.Slave slave_ift,

    output TimerStruct::TimerPack time_out,
    output MMIOStruct::MMIOPack   cosim_mmio,

    output [63:0] cosim_mtime,
    output [63:0] cosim_mtimecmp
);

    import MMIOStruct::MMIOPack;

    Mem_ift #(
        .ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
        .DATA_WIDTH(C_S_AXI_DATA_WIDTH)
    ) mem_ift ();

    MemAxi_lite #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) memaxi_lite (
        .slave_ift(slave_ift),
        .mem_ift  (mem_ift.Master),

        .debug_axi_wstate(),
        .debug_axi_rstate(),
        .debug_wen_mem   (),
        .debug_ren_mem   (),
        .debug_wvalid_mem(),
        .debug_rvalid_mem()
    );

    Timer timer (
        .clk           (slave_ift.clk),
        .rstn          (slave_ift.rstn),
        .mem_ift       (mem_ift.Slave),
        .time_o        (time_out),
        .cosim_mmio    (cosim_mmio),
        .cosim_mtime   (cosim_mtime),
        .cosim_mtimecmp(cosim_mtimecmp)
    );

endmodule
