`include "MMIOStruct.vh"

module Axi_lite_Uart #(
    parameter integer C_S_AXI_DATA_WIDTH = 64,
    parameter integer C_S_AXI_ADDR_WIDTH = 64
) (
    AXI_ift.Slave   slave_ift,
    Uart_ift.Master uart_ift,

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

    assign uart_ift.waddr_mem = mem_ift.Mw.waddr;
    assign uart_ift.raddr_mem = mem_ift.Mr.raddr;
    assign uart_ift.wdata_mem = mem_ift.Mw.wdata;
    assign mem_ift.Sr.rdata   = uart_ift.rdata_mem;
    assign mem_ift.Sw.wvalid  = uart_ift.wvalid_mem;
    assign mem_ift.Sr.rvalid  = uart_ift.rvalid_mem;
    assign uart_ift.wen_mem   = mem_ift.Mw.wen;
    assign uart_ift.ren_mem   = mem_ift.Mr.ren;
    assign uart_ift.wmask_mem = mem_ift.Mw.wmask;

    assign cosim_mmio.store   = 1'b0;
    assign cosim_mmio.addr    = 64'b0;
    assign cosim_mmio.len     = 64'b0;
    assign cosim_mmio.val     = 64'b0;

endmodule
