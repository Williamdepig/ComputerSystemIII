`timescale 1ns/1ps

module Imm_Gen(
    input [2:0] immgen_op,
    input [31:0] inst,
    
    output reg[63:0] imm 
);
    parameter zero = 3'b000,
              I_type = 3'b001,
              S_type = 3'b010,
              B_type = 3'b011,
              U_type = 3'b100,
              J_type = 3'b101,
              CSR_type = 3'b110;
always @(*) begin
    case(immgen_op)
        zero:   imm = 0;
        I_type: imm = {{52{inst[31]}},inst[31:20]};
        S_type: imm = {{52{inst[31]}},inst[31:25],inst[11:7]};
        B_type: imm = {{51{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
        U_type: imm = {{32{inst[31]}},inst[31:12],12'b0};
        J_type: imm = {{43{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
        CSR_type: imm = {59'b0,inst[19:15]};
        default:imm = 0;
    endcase
end
endmodule