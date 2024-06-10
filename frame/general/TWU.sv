

module TWU #(
    parameter integer ADDR_WIDTH = 64,

)
(
    input clk,
    input rstn,

    input  [ADDR_WIDTH-1:0] va_from_core, // virtual address from core
    input                   request,
    input  [ADDR_WIDTH-1:0] pte_from_cache,
    input                   stall_cache,
    input  [ADDR_WIDTH-1:0] ppn_base,
    output                  stall_cpu,
    output [ADDR_WIDTH-1:0] pa_to_core,
    output                  ren_mmu_to_mem,
    output [ADDR_WIDTH-1:0] va_mmu_to_mem,
    output                  hit 

);

    localparam IDLE = 4'b0001;
    localparam L2   = 4'b0010;
    localparam L1   = 4'b0100;
    localparam L0   = 4'b1000;

    logic [3:0]state;
    logic [3:0]next_state;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end


endmodule