interface Mem_ift #(
    parameter longint ADDR_WIDTH = 64,
    parameter longint DATA_WIDTH = 64
);
    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [DATA_WIDTH/8-1:0] mask_t;
    typedef logic ctrl_t;

    typedef struct {
        addr_t waddr;
        ctrl_t wen;
        data_t wdata;
        mask_t wmask;
    } Mw_struct;

    typedef struct {ctrl_t wvalid;} Sw_struct;

    typedef struct {
        addr_t raddr;
        ctrl_t ren;
    } Mr_struct;

    typedef struct {
        ctrl_t rvalid;
        data_t rdata;
    } Sr_struct;

    Mw_struct Mw;
    Mr_struct Mr;
    Sw_struct Sw;
    Sr_struct Sr;

    modport Master(output Mw, input Sw, output Mr, input Sr);

    modport Slave(input Mw, output Sw, input Mr, output Sr);

endinterface
