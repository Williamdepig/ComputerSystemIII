`include "MMUStruct.vh"
`include "PageStruct.vh"
module MMU #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter PPN_WIDTH = 44
) (
    input clk,
    input rstn,
    input fresh,

// core <--> mmu
    input  [DATA_WIDTH-1:0] satp,
    input  [ADDR_WIDTH-1:0] pc_vir,
    input  [ADDR_WIDTH-1:0] addr_vir,
    input if_request,
    input wen_cpu,
    input ren_cpu,
    input [DATA_WIDTH-1:0]   wdata_cpu,
    input [DATA_WIDTH/8-1:0] wmask_cpu,

    output if_stall_to_cpu,
    output mem_stall_to_cpu,
    output [DATA_WIDTH-1:0] rdata_to_cpu,
    output           [31:0] inst,

// mmu <--> cache
    output if_mmu,
    output wen_mmu,
    output ren_mmu,
    output [DATA_WIDTH-1:0]   wdata_mmu,
    output [DATA_WIDTH/8-1:0] wmask_mmu,
    
    input if_stall_from_cache,
    input mem_stall_from_cache,

    output [ADDR_WIDTH-1:0] pc_phy,
    output [ADDR_WIDTH-1:0] addr_phy,

    input [DATA_WIDTH-1:0] rdata_from_cache,
    input           [31:0] inst_from_cache
);

    localparam OFFSET = 12;
    typedef logic[ADDR_WIDTH-1:0] addr_t;
    typedef logic[DATA_WIDTH-1:0] data_t;

    logic translator_enable;
    addr_t ppn_base;
    addr_t va_core;
    addr_t pte;
    addr_t pte_from_cache;
    PageStruct::PTEPack pte_pack;
    logic ren_twu;
    addr_t pa_twu;
    logic request;

    logic [DATA_WIDTH-1:0] rdata;
    logic [ADDR_WIDTH-1:0] raddr;
    logic                  ren;
    logic                  rvalid;

    Mem_ift #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mmu_ift ();

    TLB #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (4),
        .CAPACITY  (512)
    ) tlb(
        .clk    (clk),
        .rstn   (rstn & ~fresh),

        .va     (va_core),
        .request(request),

        .pte    (pte),
        .stall  (tlb_stall),

        .rdata  (rdata),
        .raddr  (raddr),
        .rvalid (rvalid),
        .ren    (ren)
    );

    PTEDecode ptedecode(
        .pte(pte),
        .pte_pack(pte_pack)
    );

    TWU twu(
        .clk             (clk),
        .rstn            (rstn),

        .va              (raddr),
        .request         (ren),
        .ppn_base        (ppn_base),
        
        .pte_from_cache  (pte_from_cache),
        .stall_from_cache(mem_stall_from_cache),
        
        .ren_to_cache    (ren_twu),
        .pa_to_cache     (pa_twu),

        .pte             (rdata),
        .finish          (rvalid)
    );

    wire tlb_stall;

    assign translator_enable = (satp[63:60] == 8);
    assign ppn_base = {{20{1'b0}} ,satp[PPN_WIDTH-1:0]};

    assign pc_phy = ~translator_enable ? pc_vir :
                    if_request ? (pte_pack.ppn | {{(ADDR_WIDTH-OFFSET){1'b0}},pc_vir[OFFSET-1:0]}) :
                    0;
    assign addr_phy = ~translator_enable ? addr_vir :
                      ren_twu            ? pa_twu :
                      (wen_cpu|ren_cpu)  ? (pte_pack.ppn | {{(ADDR_WIDTH-OFFSET){1'b0}},addr_vir[OFFSET-1:0]}) :
                      0;
    assign va_core = (wen_cpu|ren_cpu) ? addr_vir :
                     if_request ? pc_vir :
                     0;

    assign inst = inst_from_cache;
    assign rdata_to_cpu = rdata_from_cache;
    assign pte_from_cache = rdata_from_cache;

    assign request = translator_enable & (wen_cpu | ren_cpu | if_request);
    assign if_mmu = if_request & (~tlb_stall);
    assign wen_mmu = wen_cpu & (~tlb_stall);
    assign ren_mmu = ren_twu | (ren_cpu & (~tlb_stall));

    assign if_stall_to_cpu = tlb_stall | if_stall_from_cache;
    assign mem_stall_to_cpu = tlb_stall | mem_stall_from_cache;

    assign wdata_mmu = wdata_cpu;
    assign wmask_mmu = wmask_cpu;

endmodule