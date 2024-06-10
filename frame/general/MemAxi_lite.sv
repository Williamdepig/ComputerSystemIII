`timescale 1 ns / 1 ps

module MemAxi_lite #(
    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH = 64,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH = 64
) (
    AXI_ift.Slave  slave_ift,
    Mem_ift.Master mem_ift,

    output wire [1:0] debug_axi_wstate,
    output wire [1:0] debug_axi_rstate,
    output wire       debug_wen_mem,
    output wire       debug_ren_mem,
    output wire       debug_wvalid_mem,
    output wire       debug_rvalid_mem
);

    wire [    C_S_AXI_ADDR_WIDTH-1 : 0] waddr_mem;
    wire [    C_S_AXI_DATA_WIDTH-1 : 0] wdata_mem;
    wire [    C_S_AXI_ADDR_WIDTH-1 : 0] raddr_mem;
    wire [    C_S_AXI_DATA_WIDTH-1 : 0] rdata_mem;
    wire                                rvalid_mem;
    wire                                wvalid_mem;
    reg                                 wen_mem;
    reg                                 ren_mem;
    wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] wmask_mem;

    assign mem_ift.Mw.waddr = waddr_mem;
    assign mem_ift.Mw.wdata = wdata_mem;
    assign mem_ift.Mr.raddr = raddr_mem;
    assign rdata_mem        = mem_ift.Sr.rdata;
    assign rvalid_mem       = mem_ift.Sr.rvalid;
    assign wvalid_mem       = mem_ift.Sw.wvalid;
    assign mem_ift.Mw.wen   = wen_mem;
    assign mem_ift.Mr.ren   = ren_mem;
    assign mem_ift.Mw.wmask = wmask_mem;

    reg [  C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
    reg                              axi_awready;
    reg [  C_S_AXI_DATA_WIDTH-1 : 0] axi_wdata;
    reg [C_S_AXI_DATA_WIDTH/8-1 : 0] axi_wstrb;
    reg                              axi_wready;
    reg [                     1 : 0] axi_bresp;
    reg                              axi_bvalid;
    reg [  C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
    reg                              axi_arready;
    reg [  C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
    reg [                     1 : 0] axi_rresp;
    reg                              axi_rvalid;

    assign slave_ift.Sw.awready = axi_awready;
    assign slave_ift.Sw.wready  = axi_wready;
    assign slave_ift.Sw.bresp   = axi_bresp;
    assign slave_ift.Sw.bvalid  = axi_bvalid;
    assign slave_ift.Sr.arready = axi_arready;
    assign slave_ift.Sr.rdata   = axi_rdata;
    assign slave_ift.Sr.rresp   = axi_rresp;
    assign slave_ift.Sr.rvalid  = axi_rvalid;

    localparam WIDLE = 2'b00;
    localparam WGETDATA = 2'b01;
    localparam WWORK = 2'b10;
    localparam WBRESP = 2'b11;
    reg [1:0] wstate;
    always @(posedge slave_ift.clk) begin
        if (!slave_ift.rstn) begin
            wstate      <= WIDLE;
            axi_awaddr  <= {C_S_AXI_ADDR_WIDTH{1'b0}};
            axi_awready <= 1'b0;
            axi_wdata   <= {C_S_AXI_DATA_WIDTH{1'b0}};
            axi_wready  <= 1'b0;
            axi_bresp   <= 2'b0;
            axi_bvalid  <= 1'b0;
            wen_mem     <= 1'b0;
            axi_wstrb   <= {(C_S_AXI_DATA_WIDTH / 8) {1'b0}};
        end else begin
            case (wstate)
                WIDLE: begin
                    if (slave_ift.Mw.wvalid & slave_ift.Mw.awvalid) begin
                        axi_wready  <= 1'b1;
                        axi_awready <= 1'b1;
                        axi_awaddr  <= slave_ift.Mw.awaddr;
                        axi_wdata   <= slave_ift.Mw.wdata;
                        axi_wstrb   <= slave_ift.Mw.wstrb;
                        wstate      <= WGETDATA;
                    end
                end
                WGETDATA: begin
                    wen_mem     <= 1'b1;
                    wstate      <= WWORK;
                    axi_awready <= 1'b0;
                    axi_wready  <= 1'b0;
                end
                WWORK: begin
                    if (wvalid_mem) begin
                        wen_mem    <= 1'b0;
                        wstate     <= WBRESP;
                        axi_bvalid <= 1'b1;
                        axi_bresp  <= 2'b0;
                    end
                end
                WBRESP: begin
                    if (slave_ift.Mw.bready) begin
                        wstate     <= WIDLE;
                        axi_bvalid <= 1'b0;
                    end
                end
            endcase
        end
    end

    assign waddr_mem = axi_awaddr;
    assign raddr_mem = axi_araddr;
    assign wmask_mem = axi_wstrb;
    assign wdata_mem = axi_wdata;

    wire Wbusy = (slave_ift.Mw.wvalid & slave_ift.Mw.awvalid) & (wstate == WIDLE) | (wstate == WGETDATA) |
        (wstate == WWORK) & ~wvalid_mem;

    localparam RIDLE = 3'b000;
    localparam RGETADDR = 3'b001;
    localparam RWORK = 3'b010;
    localparam RRESP = 3'b011;
    localparam RKEEPDATA = 3'b100;
    reg [2:0] rstate;
    always @(posedge slave_ift.clk) begin
        if (!slave_ift.rstn) begin
            rstate      <= RIDLE;
            axi_arready <= 1'b0;
            axi_rvalid  <= 1'b0;
            axi_rresp   <= 2'b0;
            ren_mem     <= 1'b0;
            axi_araddr  <= {C_S_AXI_ADDR_WIDTH{1'b0}};
            axi_rdata   <= {C_S_AXI_DATA_WIDTH{1'b0}};
        end else begin
            case (rstate)
                RIDLE: begin
                    if (slave_ift.Mr.arvalid & ~Wbusy) begin
                        rstate      <= RGETADDR;
                        axi_arready <= 1'b1;
                        axi_araddr  <= slave_ift.Mr.araddr;
                    end
                end
                RGETADDR: begin
                    axi_arready <= 1'b0;
                    ren_mem     <= 1'b1;
                    rstate      <= RWORK;
                end
                RWORK: begin
                    if (rvalid_mem) begin
                        rstate <= RKEEPDATA;
                    end
                end
                RKEEPDATA: begin
                    rstate     <= RRESP;
                    ren_mem    <= 1'b0;
                    axi_rdata  <= rdata_mem;
                    axi_rvalid <= 1'b1;
                    axi_rresp  <= 2'b0;
                end
                default: begin
                    if (slave_ift.Mr.rready) begin
                        axi_rvalid <= 1'b0;
                        rstate     <= RIDLE;
                    end
                end
            endcase
        end
    end

    assign debug_axi_rstate = rstate[1:0];
    assign debug_axi_wstate = wstate;
    assign debug_wen_mem    = wen_mem;
    assign debug_ren_mem    = ren_mem;
    assign debug_wvalid_mem = wvalid_mem;
    assign debug_rvalid_mem = rvalid_mem;

endmodule
