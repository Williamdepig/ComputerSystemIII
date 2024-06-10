`include "ExceptStruct.vh"

module IDExceptExamine (
    input clk,
    input rst,
    input stall,
    input flush,

    input [63:0] pc_id,
    input [ 1:0] priv,
    input        is_ecall_id,
    input        is_ebreak_id,
    input        illegal_id,
    input [31:0] inst_id,
    input        valid_id,

    input  ExceptStruct::ExceptPack except_id,
    output ExceptStruct::ExceptPack except_exe,
    output                          except_happen_id
);

    import ExceptStruct::ExceptPack;
    ExceptPack except_new;
    ExceptPack except;

    InstExamine instexmaine (
        .PC_i          (pc_id),
        .priv_i        (priv),
        .is_ecall_id_i (is_ecall_id),
        .is_ebreak_id_i(is_ebreak_id),
        .illegal_id_i  (illegal_id),
        .inst_i        (inst_id),
        .valid_i       (valid_id),
        .except_o      (except_new)
    );

    assign except           = except_id.except ? except_id : except_new;
    assign except_happen_id = except_new.except & ~except_id.except;

    ExceptReg exceptreg (
        .clk     (clk),
        .rst     (rst),
        .stall   (stall),
        .flush   (flush),
        .except_i(except),
        .except_o(except_exe)
    );

endmodule
