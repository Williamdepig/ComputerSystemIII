`include "Define.vh"
`include "ExceptStruct.vh"
module PageFaultExamine (
    input [63:0] PC_i,
    input [1:0] priv_i,
    input [31:0] inst_i,
    input page_fault,
    input if_request,
    input we,
    input re,
    input valid_i,
    output ExceptStruct::ExceptPack except_o
);

    wire is_page_fault = page_fault & valid_i;
    assign except_o.except = is_page_fault;
    assign except_o.epc = PC_i;
    assign except_o.ecause = ~is_page_fault ? 64'h0 :
                                 if_request ? `INST_PAGE_FAULT :
                                         we ? `STORE_PAGE_FAULT :
                                         re ? `LOAD_PAGE_FAULT :
                                         64'h0;
    assign except_o.etval = ~is_page_fault ? 64'h0 :
                            PC_i;

endmodule