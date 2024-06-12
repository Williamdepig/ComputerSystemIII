`include "Define.vh"
`include "ExceptStruct.vh"
module OldInstExamine (
    input [63:0] PC_i,
    input [1:0] priv_i,
    input [31:0] inst_i,
    input valid_i,
    output ExceptStruct::ExceptPack except_o
);

    wire is_ecall=inst_i==`ECALL;
    wire is_ebreak=inst_i==`EBREAK;
    wire is_illegal=(inst_i[1:0]!=2'b11)&valid_i;

    wire [63:0] ecall_code [3:0];
    assign ecall_code[0]=`U_CALL;
    assign ecall_code[1]=`S_CALL;
    assign ecall_code[2]=`H_CALL;
    assign ecall_code[3]=`M_CALL;

    assign except_o.except=is_ebreak|is_ecall|is_illegal;
    assign except_o.epc=PC_i;
    assign except_o.ecause=is_ebreak?`BREAKPOINT:
                           is_ecall?ecall_code[priv_i]:
                           is_illegal?`ILLEAGAL_INST:
                           64'h0;
    assign except_o.etval=is_illegal?{32'b0,inst_i}:64'h0;
    
endmodule