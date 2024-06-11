`include "MMUStruct.vh"

module TLB #(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM   = 4,
    parameter integer CAPACITY   = 1024
) (
    input                   clk,
    input                   rstn,
    input  [ADDR_WIDTH-1:0] va,
    input                   request,
    output [ADDR_WIDTH-1:0] pte,
    output                  stall,

    input  [DATA_WIDTH-1:0] rdata,
    output [ADDR_WIDTH-1:0] raddr,
    input                   rvalid,
    output                  ren
);

    wire [ADDR_WIDTH-1:0] vpn;
    assign vpn = va >> 12;

    wire ren_mem;
    wire [ADDR_WIDTH-1:0] raddr_mem;
    wire [DATA_WIDTH-1:0] rdata_mem;
    wire rvalid_mem;
    wire hit;

    assign ren = ren_mem;
    assign raddr = raddr_mem;
    assign rdata_mem = rdata;
    assign rvalid_mem = rvalid;

    localparam IDLE = 2'b01,
               READ = 2'b10;
    localparam BANK_INDEX_TOTAL=BANK_NUM;
    localparam BYTE_NUM=DATA_WIDTH/8;
    localparam LINE_NUM=CAPACITY/2/(BANK_NUM*BYTE_NUM);
    localparam GRANU_LEN=$clog2(BYTE_NUM);
    localparam GRANU_BEGIN=0;
    localparam GRANU_END=GRANU_BEGIN+GRANU_LEN-1;
    localparam OFFSET_LEN=$clog2(BANK_NUM);
    localparam OFFSET_BEGIN=GRANU_END+1;
    localparam OFFSET_END=OFFSET_BEGIN+OFFSET_LEN-1;
    localparam INDEX_LEN=$clog2(LINE_NUM);
    localparam INDEX_BEGIN=OFFSET_END+1;
    localparam INDEX_END=INDEX_BEGIN+INDEX_LEN-1;
    localparam TAG_BEGIN=INDEX_END+1;
    localparam TAG_END=ADDR_WIDTH-1;
    localparam TAG_LEN=ADDR_WIDTH-TAG_BEGIN;
    typedef logic [TAG_LEN-1:0] tag_t;
    typedef logic [INDEX_LEN-1:0] index_t;
    typedef logic [OFFSET_LEN-1:0] offset_t;


    wire [ADDR_WIDTH-1:0] addr_cache;
    wire miss_cache;
    wire set_cache;
    wire busy_rd;
    wire [ADDR_WIDTH-1:0] addr_rd;
    wire [DATA_WIDTH-1:0] data_rd;
    wire wen_rd;
    wire set_rd;
    wire finish_rd;

    TLBBank #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM(BANK_NUM),
        .CAPACITY(CAPACITY)
    ) tlb_bank (
        .clk(clk),
        .rstn(rstn),
        .addr_cpu(vpn),
        .wdata_cpu(0),
        .wen_cpu(0),
        .wmask_cpu(0),
        .ren_cpu(request),
        .rdata_cpu(pte),
        .hit_cpu(hit),

        .addr_cache(addr_cache),
        .miss_cache(miss_cache),
        .set_cache(set_cache),

        .busy_rd(busy_rd),
        .addr_rd(addr_rd),
        .data_rd(data_rd),
        .wen_rd(wen_rd),
        .set_rd(set_rd),
        .finish_rd(finish_rd)
    );

    logic [1:0]state;
    logic [1:0]next_state;
    integer count;
    logic _busy_rd, _finish_rd, _wen_rd, set;
    logic [ADDR_WIDTH-1:0]addr;
    logic _finish_wb;
    logic _ren_mem;
    
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end
    always @(*) begin
        _ren_mem = 0;
        _wen_rd = 0;
        _busy_rd = 0;
        _finish_rd = 0;
        case(state)
            IDLE: begin 
                next_state = miss_cache ? READ : IDLE;
            end  
            READ: begin
                next_state = count+1 != BANK_INDEX_TOTAL ? READ :
                             ~rvalid_mem ? READ :
                             IDLE;
                _finish_rd = count+1 == BANK_INDEX_TOTAL && rvalid_mem;
                _ren_mem = ~rvalid_mem & ~_finish_rd;
                _wen_rd = rvalid_mem;
                _busy_rd = 1;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            count <= 0;
            set <= 0;
            addr <= {ADDR_WIDTH{1'b0}};
        end
        else begin
            case(state)
                READ: begin
                    addr <= next_state == IDLE ? 0 :
                            rvalid_mem ? addr + BYTE_NUM*2 :
                            addr;
                    count <= next_state != READ ? 0 :
                             rvalid_mem ? count+1 : 
                             count;
                    
                end
                IDLE:begin
                    count <= 0;
                    if(next_state == READ) begin
                        set <= set_cache;
                        addr <= addr_cache;
                    end else begin
                        set <= 0;
                        addr <= {ADDR_WIDTH{1'b0}};     
                    end
                end
                default:begin
                    count <= 0;
                    set <= 0;
                    addr <= {ADDR_WIDTH{1'b0}};
                end
            endcase
        end
    end

    assign ren_mem = _ren_mem;
    assign raddr_mem = addr;

    assign busy_rd = _busy_rd;
    assign finish_rd = _finish_rd;
    assign wen_rd = _wen_rd;
    assign addr_rd = addr;
    assign set_rd = set;
    assign data_rd = rdata_mem;

    assign stall = request & ~hit;
endmodule