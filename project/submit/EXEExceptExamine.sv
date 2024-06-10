`include "ExceptStruct.vh"
module EXEExceptExamine(
    input clk,
    input rst,
    input stall,
    input flush,

    input [63:0] pc_exe,
    input [1:0] priv,
    input [31:0] inst_exe,
    input valid_exe,
    
    input ExceptStruct::ExceptPack except_exe,
    output ExceptStruct::ExceptPack except_mem,
    output except_happen_exe
);
    
    import ExceptStruct::ExceptPack;
    ExceptPack except_new;
    ExceptPack except;

    OldInstExamine instexmaine(
        .PC_i(pc_exe),
        .priv_i(priv),
        .inst_i(inst_exe),
        .valid_i(valid_exe),
        .except_o(except_new)
    );

    assign except=except_exe.except?except_exe:except_new;
    assign except_happen_exe=except_new.except&~except_exe.except;

    ExceptReg exceptreg_exe_mem(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .flush(flush),
        .except_i(except),
        .except_o(except_mem)
    );

endmodule 
