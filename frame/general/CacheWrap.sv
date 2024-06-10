module CacheWrap #(
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
    output                    stall_cpu,

    input cache_enable,
    input switch_mode,

    Mem_ift.Master mem_ift
);
    reg cache_enable_reg;

    localparam BYTE_NUM = DATA_WIDTH / 8;
    wire [DATA_WIDTH-1:0] rdata_cache;
    wire                  hit_cache;
    Mem_ift #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH * 2)
    ) cache_ift ();

    Cache #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (BANK_NUM),
        .CAPACITY  (CAPACITY)
    ) cache (
        .clk      (clk),
        .rstn     (rstn),
        .addr_cpu (addr_cpu),
        .wdata_cpu(wdata_cpu),
        .wen_cpu  (wen_cpu & cache_enable_reg & ~switch_mode),
        .wmask_cpu(wmask_cpu),
        .ren_cpu  (ren_cpu & cache_enable_reg & ~switch_mode),
        .rdata_cpu(rdata_cache),
        .hit_cpu  (hit_cache),
        .mem_ift  (cache_ift.Master)
    );

    Mem_ift #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH * 2)
    ) direct_ift ();
    assign direct_ift.Mw.waddr = addr_cpu;
    assign direct_ift.Mw.wen = wen_cpu & ~cache_enable_reg & ~switch_mode;
    assign direct_ift.Mw.wdata = {wdata_cpu, wdata_cpu};
    assign direct_ift.Mw.wmask = addr_cpu[$clog2(
        BYTE_NUM
    )] ? {wmask_cpu, {(BYTE_NUM) {1'b0}}} : {{(BYTE_NUM) {1'b0}}, wmask_cpu};
    assign direct_ift.Mr.raddr = addr_cpu;
    assign direct_ift.Mr.ren = ren_cpu & ~cache_enable_reg & ~switch_mode;

    Mem_ift #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH * 2)
    ) dummy_ift ();
    assign dummy_ift.Mw = '{
            waddr: {ADDR_WIDTH{1'b0}},
            wen: 1'b0,
            wdata: {(2 * DATA_WIDTH) {1'b0}},
            wmask: {(2 * BYTE_NUM) {1'b0}}
        };
    assign dummy_ift.Sw = '{wvalid: 1'b0};
    assign dummy_ift.Mr = '{raddr: {ADDR_WIDTH{1'b0}}, ren: 1'b0};
    assign dummy_ift.Sr = '{rvalid: 1'b0, rdata: {(2 * DATA_WIDTH) {1'b0}}};

    assign mem_ift.Mw = cache_enable_reg ? cache_ift.Mw : direct_ift.Mw;
    assign mem_ift.Mr = cache_enable_reg ? cache_ift.Mr : direct_ift.Mr;

    assign cache_ift.Sr = cache_enable_reg ? mem_ift.Sr : dummy_ift.Sr;
    assign cache_ift.Sw = cache_enable_reg ? mem_ift.Sw : dummy_ift.Sw;
    assign direct_ift.Sr = cache_enable_reg ? dummy_ift.Sr : mem_ift.Sr;
    assign direct_ift.Sw = cache_enable_reg ? dummy_ift.Sw : mem_ift.Sw;

    assign rdata_cpu = cache_enable_reg ? rdata_cache : addr_cpu[$clog2(
        BYTE_NUM
    )] ? direct_ift.Sr.rdata[2*DATA_WIDTH-1:DATA_WIDTH] : direct_ift.Sr.rdata[DATA_WIDTH-1:0];

    wire _stall_cpu;
    reg  skip_if;
    reg _wen, _ren;
    always @(posedge clk) begin
        if (~rstn) begin
            skip_if <= 1'b0;
        end else if (_stall_cpu & switch_mode & ~cache_enable_reg) begin
            skip_if <= 1'b1;
        end else if (direct_ift.Sr.rvalid) begin
            skip_if <= 1'b0;
        end
    end
    always @(posedge clk) begin
        if (~rstn) begin
            _wen <= 1'b0;
            _ren <= 1'b0;
        end else if ((_wen | _ren) & ~cache_enable_reg) begin
            _wen <= _wen ? ~direct_ift.Sw.wvalid : 0;
            _ren <= _ren ? ~direct_ift.Sr.rvalid : 0;
        end else if ((ren_cpu | wen_cpu) & ~cache_enable_reg & ~switch_mode) begin
            _wen <= wen_cpu;
            _ren <= ren_cpu;
        end
    end
    assign _stall_cpu = cache_enable_reg ? (wen_cpu | ren_cpu) & ~hit_cache :
        ((wen_cpu | _wen) & ~direct_ift.Sw.wvalid) | ((ren_cpu | _ren) & ~direct_ift.Sr.rvalid);
    assign stall_cpu = (_stall_cpu | skip_if) & ~switch_mode;
    
    wire transac_not_finish = mem_ift.Mr.ren & ~mem_ift.Sr.rvalid | mem_ift.Mw.wen & ~mem_ift.Sw.wvalid;
    always @(posedge clk) begin
        if (~rstn) cache_enable_reg <= 1'b0;
        else if (cache_enable_reg ^ cache_enable & ~transac_not_finish) begin
            cache_enable_reg <= cache_enable;
        end
    end

endmodule
