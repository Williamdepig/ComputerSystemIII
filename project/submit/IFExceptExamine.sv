`include "ExceptStruct.vh"
module IFExceptExamine(
    input clk,
    input rst,
    input stall,
    input flush,
    input page_fault,

    input [63:0] pc_if,
    input [1:0] priv,
    input [31:0] inst_if,
    input valid_if,
    input if_request,
    
    output ExceptStruct::ExceptPack except_id,
    output except_happen_if
);
    
    import ExceptStruct::ExceptPack;
    ExceptPack except;

    PageFaultExamine if_page_fault_exmaine(
        .PC_i(pc_if),
        .priv_i(priv),
        .inst_i(inst_if),
        .valid_i(valid_if),
        .page_fault(page_fault),
        .if_request(if_request),
        .we(1'b0),
        .re(1'b0),

        .except_o(except)
    );

    assign except_happen_if=except.except;

    ExceptReg exceptreg_if_id(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .flush(flush),
        .except_i(except),
        .except_o(except_id)
    );

endmodule 
