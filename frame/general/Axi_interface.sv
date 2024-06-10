interface AXI_ift #(
    parameter integer AXI_ADDR_WIDTH,
    parameter integer AXI_DATA_WIDTH
) (
    input clk,
    input rstn
);

    localparam integer AXI_BYTE_WIDTH = AXI_DATA_WIDTH / 8;
    typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
    typedef logic [AXI_DATA_WIDTH-1:0] data_t;
    typedef logic valid_t;
    typedef logic ready_t;
    typedef logic [1:0] resp_t;
    typedef logic [AXI_BYTE_WIDTH-1:0] wstrb_t;
    typedef logic [2:0] port_t;

    typedef struct {
        addr_t  awaddr;
        port_t  awport;
        valid_t awvalid;
        data_t  wdata;
        valid_t wvalid;
        wstrb_t wstrb;
        ready_t bready;
    } axi_from_M_w;

    typedef struct {
        addr_t  araddr;
        port_t  arport;
        valid_t arvalid;
        ready_t rready;
    } axi_from_M_r;

    typedef struct {
        ready_t awready;
        ready_t wready;
        resp_t  bresp;
        valid_t bvalid;
    } axi_from_S_w;

    typedef struct {
        ready_t arready;
        data_t  rdata;
        resp_t  rresp;
        valid_t rvalid;
    } axi_from_S_r;

    axi_from_M_r Mr;
    axi_from_M_w Mw;
    axi_from_S_r Sr;
    axi_from_S_w Sw;

    modport Master(input clk, input rstn, output Mr, output Mw, input Sr, input Sw);

    modport Slave(input clk, input rstn, input Mr, input Mw, output Sr, output Sw);

endinterface
