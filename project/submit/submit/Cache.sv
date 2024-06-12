module Cache #(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM = 4,
    parameter integer CAPACITY = 1024
)
(
    input clk,
    input rstn,
    input [ADDR_WIDTH-1:0] addr_cpu,
    input [DATA_WIDTH-1:0] wdata_cpu,
    input wen_cpu,
    input [DATA_WIDTH/8-1:0] wmask_cpu,
    input ren_cpu,
    output [DATA_WIDTH-1:0] rdata_cpu,
    output hit_cpu,

    Mem_ift.Master mem_ift
);

    wire ren_mem;
    wire wen_mem;
    wire [ADDR_WIDTH-1:0] raddr_mem;
    wire [ADDR_WIDTH-1:0] waddr_mem;
    wire [DATA_WIDTH*2-1:0] wdata_mem;
    wire [DATA_WIDTH*2/8-1:0] wmask_mem;
    wire [DATA_WIDTH*2-1:0] rdata_mem;
    wire wvalid_mem;
    wire rvalid_mem;

    assign mem_ift.Mw.waddr=waddr_mem;
    assign mem_ift.Mr.raddr=raddr_mem;
    assign mem_ift.Mw.wen=wen_mem;
    assign mem_ift.Mr.ren=ren_mem;
    assign mem_ift.Mw.wdata=wdata_mem;
    assign mem_ift.Mw.wmask=wmask_mem;
    assign rdata_mem=mem_ift.Sr.rdata;
    assign rvalid_mem=mem_ift.Sr.rvalid;
    assign wvalid_mem=mem_ift.Sw.wvalid;

    localparam IDLE = 3'b001,
               READ = 3'b010,
               WRITE = 3'b100;
    localparam BANK_INDEX_TOTAL=BANK_NUM/2;
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

    wire [ADDR_WIDTH-1:0] addr_wb;
    wire [BANK_NUM*DATA_WIDTH-1:0] data_wb;
    wire busy_wb;
    wire need_wb;

    wire [ADDR_WIDTH-1:0] addr_cache;
    wire miss_cache;
    wire set_cache;
    wire busy_rd;
    wire [ADDR_WIDTH-1:0] addr_rd;
    wire [DATA_WIDTH*2-1:0] data_rd;
    wire wen_rd;
    wire set_rd;
    wire finish_rd;

    CacheBank #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM(BANK_NUM),
        .CAPACITY(CAPACITY)
    ) cache_bank (
        .clk(clk),
        .rstn(rstn),
        .addr_cpu(addr_cpu),
        .wdata_cpu(wdata_cpu),
        .wen_cpu(wen_cpu),
        .wmask_cpu(wmask_cpu),
        .ren_cpu(ren_cpu),
        .rdata_cpu(rdata_cpu),
        .hit_cpu(hit_cpu),

        .addr_wb(addr_wb),
        .data_wb(data_wb),
        .busy_wb(busy_wb),
        .need_wb(need_wb),

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

    wire [ADDR_WIDTH-1:0] addr_mem;
    wire [DATA_WIDTH*2-1:0] data_mem;
    wire [OFFSET_LEN-2:0] bank_index; 
    wire finish_wb;
    CacheWriteBuffer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM(BANK_NUM)
    ) cache_write_buffer (
        .clk(clk),
        .rstn(rstn),
        .addr_wb(addr_wb),
        .data_wb(data_wb),
        .busy_wb(busy_wb),
        .need_wb(need_wb),
        .miss_cache(miss_cache),

        .addr_mem(addr_mem),
        .data_mem(data_mem),
        .bank_index(bank_index),
        .finish_wb(finish_wb)
    );

    logic [2:0]state;
    logic [2:0]next_state;
    integer count;
    logic _busy_rd, _finish_rd, _wen_rd, set;
    logic [ADDR_WIDTH-1:0]addr;
    logic _ren_mem;

    logic _wen_mem;
    logic _finish_wb;
    logic [$clog2(BANK_NUM)-2:0]_bank_index;
    
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
        _bank_index = 0;
        _wen_mem = 0;
        _finish_rd = 0;
        _finish_wb = 0;
        case(state)
            IDLE: begin 
                next_state = miss_cache ? READ : IDLE;
            end  
            READ: begin
                next_state = count+1 != BANK_INDEX_TOTAL ? READ :
                             ~rvalid_mem ? READ :
                             busy_wb ? WRITE :
                             IDLE;
                _finish_rd = count+1 == BANK_INDEX_TOTAL && rvalid_mem;
                _ren_mem = ~rvalid_mem & ~_finish_rd;
                _wen_rd = rvalid_mem;
                _busy_rd = 1;
            end
            WRITE: begin
                next_state = count+1 != BANK_INDEX_TOTAL ? WRITE :
                             ~wvalid_mem ? WRITE :
                             IDLE;  
                _finish_wb = count+1 == BANK_INDEX_TOTAL && wvalid_mem;
                _bank_index = count[$clog2(BANK_NUM)-2:0];
                _wen_mem = ~wvalid_mem & ~_finish_wb;
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
                            next_state == WRITE ? addr_mem :
                            rvalid_mem ? addr + BYTE_NUM*2 :
                            addr;
                    count <= next_state != READ ? 0 :
                             rvalid_mem ? count+1 : 
                             count;
                    
                end
                WRITE:begin
                    count <= next_state != WRITE ? 0 :
                             wvalid_mem ? count+1 : 
                             count;
                    addr <=  next_state == IDLE ? 0 : 
                             wvalid_mem ? addr + BYTE_NUM*2 :
                             addr;               
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

    assign waddr_mem = addr;
    assign wdata_mem = data_mem;
    assign wen_mem = _wen_mem;
    assign finish_wb = _finish_wb;
    assign bank_index = _bank_index;
    assign wmask_mem = 16'hffff;

endmodule