`include "Define.vh"
`include "ExceptStruct.vh"

module PrivExamine (
    input [63:0] PC_i,
    input [ 1:0] priv_i,
    input [31:0] mcounteren_i,
    input [ 1:0] csr_ret_i,
    input [ 1:0] csr_priv_i,
    input [11:0] csr_index_i,
    input [31:0] inst_i,

    output ExceptStruct::ExceptPack except_o
);

    wire csr_we_priv = priv_i < csr_priv_i;
    wire ret_priv = (csr_ret_i[1] & (priv_i < 2'b11)) | (csr_ret_i[0] & (priv_i < 2'b01));
    wire mcounteren_priv = (csr_index_i[11:5] == 7'b1100000) & ~(mcounteren_i[csr_index_i[4:0]]);
    assign except_o.except = csr_we_priv | ret_priv | mcounteren_priv;
    assign except_o.epc    = PC_i;
    assign except_o.ecause = `ILLEAGAL_INST;
    assign except_o.etval  = {32'b0, inst_i};

endmodule
