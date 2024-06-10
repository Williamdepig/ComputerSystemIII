`include "Define.vh"

module CommitExceptExamine (
    input        valid,
    input [63:0] pc_wb,
    input [ 1:0] priv,
    input [31:0] mcounteren,
    input [ 1:0] csr_ret_wb,
    input [31:0] inst_wb,
    input        csr_we_wb,

    input  ExceptStruct::ExceptPack except_wb,
    output ExceptStruct::ExceptPack except_commit
);
    import ExceptStruct::ExceptPack;
    ExceptPack        except_new;
    ExceptPack        except;

    wire       [11:0] csr_index_wb = csr_we_wb ? inst_wb[31:20] : 12'b0;
    wire       [ 1:0] csr_priv_wb = csr_we_wb ? inst_wb[29:28] : 2'b00;

    PrivExamine privexamine (
        .PC_i        (pc_wb),
        .priv_i      (priv),
        .mcounteren_i(mcounteren),
        .csr_ret_i   (csr_ret_wb),
        .csr_priv_i  (csr_priv_wb),
        .csr_index_i (csr_index_wb),
        .inst_i      (inst_wb),
        .except_o    (except_new)
    );

    wire       is_vaild = valid | except_wb.except;
    ExceptPack tmp;
    assign tmp                  = except_wb.except ? except_wb : except_new;
    assign except_commit.except = tmp.except & is_vaild;
    assign except_commit.epc    = tmp.epc;
    assign except_commit.ecause = tmp.ecause;
    assign except_commit.etval  = tmp.etval;

endmodule
