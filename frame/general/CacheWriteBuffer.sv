module CacheWriteBuffer #(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM   = 4
) (
    input                            clk,
    input                            rstn,
    input  [         ADDR_WIDTH-1:0] addr_wb,
    input  [BANK_NUM*DATA_WIDTH-1:0] data_wb,
    output                           busy_wb,
    input                            need_wb,
    input                            miss_cache,

    output [  ADDR_WIDTH-1:0] addr_mem,
    output [DATA_WIDTH*2-1:0] data_mem,

    input [$clog2(BANK_NUM)-2:0] bank_index,
    input                        finish_wb
);
    reg                           busy;
    reg [         ADDR_WIDTH-1:0] addr;
    reg [DATA_WIDTH*BANK_NUM-1:0] data;
    
    always @(posedge clk) begin
        if (~rstn) begin
            addr <= {ADDR_WIDTH{1'b0}};
            data <= {BANK_NUM * DATA_WIDTH{1'b0}};
            busy <= 1'b0;
        end else if (miss_cache & need_wb) begin
            addr <= addr_wb;
            data <= data_wb;
            busy <= 1'b1;
        end else if (finish_wb) begin
            busy <= 1'b0;
        end
    end

    assign busy_wb  = busy;
    assign addr_mem = addr;
    wire [2*DATA_WIDTH-1:0] word[BANK_NUM/2-1:0];
    genvar i;
    generate
        for (i = 0; i < BANK_NUM / 2; i = i + 1) begin
            assign word[i] = data[(i*2+2)*DATA_WIDTH-1:i*2*DATA_WIDTH];
        end
    endgenerate
    assign data_mem = word[bank_index];
endmodule
