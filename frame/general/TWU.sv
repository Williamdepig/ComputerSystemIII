`include "PageStruct.vh"

module TWU #(
    parameter ADDR_WIDTH = 64,
    parameter STATE_NUM = 4
)
(
    input clk,
    input rstn,

    input  [ADDR_WIDTH-1:0] va_from_core, // virtual address from core
    input                   request,
    input  [ADDR_WIDTH-1:0] ppn_base,

    input  [ADDR_WIDTH-1:0] pte_from_cache,
    input                   stall_from_cache,

    output                  ren_to_cache,
    output [ADDR_WIDTH-1:0] pa_to_cache,

    output [ADDR_WIDTH-1:0] pa_to_core,
    output                  finish,
    output                  hit

);

    localparam IDLE = 4'b0001;
    localparam L2   = 4'b0010;
    localparam L1   = 4'b0100;
    localparam L0   = 4'b1000;
    typedef logic[STATE_NUM-1:0] state_t;
    typedef logic[ADDR_WIDTH-1:0] addr_t;


    PageStruct::PTEPack pte_pack;
    PTEDecode pte_decode (
        .pte(pte_from_cache),
        .pte_pack(pte_pack)
    );

    state_t state;
    state_t next_state;

    addr_t pa_temp;
    addr_t vpn2;
    addr_t vpn1;
    addr_t vpn0;
    addr_t offset;

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
                next_state = stall_from_cache ? L2 :
                             ~pte_pack.v ? IDLE :
                             pte_pack.r|pte_pack.w|pte_pack.x ? IDLE :
                             L1;
                pa_temp = pte_pack.ppn | vpn1;
            end
            L1: begin
                next_state = stall_from_cache ? L1 :
                             ~pte_pack.v ? IDLE :
                             pte_pack.r|pte_pack.w|pte_pack.x ? IDLE :
                             L0;
                pa_temp = pte_pack.ppn | vpn0;
            end
            L0: begin
                next_state = stall_from_cache ? L0 :
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

assign pa_to_cache = pa_temp;
assign ren_to_cache = (next_state != IDLE);

assign pa_to_core = pte_pack.ppn | offset;
assign finish = (state != IDLE) & (next_state == IDLE);
assign hit = pte_pack.v & (pte_pack.r | pte_pack.w | pte_pack.x);

endmodule