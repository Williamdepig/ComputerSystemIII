`timescale 1ns/1ps

module ALU_MUX(
    input [63:0] reg1,
    input [63:0] pc,
    input [63:0] reg2,
    input [63:0] csr,
    input [63:0] imm,
    input [1:0]asel , [1:0]bsel,

    output reg [63:0] a,
    output reg [63:0] b
);
    always @(*) begin
        case(asel)
            2'b00: a = 0;
            2'b01: a = reg1;
            2'b10: a = pc;
            2'b11: a = csr;
            default: a = 0;
        endcase
    end
    always @(*) begin
        case(bsel)
            2'b00: b = 0;
            2'b01: b = reg2;
            2'b10: b = imm;   
            default: b = 0;
        endcase
    end
endmodule