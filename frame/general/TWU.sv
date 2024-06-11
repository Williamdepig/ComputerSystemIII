`include "PageStruct.vh"

module TWU #(
    parameter integer ADDR_WIDTH = 64,

)
(
    input clk,
    input rstn,

    input  [ADDR_WIDTH-1:0] va_from_core, // virtual address from core
    input                   request,
    input  [ADDR_WIDTH-1:0] ppn_base,

    input  [ADDR_WIDTH-1:0] pte_from_cache,
    input                   stall_cache,

    output                  ren_mmu_to_cache,
    output [ADDR_WIDTH-1:0] pa_mmu_to_cache,

    output [ADDR_WIDTH-1:0] pa_to_core,
    output                  finish,
    output                  hit

);

    localparam IDLE = 4'b0001;
    localparam L2   = 4'b0010;
    localparam L1   = 4'b0100;
    localparam L0   = 4'b1000;

    PageStruct::PTEPack pte_pack;
    PTEDecode pte_decode (
        .pte(pte_from_cache),
        .pte_pack(pte_pack)
    );

    logic [3:0]state;
    logic [3:0]next_state;
    logic [ADDR_WIDTH-1:0]pa_temp;
    logic [ADDR_WIDTH-1:0]vpn2;
    logic [ADDR_WIDTH-1:0]vpn1;
    logic [ADDR_WIDTH-1:0]vpn0;
    logic [ADDR_WIDTH-1:0]offset;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin

        case(state)
            IDLE: begin
                next_state = request ? L2 : IDLE;
                pa_temp = (ppn_base << 12) | vpn2;
            end
            L2: begin
                next_state = stall_cache ? L2 :
                             ~pte_pack.v ? IDLE :
                             pte_pack.r|pte_pack.w|pte_pack.x ? IDLE :
                             L1;
                pa_temp = pte_pack.ppn | vpn1;
            end
            L1: begin
                next_state = stall_cache ? L1 :
                             ~pte_pack.v ? IDLE :
                             pte_pack.r|pte_pack.w|pte_pack.x ? IDLE :
                             L0;
                pa_temp = pte_pack.ppn | vpn0;
            end
            L0: begin
                next_state = stall_cache ? L0 :
                             IDLE;
            end
            default: begin
                next_state = IDLE;
                pa_temp = {ADDR_WIDTH{1'b0}};
            end
        endcase

    end

assign vpn2 = va_from_core[38:30] << 3;
assign vpn1 = va_from_core[29:21] << 3;
assign vpn0 = va_from_core[20:12] << 3;
assign offset = va_from_core[11:0];

assign pa_mmu_to_cache = pa_temp;
assign ren_mmu_to_cache = (next_state != IDLE);

assign pa_to_core = pte_pack.ppn | offset;
assign finish = (state != IDLE) & (next_state == IDLE);
assign hit = pte_pack.v & (pte_pack.r | pte_pack.w | pte_pack.x);

endmodule