`include "MMUStruct.vh"
`include "MMIOStruct.vh"
`include "Define.vh"

module MMUer (
    input clk,
    input rstn,

    Mem_ift.Slave mem_ift,

    output MMUStruct::MMUPack   mmu_info,
    output MMIOStruct::MMIOPack cosim_mmio
);

    wire        ren;
    wire        wen;
    wire [63:0] raddr;
    wire [63:0] waddr;
    wire [63:0] wdata;
    wire [ 7:0] wmask;
    wire [63:0] rdata;
    wire        wvalid;
    wire        rvalid;

    assign ren               = mem_ift.Mr.ren;
    assign wen               = mem_ift.Mw.wen;
    assign raddr             = mem_ift.Mr.raddr;
    assign waddr             = mem_ift.Mw.waddr;
    assign wdata             = mem_ift.Mw.wdata;
    assign wmask             = mem_ift.Mw.wmask;
    assign mem_ift.Sr.rdata  = rdata;
    assign mem_ift.Sr.rvalid = rvalid;
    assign mem_ift.Sw.wvalid = wvalid;

    reg  [7:0] icache_ctrl;
    reg  [7:0] dcache_ctrl;

    wire       is_wicache = wen & (waddr == `ICACHE_BASE);
    wire       is_wdcahce = wen & (waddr == `DCACHE_BASE);

    always @(posedge clk) begin
        if (~rstn) begin
            icache_ctrl <= 8'b0;
            dcache_ctrl <= 8'b0;
        end else begin
            if (is_wicache) begin
                if (wmask[0]) icache_ctrl <= wdata[7:0];
            end
            if (is_wdcahce) begin
                if (wmask[0]) dcache_ctrl <= wdata[7:0];
            end
        end
    end

    wire        is_ricache = ren & (raddr == `ICACHE_BASE);
    wire        is_rdcache = ren & (raddr == `DCACHE_BASE);
    wire [63:0] icache_value = {63'b0, icache_ctrl[0]};
    wire [63:0] dcache_value = {63'b0, dcache_ctrl[0]};
    assign rdata                              = is_ricache ? icache_value : is_rdcache ? dcache_value : 64'b0;
    assign rvalid                             = 1'b1;
    assign wvalid                             = 1'b1;

    assign mmu_info.icache_ctrl.icache_enable = icache_ctrl[0];
    assign mmu_info.dcache_ctrl.dcache_enable = dcache_ctrl[0];

    assign cosim_mmio.store                   = ren;
    assign cosim_mmio.len                     = 64'd8;
    assign cosim_mmio.addr                    = raddr;
    assign cosim_mmio.val                     = rdata;

endmodule
