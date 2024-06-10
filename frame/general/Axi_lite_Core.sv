`include "CSRStruct.vh"
`include "RegStruct.vh"
`include "TimerStruct.vh"
`include "MMUStruct.vh"

module Axi_lite_Core #(
    parameter integer C_M_AXI_ADDR_WIDTH     = 64,
    parameter integer C_M_AXI_DATA_WIDTH     = 64,
    parameter integer C_M_AXI_MEM_DATA_WIDTH = 128
) (
    AXI_ift.Master if_ift,
    AXI_ift.Master mem_ift,
    AXI_ift.Master mmio_ift,

    input TimerStruct::TimerPack time_out,
    input MMUStruct::MMUPack     mmu_info,

    output wire        cosim_valid,
    output wire [63:0] cosim_pc,         /* current pc */
    output wire [31:0] cosim_inst,       /* current instruction */
    output wire [ 7:0] cosim_rs1_id,     /* rs1 id */
    output wire [63:0] cosim_rs1_data,   /* rs1 data */
    output wire [ 7:0] cosim_rs2_id,     /* rs2 id */
    output wire [63:0] cosim_rs2_data,   /* rs2 data */
    output wire [63:0] cosim_alu,        /* alu out */
    output wire [63:0] cosim_mem_addr,   /* memory address */
    output wire [ 3:0] cosim_mem_we,     /* memory write enable */
    output wire [63:0] cosim_mem_wdata,  /* memory write data */
    output wire [63:0] cosim_mem_rdata,  /* memory read data */
    output wire [ 3:0] cosim_rd_we,      /* rd write enable */
    output wire [ 7:0] cosim_rd_id,      /* rd id */
    output wire [63:0] cosim_rd_data,    /* rd data */
    output wire [ 3:0] cosim_br_taken,   /* branch taken? */
    output wire [63:0] cosim_npc,        /* next pc */

    output CSRStruct::CSRPack cosim_csr_info,
    output RegStruct::RegPack cosim_regs,

    output        cosim_interrupt,
    output [63:0] cosim_cause
);
    wire [63:0] pc;
    wire [63:0] address_cpu;
    wire        wen_cpu;
    wire        ren_cpu;
    wire [63:0] wdata_cpu;
    wire [ 7:0] wmask_cpu;
    wire [31:0] inst;
    wire [63:0] rdata_cpu;
    wire        if_stall;
    wire        mem_stall;
    wire        if_request;

    wire        clk = mem_ift.clk;
    wire        rstn = mem_ift.rstn;
    wire        switch_mode;

    Core core (
        .clk        (clk),
        .rstn       (rstn),
        .time_out   (time_out),
        .pc         (pc),
        .inst       (inst),
        .address    (address_cpu),
        .we_mem     (wen_cpu),
        .wdata_mem  (wdata_cpu),
        .wmask_mem  (wmask_cpu),
        .re_mem     (ren_cpu),
        .rdata_mem  (rdata_cpu),
        .if_request (if_request),
        .switch_mode(switch_mode),
        .if_stall   (if_stall),
        .mem_stall  (mem_stall),

        .cosim_valid    (cosim_valid),
        .cosim_pc       (cosim_pc),
        .cosim_inst     (cosim_inst),
        .cosim_rs1_id   (cosim_rs1_id),
        .cosim_rs1_data (cosim_rs1_data),
        .cosim_rs2_id   (cosim_rs2_id),
        .cosim_rs2_data (cosim_rs2_data),
        .cosim_alu      (cosim_alu),
        .cosim_mem_addr (cosim_mem_addr),
        .cosim_mem_we   (cosim_mem_we),
        .cosim_mem_wdata(cosim_mem_wdata),
        .cosim_mem_rdata(cosim_mem_rdata),
        .cosim_rd_we    (cosim_rd_we),
        .cosim_rd_id    (cosim_rd_id),
        .cosim_rd_data  (cosim_rd_data),
        .cosim_br_taken (cosim_br_taken),
        .cosim_npc      (cosim_npc),
        .cosim_csr_info (cosim_csr_info),
        .cosim_regs     (cosim_regs),
        .cosim_interrupt(cosim_interrupt),
        .cosim_cause    (cosim_cause)
    );

    Mem_ift #(
        .ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .DATA_WIDTH(C_M_AXI_MEM_DATA_WIDTH)
    ) if_info ();
    Icache #(
        .ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .BANK_NUM  (4),
        .CAPACITY  (256)
    ) icache (
        .clk        (clk),
        .rstn       (rstn),
        .pc         (pc),
        .if_request (if_request),
        .inst       (inst),
        .if_stall   (if_stall),
        .switch_mode(switch_mode),
        .icache_ctrl(mmu_info.icache_ctrl),
        .mem_ift    (if_info)
    );

    wire [63:0] rdata_cpu_from_mem;
    wire        mem_stall_from_mem;
    wire        wen_cpu_to_mem;
    wire        ren_cpu_to_mem;
    Mem_ift #(
        .ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .DATA_WIDTH(C_M_AXI_MEM_DATA_WIDTH)
    ) mem_info ();
    Dcache #(
        .ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .BANK_NUM  (4),
        .CAPACITY  (256)
    ) dcache (
        .clk        (clk),
        .rstn       (rstn),
        .addr_cpu   (address_cpu),
        .wen_cpu    (wen_cpu_to_mem),
        .ren_cpu    (ren_cpu_to_mem),
        .wdata_cpu  (wdata_cpu),
        .wmask_cpu  (wmask_cpu),
        .rdata_cpu  (rdata_cpu_from_mem),
        .switch_mode(switch_mode),
        .data_stall (mem_stall_from_mem),
        .dcache_ctrl(mmu_info.dcache_ctrl),
        .mem_ift    (mem_info.Master)
    );

    wire        wen_cpu_to_mmio;
    wire        ren_cpu_to_mmio;
    wire [63:0] rdata_cpu_from_mmio;
    wire        mem_stall_from_mmio;
    Mem_ift #(
        .ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH)
    ) mmio_info ();
    Core2MMIO_FSM mmio_fsm (
        .address_cpu(address_cpu),
        .wen_cpu    (wen_cpu_to_mmio),
        .ren_cpu    (ren_cpu_to_mmio),
        .wdata_cpu  (wdata_cpu),
        .wmask_cpu  (wmask_cpu),
        .rdata_cpu  (rdata_cpu_from_mmio),
        .mem_stall  (mem_stall_from_mmio),
        .mem_ift    (mmio_info.Master)
    );

    CrossBar crossbar (
        .wen_cpu            (wen_cpu),
        .ren_cpu            (ren_cpu),
        .mem_stall          (mem_stall),
        .rdata_cpu          (rdata_cpu),
        .address_cpu        (address_cpu),
        .wen_cpu_to_mem     (wen_cpu_to_mem),
        .ren_cpu_to_mem     (ren_cpu_to_mem),
        .mem_stall_from_mem (mem_stall_from_mem),
        .rdata_cpu_from_mem (rdata_cpu_from_mem),
        .wen_cpu_to_mmio    (wen_cpu_to_mmio),
        .ren_cpu_to_mmio    (ren_cpu_to_mmio),
        .mem_stall_from_mmio(mem_stall_from_mmio),
        .rdata_cpu_from_mmio(rdata_cpu_from_mmio)
    );

    CoreAxi_lite #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_MEM_DATA_WIDTH)
    ) if_axi_lite (
        .master_ift(if_ift),
        .mem_ift   (if_info.Slave),
        .wresp_mem (),
        .rresp_mem ()
    );

    CoreAxi_lite #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_MEM_DATA_WIDTH)
    ) mem_axi_lite (
        .master_ift(mem_ift),
        .mem_ift   (mem_info.Slave),
        .wresp_mem (),
        .rresp_mem ()
    );

    CoreAxi_lite #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
    ) mmio_axi_lite (
        .master_ift(mmio_ift),
        .mem_ift   (mmio_info.Slave),
        .wresp_mem (),
        .rresp_mem ()
    );

endmodule
