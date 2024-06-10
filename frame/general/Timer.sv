`include "Define.vh"
`include "TimerStruct.vh"
`include "MMIOStruct.vh"

module Timer (
    input clk,
    input rstn,

    Mem_ift.Slave mem_ift,

    output TimerStruct::TimerPack time_o,
    output MMIOStruct::MMIOPack   cosim_mmio,

    output [63:0] cosim_mtime,
    output [63:0] cosim_mtimecmp
);
    wire        ren;
    wire        wen;
    wire [63:0] raddr;
    wire [63:0] waddr;
    wire [63:0] wdata;
    wire [ 7:0] wmask;
    wire [63:0] rdata;
    wire        wvalid;
    wire        rvalid;

    assign ren               = mem_ift.Mr.ren;
    assign wen               = mem_ift.Mw.wen;
    assign raddr             = mem_ift.Mr.raddr;
    assign waddr             = mem_ift.Mw.waddr;
    assign wdata             = mem_ift.Mw.wdata;
    assign wmask             = mem_ift.Mw.wmask;
    assign mem_ift.Sr.rdata  = rdata;
    assign mem_ift.Sr.rvalid = rvalid;
    assign mem_ift.Sw.wvalid = wvalid;

    import MMIOStruct::MMIOPack;

    wire           is_wtime = wen & (waddr == `MTIME_BASE);
    wire           is_wtimecmp = wen & (waddr == `MTIMECMP_BASE);
    wire           is_rtime = ren & (raddr == `MTIME_BASE);
    wire           is_rtimecmp = ren & (raddr == `MTIMECMP_BASE);

    reg     [63:0] mtime;
    reg     [63:0] mtimecmp;
    integer        i;
    always @(posedge clk) begin
        if (~rstn) begin
            mtimecmp <= 64'h0;
        end else if (is_wtimecmp) begin
            for (i = 0; i <= 7; i = i + 1) begin
                if (wmask[i]) mtimecmp[i*8+:8] <= wdata[i*8+:8];
            end
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            mtime <= 64'h0;
        end else begin
            mtime <= mtime + 64'h1;
        end
    end

    assign rdata            = is_rtime ? mtime : is_rtimecmp ? mtimecmp : 64'b0;
    assign rvalid           = 1'b1;
    assign wvalid           = 1'b1;

    assign time_o.time_int  = mtimecmp < mtime;
    assign time_o._time     = mtime;
    assign cosim_mmio.store = ren;
    assign cosim_mmio.addr  = raddr;
    assign cosim_mmio.len   = 64'd8;
    assign cosim_mmio.val   = rdata;
    assign cosim_mtime      = mtime;
    assign cosim_mtimecmp   = mtimecmp;
endmodule
