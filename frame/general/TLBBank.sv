module TLBBank #(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM   = 4,
    parameter integer CAPACITY   = 1024
) (
    input clk,
    input rstn,

    input  [  ADDR_WIDTH-1:0] addr_cpu,
    input  [  DATA_WIDTH-1:0] wdata_cpu,
    input                     wen_cpu,
    input  [DATA_WIDTH/8-1:0] wmask_cpu,
    input                     ren_cpu,
    output [  DATA_WIDTH-1:0] rdata_cpu,
    output                    hit_cpu,



    output [  ADDR_WIDTH-1:0] addr_cache,
    output                    miss_cache,
    output                    set_cache,
    input                     busy_rd,
    input  [  ADDR_WIDTH-1:0] addr_rd,
    input  [  DATA_WIDTH-1:0] data_rd,
    input                     wen_rd,
    input                     set_rd,
    input                     finish_rd
);

    localparam BYTE_NUM = DATA_WIDTH / 8;
    localparam LINE_NUM = CAPACITY / 2 / (BANK_NUM * BYTE_NUM);
    localparam GRANU_LEN = $clog2(BYTE_NUM);
    localparam GRANU_BEGIN = 0;
    localparam GRANU_END = GRANU_BEGIN + GRANU_LEN - 1;
    localparam OFFSET_LEN = $clog2(BANK_NUM);
    localparam OFFSET_BEGIN = 0;
    localparam OFFSET_END = OFFSET_BEGIN + OFFSET_LEN - 1;
    localparam INDEX_LEN = $clog2(LINE_NUM);
    localparam INDEX_BEGIN = OFFSET_END + 1;
    localparam INDEX_END = INDEX_BEGIN + INDEX_LEN - 1;
    localparam TAG_BEGIN = INDEX_END + 1;
    localparam TAG_END = ADDR_WIDTH - 1;
    localparam TAG_LEN = ADDR_WIDTH - TAG_BEGIN;

    typedef logic [TAG_LEN-1:0] tag_t;
    typedef logic [INDEX_LEN-1:0] index_t;
    typedef logic [OFFSET_LEN-1:0] offset_t;
    typedef logic [BANK_NUM*DATA_WIDTH-1:0] data_t;

    typedef struct {
        logic  valid;
        logic  dirty;
        logic  lru;
        tag_t  tag;
        data_t data;
    } CacheLine;

    CacheLine set        [1:0][LINE_NUM-1:0];

    tag_t     tag_cpu;
    index_t   index_cpu;
    offset_t  offset_cpu;
    assign tag_cpu    = addr_cpu[TAG_END:TAG_BEGIN];
    assign index_cpu  = addr_cpu[INDEX_END:INDEX_BEGIN];
    assign offset_cpu = addr_cpu[OFFSET_END:OFFSET_BEGIN];

    tag_t    tag_rd;
    index_t  index_rd;
    offset_t offset_rd;
    assign tag_rd    = addr_rd[TAG_END:TAG_BEGIN];
    assign index_rd  = addr_rd[INDEX_END:INDEX_BEGIN];
    assign offset_rd = addr_rd[OFFSET_END:OFFSET_BEGIN];

    wire      [           1:0] hit;
    CacheLine                  index_line     [1:0];
    wire      [DATA_WIDTH-1:0] index_line_data[1:0] [BANK_NUM-1:0];
    assign index_line[0] = set[0][index_cpu];
    assign index_line[1] = set[1][index_cpu];
    genvar v;
    generate
        for (v = 0; v < BANK_NUM; v = v + 1) begin : unpack_index_line
            assign index_line_data[0][v] = index_line[0].data[DATA_WIDTH*v+DATA_WIDTH-1:DATA_WIDTH*v];
            assign index_line_data[1][v] = index_line[1].data[DATA_WIDTH*v+DATA_WIDTH-1:DATA_WIDTH*v];
        end
    endgenerate
    assign hit[0] = (index_line[0].tag == tag_cpu) & index_line[0].valid;
    assign hit[1] = (index_line[1].tag == tag_cpu) & index_line[1].valid;
    assign hit_cpu = |hit;
    assign rdata_cpu = hit[0] ? index_line_data[0][offset_cpu] : index_line_data[1][offset_cpu];

    assign set_cache = index_line[0].lru;
    CacheLine replace_line;
    assign replace_line = index_line[set_cache];
    wire [OFFSET_END:0] pad_zero = {(OFFSET_END + 1) {1'b0}};
    wire                miss_happen = ~hit_cpu & (wen_cpu | ren_cpu);
    assign miss_cache = miss_happen & ~busy_rd;
    assign addr_cache = {addr_cpu[TAG_END:INDEX_BEGIN], pad_zero};

    integer i;
    integer j;
    integer k;
    integer l;
    always @(posedge clk) begin
        if (~rstn) begin
            for (i = 0; i < LINE_NUM; i = i + 1) begin
                set[0][i].valid <= 1'b0;
                set[1][i].valid <= 1'b0;
            end
        end else if (finish_rd) begin
            set[set_rd][index_rd].valid <= 1'b1;
        end else if (miss_cache) begin
            set[set_cache][index_cpu].valid <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            for (i = 0; i < LINE_NUM; i = i + 1) begin
                set[0][i].dirty <= 1'b0;
                set[1][i].dirty <= 1'b0;
            end
        end else if (hit_cpu & wen_cpu) begin
            if (hit[0]) set[0][index_cpu].dirty <= 1'b1;
            if (hit[1]) set[1][index_cpu].dirty <= 1'b1;
        end else if (miss_cache) begin
            set[set_cache][index_cpu].dirty <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            for (i = 0; i < LINE_NUM; i = i + 1) begin
                set[0][i].lru <= 1'b0;
                set[1][i].lru <= 1'b0;
            end
        end else if (hit_cpu & (wen_cpu | ren_cpu)) begin
            set[0][index_cpu].lru <= hit[0];
            set[1][index_cpu].lru <= hit[1];
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            for (i = 0; i < LINE_NUM; i = i + 1) begin
                set[0][i].tag <= {TAG_LEN{1'b0}};
                set[1][i].tag <= {TAG_LEN{1'b0}};
            end
        end else if (miss_cache) begin
            set[set_cache][index_cpu].tag <= tag_cpu;
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            for (i = 0; i < 2; i = i + 1) begin
                for (j = 0; j < LINE_NUM; j = j + 1) begin
                    set[i][j].data <= {(DATA_WIDTH * BANK_NUM) {1'b0}};
                end
            end
        end else begin
            for (i = 0; i < 2; i = i + 1) begin
                for (j = 0; j < LINE_NUM; j = j + 1) begin
                    for (k = 0; k < BANK_NUM; k = k + 1) begin
                        if (set_rd == i[0] & wen_rd & index_rd == j[INDEX_LEN-1:0] &
                            offset_rd[OFFSET_LEN-1:0] == k[OFFSET_LEN-1:0]) begin
                            set[i][j].data[k*DATA_WIDTH+:DATA_WIDTH] <= data_rd;
                        end else if (hit[i] & wen_cpu & index_cpu == j[INDEX_LEN-1:0] &
                                     k[OFFSET_LEN-1:0] == offset_cpu) begin
                            for (l = 0; l < BYTE_NUM; l = l + 1) begin
                                if (wmask_cpu[l]) set[i][j].data[k*DATA_WIDTH+8*l+:8] <= wdata_cpu[8*l+:8];
                            end
                        end
                    end
                end
            end
        end
    end
endmodule


