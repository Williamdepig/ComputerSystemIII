`include "MMUStruct.vh"
`include "PageStruct.vh"
module MMU #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter PPN_WIDTH = 44
) (
    input clk,
    input rstn,
    input fence_flush,

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

    output page_fault_i,
    output page_fault_d,

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

    localparam BUSY_D=0'b10;
    localparam BUSY_I=0'b01;
    localparam N_BUSY=0'b00;

    localparam OFFSET = 12;
    typedef logic[ADDR_WIDTH-1:0] addr_t;
    typedef logic[DATA_WIDTH-1:0] data_t;

    logic translator_enable_reg;
    addr_t ppn_base;
    addr_t pte_i;
    addr_t pte_d;
    addr_t pte_from_cache;
    PageStruct::PTEPack pte_pack_i;
    PageStruct::PTEPack pte_pack_d;
    logic ren_twu;
    addr_t pa_twu;
    logic request;

    logic [DATA_WIDTH-1:0] rdata;
    logic [ADDR_WIDTH-1:0] raddr;
    logic                  ren;
    logic                  rvalid;

    logic [ADDR_WIDTH-1:0] raddr_i;
    logic                  ren_i;
    logic                  rvalid_i;

    logic [ADDR_WIDTH-1:0] raddr_d;
    logic                  ren_d;
    logic                  rvalid_d;

    wire tlb_stall_i;
    wire tlb_stall_d;

    logic [1:0]busy;

    Mem_ift #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mmu_ift ();

    TLB #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (4),
        .CAPACITY  (512)
    ) tlb_i(
        .clk    (clk),
        .rstn   (rstn & ~fence_flush),

        .va     (pc_vir),
        .request(if_request & translator_enable),

        .pte    (pte_i),
        .stall  (tlb_stall_i),

        .rdata  (rdata),
        .raddr  (raddr_i),
        .rvalid (rvalid_i),
        .ren    (ren_i)
    );

    TLB #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (4),
        .CAPACITY  (512)
    ) tlb_d(
        .clk    (clk),
        .rstn   (rstn & ~fence_flush),

        .va     (addr_vir),
        .request((wen_cpu|ren_cpu) & translator_enable),

        .pte    (pte_d),
        .stall  (tlb_stall_d),

        .rdata  (rdata),
        .raddr  (raddr_d),
        .rvalid (rvalid_d),
        .ren    (ren_d)
    );

    PTEDecode pte_decode_i(
        .pte(pte_i),
        .pte_pack(pte_pack_i)
    );

    PTEDecode pte_decode_d(
        .pte(pte_d),
        .pte_pack(pte_pack_d)
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


    assign ren = ren_i | ren_d;
    assign raddr = ren_d ? raddr_d :
                   ren_i ? raddr_i :
                   0;
    assign rvalid_i = (busy==BUSY_I) & rvalid;
    assign rvalid_d = (busy==BUSY_D) & rvalid;

    always @(posedge clk)begin
        if(~rstn)begin
            busy <= N_BUSY;
        end
        else if(ren) begin
            busy <= ren_d ? BUSY_D :
                    ren_i ? BUSY_I :
                    N_BUSY;
        end
        else begin
            busy <= N_BUSY;
        end
    end

    always @(posedge clk) begin
        if(~rstn) begin
            translator_enable_reg <= 0;
        end
        else if(fence_flush) begin
            translator_enable_reg <= 1;
        end
        else begin
            translator_enable_reg <= translator_enable_reg;
        end
    end

    wire translator_enable;

    assign translator_enable = translator_enable_reg;
    assign ppn_base = {{20{1'b0}} ,satp[PPN_WIDTH-1:0]};

    assign pc_phy = ~translator_enable ? pc_vir :
                    if_request ? (pte_pack_i.ppn | {{(ADDR_WIDTH-OFFSET){1'b0}},pc_vir[OFFSET-1:0]}) :
                    0;
    assign addr_phy = ~translator_enable ? addr_vir :
                      ren_twu            ? pa_twu :
                      (wen_cpu|ren_cpu)  ? (pte_pack_d.ppn | {{(ADDR_WIDTH-OFFSET){1'b0}},addr_vir[OFFSET-1:0]}) :
                      0;

    assign inst = inst_from_cache;
    assign rdata_to_cpu = rdata_from_cache;
    assign pte_from_cache = rdata_from_cache;

    assign if_mmu = if_request & (~tlb_stall_i) & (~page_fault_i);
    assign wen_mmu = wen_cpu & (~tlb_stall_d) & (~page_fault_d);
    assign ren_mmu = ren_twu | ((ren_cpu & (~tlb_stall_d)) & (~page_fault_d));

    assign if_stall_to_cpu = tlb_stall_i | if_stall_from_cache;
    assign mem_stall_to_cpu = tlb_stall_d | mem_stall_from_cache;

    assign wdata_mmu = wdata_cpu;
    assign wmask_mmu = wmask_cpu;

    wire _page_fault_d, _page_fault_i;

    assign _page_fault_d =( (wen_cpu&(~pte_pack_d.w|~pte_pack_d.v)) | (ren_cpu&(~pte_pack_d.r|~pte_pack_d.v)) );

    assign _page_fault_i = (if_request & (~pte_pack_i.x|~pte_pack_i.v));

    assign page_fault_d = _page_fault_d & translator_enable;
    assign page_fault_i = _page_fault_i & translator_enable;


endmodule