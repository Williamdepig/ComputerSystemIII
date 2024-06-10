`include "MMUStruct.vh"

module Icache #(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM   = 4,
    parameter integer CAPACITY   = 1024
) (
    input                   clk,
    input                   rstn,
    input  [ADDR_WIDTH-1:0] pc,
    input                   if_request,
    output [          31:0] inst,
    input                   switch_mode,
    output                  if_stall,

    input MMUStruct::IcacheCtrl icache_ctrl,

    Mem_ift.Master mem_ift
);

    wire [DATA_WIDTH-1:0] inst_set;
    CacheWrap #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (BANK_NUM),
        .CAPACITY  (CAPACITY)
    ) cache_wrap (
        .clk         (clk),
        .rstn        (rstn),
        .addr_cpu    (pc),
        .wdata_cpu   ({DATA_WIDTH{1'b0}}),
        .wen_cpu     (1'b0),
        .wmask_cpu   ({(DATA_WIDTH / 8) {1'b0}}),
        .ren_cpu     (if_request),
        .rdata_cpu   (inst_set),
        .stall_cpu   (if_stall),
        .switch_mode (switch_mode),
        .cache_enable(icache_ctrl.icache_enable),
        .mem_ift     (mem_ift)
    );
    wire [31:0] insts[DATA_WIDTH/32-1:0];
    genvar i;
    generate
        for (i = 0; i < (DATA_WIDTH[31:0] / 32); i = i + 1) begin : set_inst
            assign insts[i] = inst_set[i*32+31:i*32];
        end
    endgenerate
    assign inst = insts[pc[2+$clog2(DATA_WIDTH/32)-1:2]];


endmodule
