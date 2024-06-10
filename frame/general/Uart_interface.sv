interface Uart_ift;

    logic [63:0] waddr_mem;
    logic [63:0] raddr_mem;
    logic [63:0] wdata_mem;
    logic [63:0] rdata_mem;
    logic        rvalid_mem;
    logic        wvalid_mem;
    logic        wen_mem;
    logic        ren_mem;
    logic [ 7:0] wmask_mem;

    modport Master(
        output waddr_mem,
        output raddr_mem,
        output wdata_mem,
        input rdata_mem,
        input rvalid_mem,
        input wvalid_mem,
        output wen_mem,
        output ren_mem,
        output wmask_mem
    );

    modport Slave(
        input waddr_mem,
        input raddr_mem,
        input wdata_mem,
        output rdata_mem,
        output rvalid_mem,
        output wvalid_mem,
        input wen_mem,
        input ren_mem,
        input wmask_mem
    );

endinterface
