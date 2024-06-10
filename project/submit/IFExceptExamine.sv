`include "ExceptStruct.vh"
module IFExceptExamine(
    input clk,
    input rst,
    input stall,
    input flush,

    input [63:0] pc_if,
    input [1:0] priv,
    input [31:0] inst_if,
    input valid_if,
    
    output ExceptStruct::ExceptPack except_id,
    output except_happen_if
);
    
    import ExceptStruct::ExceptPack;
    ExceptPack except;

    OldInstExamine instexmaine(
        .PC_i(pc_if),
        .priv_i(priv),
        .inst_i(inst_if),
        .valid_i(valid_if),
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
