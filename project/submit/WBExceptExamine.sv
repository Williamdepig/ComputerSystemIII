`include "ExceptStruct.vh"
module WBExceptExamine(
    input [63:0] pc_wb,
    input [1:0] priv,
    input [31:0] inst_wb,
    input valid_wb,
    
    input ExceptStruct::ExceptPack except_wb,
    output ExceptStruct::ExceptPack except_commit
);
    
    import ExceptStruct::ExceptPack;
    ExceptPack except_new;
    OldInstExamine instexmaine(
        .PC_i(pc_wb),
        .priv_i(priv),
        .inst_i(inst_wb),
        .valid_i(valid_wb),
        .except_o(except_new)
    );

    assign except_commit=except_wb.except?except_wb:except_new;


endmodule 
