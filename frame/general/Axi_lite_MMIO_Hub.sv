module Axi_lite_MMIO_Hub #(
    parameter integer AXI_ADDR_WIDTH = 64,
    parameter integer AXI_DATA_WIDTH = 64,
    parameter longint MEM0_BEGIN,
    parameter longint MEM0_END,
    parameter longint MEM1_BEGIN,
    parameter longint MEM1_END,
    parameter longint MEM2_BEGIN,
    parameter longint MEM2_END,
    parameter longint MEM3_BEGIN,
    parameter longint MEM3_END
) (
    input clk,
    input rstn,

    AXI_ift.Slave  master,
    AXI_ift.Master slave0,
    AXI_ift.Master slave1,
    AXI_ift.Master slave2,
    AXI_ift.Master slave3
);

    AXI_ift #(
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
    ) dummy_axi (
        .clk (clk),
        .rstn(rstn)
    );

    assign dummy_axi.Mw = '{awaddr: 0, awport: 0, awvalid: 0, wdata: 0, wvalid: 0, wstrb: 0, bready: 0};

    assign dummy_axi.Mr = '{araddr: 0, arport: 0, arvalid: 0, rready: 0};

    assign dummy_axi.Sw = '{awready: 0, wready: 0, bresp: 0, bvalid: 0};

    assign dummy_axi.Sr = '{arready: 0, rdata: 0, rresp: 0, rvalid: 0};

    wire [AXI_ADDR_WIDTH-1:0] waddr = master.Mw.awaddr;

    wire wismem0 = (MEM0_BEGIN <= waddr) & (waddr < MEM0_END);
    wire wismem1 = (MEM1_BEGIN <= waddr) & (waddr < MEM1_END);
    wire wismem2 = (MEM2_BEGIN <= waddr) & (waddr < MEM2_END);
    wire wismem3 = (MEM3_BEGIN <= waddr) & (waddr < MEM3_END);

    assign master.Sw = wismem0 ? slave0.Sw :
        wismem1 ? slave1.Sw : wismem2 ? slave2.Sw : wismem3 ? slave3.Sw : dummy_axi.Sw;

    assign slave0.Mw = wismem0 ? master.Mw : dummy_axi.Mw;
    assign slave1.Mw = wismem1 ? master.Mw : dummy_axi.Mw;
    assign slave2.Mw = wismem2 ? master.Mw : dummy_axi.Mw;
    assign slave3.Mw = wismem3 ? master.Mw : dummy_axi.Mw;

    wire [AXI_ADDR_WIDTH-1:0] raddr = master.Mr.araddr;
    
    wire rismem0 = (MEM0_BEGIN <= raddr) & (raddr < MEM0_END);
    wire rismem1 = (MEM1_BEGIN <= raddr) & (raddr < MEM1_END);
    wire rismem2 = (MEM2_BEGIN <= raddr) & (raddr < MEM2_END);
    wire rismem3 = (MEM3_BEGIN <= raddr) & (raddr < MEM3_END);

    assign master.Sr = rismem0 ? slave0.Sr :
        rismem1 ? slave1.Sr : rismem2 ? slave2.Sr : rismem3 ? slave3.Sr : dummy_axi.Sr;

    assign slave0.Mr = rismem0 ? master.Mr : dummy_axi.Mr;
    assign slave1.Mr = rismem1 ? master.Mr : dummy_axi.Mr;
    assign slave2.Mr = rismem2 ? master.Mr : dummy_axi.Mr;
    assign slave3.Mr = rismem3 ? master.Mr : dummy_axi.Mr;

endmodule
