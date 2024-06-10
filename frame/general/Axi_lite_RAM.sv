module Axi_lite_RAM #(
    parameter integer C_S_AXI_DATA_WIDTH = 64,
    parameter integer C_S_AXI_ADDR_WIDTH = 64,
    parameter longint MEM_DEPTH          = 4096,
    parameter         FILE_PATH          = "testcase.hex"
) (
    AXI_ift.Slave slave_ift
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
        .debug_rvalid_mem(),
        .debug_wvalid_mem()
    );

    RAM #(
        .MEM_DEPTH(MEM_DEPTH),
        .FILE_PATH(FILE_PATH)
    ) ram (
        .clk    (slave_ift.clk),
        .rstn   (slave_ift.rstn),
        .mem_ift(mem_ift.Slave)
    );

endmodule
