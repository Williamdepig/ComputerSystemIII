module CoreAxi_lite #(
    // Width of M_AXI address bus. 
    // The master generates the read and write addresses of width specified as C_M_AXI_ADDR_WIDTH.
    parameter integer C_M_AXI_ADDR_WIDTH = 64,
    // Width of M_AXI data bus. 
    // The master issues write data and accept read data where the width of the data bus is C_M_AXI_DATA_WIDTH
    parameter integer C_M_AXI_DATA_WIDTH = 64
) (
    AXI_ift.Master master_ift,
    Mem_ift.Slave  mem_ift,

    output reg [1:0] wresp_mem,
    output reg [1:0] rresp_mem
);

    reg                              axi_awvalid;
    reg [  C_M_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
    reg                              axi_wvalid;
    reg [  C_M_AXI_DATA_WIDTH-1 : 0] axi_wdata;
    reg [C_M_AXI_DATA_WIDTH/8-1 : 0] axi_wstrb;
    reg                              axi_bready;
    reg                              axi_arvalid;
    reg [  C_M_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
    reg                              axi_rready;
    reg [  C_M_AXI_DATA_WIDTH-1 : 0] axi_rdata;
    reg [                       1:0] axi_resp;
    reg [                       1:0] axi_bresp;

    assign master_ift.Mw.awaddr  = axi_awaddr;
    assign master_ift.Mw.wdata   = axi_wdata;
    assign master_ift.Mw.awport  = 3'b000;
    assign master_ift.Mw.awvalid = axi_awvalid;
    assign master_ift.Mw.wvalid  = axi_wvalid;
    assign master_ift.Mw.wstrb   = axi_wstrb;
    assign master_ift.Mw.bready  = axi_bready;
    assign master_ift.Mr.araddr  = axi_araddr;
    assign master_ift.Mr.arvalid = axi_arvalid;
    assign master_ift.Mr.arport  = 3'b001;
    assign master_ift.Mr.rready  = axi_rready;

    localparam WIDLE = 2'b00;
    localparam WSETDATA = 2'b01;
    localparam WWAITDATA = 2'b10;
    localparam WWAITBRESP = 2'b11;

    reg [1:0] wstate;

    always @(posedge master_ift.clk) begin
        if (~master_ift.rstn) begin
            axi_awvalid <= 1'b0;
            axi_wvalid  <= 1'b0;
            axi_bready  <= 1'b0;
            wstate      <= WIDLE;
            axi_awaddr  <= {C_M_AXI_ADDR_WIDTH{1'b0}};
            axi_wdata   <= {C_M_AXI_DATA_WIDTH{1'b0}};
            axi_wstrb   <= {(C_M_AXI_DATA_WIDTH / 8) {1'b0}};
        end else begin
            case (wstate)
                WIDLE: begin
                    if (mem_ift.Mw.wen) begin
                        axi_awaddr <= mem_ift.Mw.waddr;
                        axi_wdata  <= mem_ift.Mw.wdata;
                        axi_wstrb  <= mem_ift.Mw.wmask;
                        wstate     <= WSETDATA;
                    end
                end
                WSETDATA: begin
                    axi_awvalid <= 1'b1;
                    axi_wvalid  <= 1'b1;
                    wstate      <= WWAITDATA;
                end
                WWAITDATA: begin
                    if (master_ift.Sw.wready) axi_wvalid <= 1'b0;
                    if (master_ift.Sw.awready) axi_awvalid <= 1'b0;
                    if ((master_ift.Sw.wready | ~axi_wvalid) & (master_ift.Sw.awready | ~axi_awvalid)) begin
                        wstate     <= WWAITBRESP;
                        axi_bready <= 1'b1;
                    end
                end
                WWAITBRESP: begin
                    if (master_ift.Sw.bvalid) begin
                        axi_bready <= 1'b0;
                        axi_bresp  <= master_ift.Sw.bresp;
                        wstate     <= WIDLE;
                    end
                end
            endcase
        end
    end

    localparam RIDLE = 3'b000;
    localparam RSETADDR = 3'b001;
    localparam RWAITADDR = 3'b010;
    localparam RWAITDATA = 3'b011;
    localparam RLOADDATA = 3'b100;

    reg [2:0] rstate;

    always @(posedge master_ift.clk) begin
        if (~master_ift.rstn) begin
            rstate      <= RIDLE;
            axi_arvalid <= 1'b0;
            axi_rready  <= 1'b0;
            axi_araddr  <= {C_M_AXI_ADDR_WIDTH{1'b0}};
            axi_rdata   <= {C_M_AXI_DATA_WIDTH{1'b0}};
            axi_bresp   <= 2'b0;
            axi_resp    <= 2'b0;
        end else begin
            case (rstate)
                RIDLE: begin
                    if (mem_ift.Mr.ren) begin
                        axi_araddr <= mem_ift.Mr.raddr;
                        rstate     <= RSETADDR;
                    end
                end
                RSETADDR: begin
                    rstate      <= RWAITADDR;
                    axi_arvalid <= 1'b1;
                end
                RWAITADDR: begin
                    if (master_ift.Sr.arready) begin
                        axi_arvalid <= 1'b0;
                        rstate      <= RWAITDATA;
                        axi_rready  <= 1'b1;
                    end
                end
                RWAITDATA: begin
                    if (master_ift.Sr.rvalid) begin
                        axi_rready <= 1'b0;
                        axi_rdata  <= master_ift.Sr.rdata;
                        axi_resp   <= master_ift.Sr.rresp;
                        rstate     <= RLOADDATA;
                    end
                end
                default: begin
                    rstate <= RIDLE;
                end
            endcase
        end
    end

    assign mem_ift.Sw.wvalid = master_ift.Sw.bvalid & (wstate == WWAITBRESP);
    assign mem_ift.Sr.rvalid = rstate == RLOADDATA;
    assign mem_ift.Sr.rdata  = axi_rdata;

    always @(posedge master_ift.clk) begin
        if (~master_ift.rstn) begin
            rresp_mem <= 2'b0;
            wresp_mem <= 2'b0;
        end else begin
            if (mem_ift.Sw.wvalid) wresp_mem <= axi_bresp;
            if (mem_ift.Sr.rvalid) rresp_mem <= axi_resp;
        end
    end

endmodule
