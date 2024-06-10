`timescale 1ns/1ps

module CSR_MUX(
    input [63:0] rs1,
    input [63:0] imm,
    input [63:0] csr_val,
    input [2:0] csr_sel,

    output reg [63:0] csr
);
    always @(*) begin
        case(csr_sel)
            3'b000: csr = 0;
            3'b001: csr = rs1;//csrrw
            3'b010: csr = csr_val|rs1;//csrrs
            3'b011: csr = csr_val&~rs1;//csrrc
            3'b100: csr = imm;//csrrwi
            3'b101: csr = csr_val|imm;//csrrsi
            3'b110: csr = csr_val&~imm;//csrrci
            default: csr = 0;
        endcase
    end
endmodule