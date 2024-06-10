`include "Define.vh"
`include "MMIOStruct.vh"

module Displayer (
    input         clk,
    input         rstn,
    output [63:0] display_o,

    Mem_ift.Slave mem_ift,

    output MMIOStruct::MMIOPack cosim_mmio
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

    wire           is_wdisplay = wen & (waddr == `DISP_BASE);

    integer        i;
    reg     [ 7:0] disp [7:0];
    reg            busy;
    reg     [23:0] cnt;
    always @(posedge clk) begin
        if (!rstn) begin
            for (i = 0; i <= 7; i = i + 1) begin
                disp[i] <= 8'hf;
            end
        end else if (is_wdisplay & ~busy) begin
            for (i = 0; i <= 6; i = i + 1) begin
                disp[i+1] <= disp[i];
            end
            disp[0] <= wdata[7:0];
`ifdef VERILATE
            $write("%c", wdata[7:0]);
`endif
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            busy <= 1'b0;
            cnt  <= 24'b0;
        end
`ifndef VERILATE
        // else if(wen&~busy)begin
        //     busy<=1'b1;
        //     cnt<=24'hffffff;
        // end else if(cnt==24'b0)begin
        //     busy<=1'b0;
        // end else if(busy==1'b1)begin
        //     cnt<=cnt-24'b1;
        // end
`endif
    end

    genvar i1;
    generate
        for (i1 = 0; i1 <= 7; i1 = i1 + 1) begin : loop_i1
            assign display_o[i1*8+:8] = disp[i1];
        end
    endgenerate
    assign rdata            = ren & (raddr == `DISP_BASE) ? {busy, 63'b0} : 64'b0;

    assign rvalid           = 1'b1;
    assign wvalid           = 1'b1;

    assign cosim_mmio.store = ren;
    assign cosim_mmio.addr  = raddr;
    assign cosim_mmio.len   = 64'd8;
    assign cosim_mmio.val   = rdata;
endmodule
