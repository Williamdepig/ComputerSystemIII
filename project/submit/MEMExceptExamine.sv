`include "ExceptStruct.vh"
module MEMExceptExamine(
    input clk,
    input rst,
    input stall,
    input flush,

    input [63:0] pc_mem,
    input [1:0] priv,
    input [31:0] inst_mem,
    input valid_mem,
    
    input ExceptStruct::ExceptPack except_mem,
    output ExceptStruct::ExceptPack except_wb,
    output except_happen_mem
);
    
    import ExceptStruct::ExceptPack;
    ExceptPack except_new;
    ExceptPack except;

    OldInstExamine instexmaine(
        .PC_i(pc_mem),
        .priv_i(priv),
        .inst_i(inst_mem),
        .valid_i(valid_mem),
        .except_o(except_new)
    );

    assign except=except_mem.except?except_mem:except_new;
    assign except_happen_mem=except_new.except&~except_mem.except;

    ExceptReg exceptreg_mem_wb(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .flush(flush),
        .except_i(except),
        .except_o(except_wb)
    );

endmodule 
