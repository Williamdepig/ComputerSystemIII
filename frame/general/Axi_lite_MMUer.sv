`include "MMIOStruct.vh"
`include "MMUStruct.vh"

module Axi_lite_MMUer #(
    parameter integer C_S_AXI_DATA_WIDTH = 64,
    parameter integer C_S_AXI_ADDR_WIDTH = 64
) (
    AXI_ift.Slave slave_ift,

    output MMUStruct::MMUPack   mmu_info,
    output MMIOStruct::MMIOPack cosim_mmio
);

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

    MMUer mmuer (
        .clk       (slave_ift.clk),
        .rstn      (slave_ift.rstn),
        .mem_ift   (mem_ift.Slave),
        .mmu_info  (mmu_info),
        .cosim_mmio(cosim_mmio)
    );

endmodule
