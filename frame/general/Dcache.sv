`include "MMUStruct.vh"

module Dcache #(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM   = 4,
    parameter integer CAPACITY   = 1024
) (
    input                     clk,
    input                     rstn,
    input  [  ADDR_WIDTH-1:0] addr_cpu,
    input  [  DATA_WIDTH-1:0] wdata_cpu,
    input                     wen_cpu,
    input  [DATA_WIDTH/8-1:0] wmask_cpu,
    input                     ren_cpu,
    output [  DATA_WIDTH-1:0] rdata_cpu,
    output                    data_stall,
    input                     switch_mode,

    input MMUStruct::DcacheCtrl dcache_ctrl,

    Mem_ift.Master mem_ift
);

    CacheWrap #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (BANK_NUM),
        .CAPACITY  (CAPACITY)
    ) cache_wrap (
        .clk         (clk),
        .rstn        (rstn),
        .addr_cpu    (addr_cpu),
        .wdata_cpu   (wdata_cpu),
        .wen_cpu     (wen_cpu),
        .wmask_cpu   (wmask_cpu),
        .ren_cpu     (ren_cpu),
        .rdata_cpu   (rdata_cpu),
        .stall_cpu   (data_stall),
        .switch_mode (switch_mode),
        .cache_enable(dcache_ctrl.dcache_enable),
        .mem_ift     (mem_ift)
    );


endmodule
