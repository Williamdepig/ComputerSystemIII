module Core2MMIO_FSM (
    input  wire [63:0] address_cpu,
    input  wire        wen_cpu,
    input  wire        ren_cpu,
    input  wire [63:0] wdata_cpu,
    input  wire [ 7:0] wmask_cpu,
    output      [63:0] rdata_cpu,
    output             mem_stall,

    Mem_ift.Master mem_ift
);

    assign mem_ift.Mw.waddr = address_cpu;
    assign mem_ift.Mr.raddr = address_cpu;
    assign mem_ift.Mw.wen   = wen_cpu;
    assign mem_ift.Mr.ren   = ren_cpu;
    assign mem_ift.Mw.wdata = wdata_cpu;
    assign mem_ift.Mw.wmask = wmask_cpu;
    assign rdata_cpu        = mem_ift.Sr.rdata;
    assign mem_stall        = ~mem_ift.Sr.rvalid & ren_cpu | ~mem_ift.Sw.wvalid & wen_cpu;

endmodule
