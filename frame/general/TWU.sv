`include "PageStruct.vh"

module TWU #(
    parameter ADDR_WIDTH = 64,
    parameter STATE_NUM = 4
)
(
    input clk,
    input rstn,

    input  [ADDR_WIDTH-1:0] va,
    input                   request,
    input  [ADDR_WIDTH-1:0] ppn_base,

    input  [ADDR_WIDTH-1:0] pte_from_cache,
    input                   stall_from_cache,

    output                  ren_to_cache,
    output [ADDR_WIDTH-1:0] pa_to_cache,

    output [ADDR_WIDTH-1:0] pte,
    output                  finish

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
    addr_t _pte;

    logic _ren;
    logic _finish;

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
            end
            L2: begin
                next_state = stall_from_cache ? L2 :
                             ~pte_pack.v ? IDLE :
                             pte_pack.r|pte_pack.w|pte_pack.x ? IDLE :
                             L1;
            end
            L1: begin
                next_state = stall_from_cache ? L1 :
                             ~pte_pack.v ? IDLE :
                             pte_pack.r|pte_pack.w|pte_pack.x ? IDLE :
                             L0;
            end
            L0: begin
                next_state = stall_from_cache ? L0 :
                             IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk)begin

        if(~rstn)begin
            pa_temp <=0;
            _finish <= 0;
            _ren <= 0;
            _pte <= 0;
        end
        else begin
            case(state) 
                IDLE: begin
                    _ren <= next_state != IDLE ? 1 : 0;
                    _finish <= 0;
                    pa_temp <= next_state == L2 ? ((ppn_base << 12) | vpn2) : 0;
                    _pte <= 0;
                end
                L2: begin
                    _ren <= next_state == IDLE ? 0 : 1;
                    _finish <= next_state == IDLE ? 1 : 0;
                    pa_temp <= next_state == L1 ? (pte_pack.ppn | vpn1) : pa_temp;
                    _pte <= next_state == IDLE ? pte_from_cache : _pte;
                end
                L1: begin
                    _ren <= next_state == IDLE ? 0 : 1;
                    _finish <= next_state == IDLE ? 1 : 0;
                    pa_temp <= next_state == L0 ? (pte_pack.ppn | vpn0) : pa_temp;
                    _pte <= next_state == IDLE ? pte_from_cache : _pte;
                end
                L0: begin
                    _ren <= next_state == IDLE ? 0 : 1;
                    _finish <= next_state == IDLE ? 1 : 0; 
                    pa_temp <= pa_temp;
                    _pte <= next_state == IDLE ? pte_from_cache : _pte;
                end
                default: begin

                end
            endcase
        end

    end


assign vpn2 = {{52{1'b0}},va[38:30],{3{1'b0}}};
assign vpn1 = {{52{1'b0}},va[29:21],{3{1'b0}}};
assign vpn0 = {{52{1'b0}},va[20:12],{3{1'b0}}};
assign offset = {{52{1'b0}},va[11:0]};

assign pa_to_cache = pa_temp;
assign ren_to_cache = _ren;

assign pte = _pte;
assign finish = _finish;

endmodule