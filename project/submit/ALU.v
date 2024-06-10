`timescale 1ns/1ps

module ALU (
  input  [63:0] a,
  input  [63:0] b,
  input  [3:0]  alu_op,
  output reg [63:0] res
);

  parameter ADD = 4'b0000,
            SUB = 4'b0001,
            AND = 4'b0010,
            OR  = 4'b0011,
            XOR = 4'b0100,
            SLT = 4'b0101,
            SLTU= 4'b0110,
            SLL = 4'b0111,
            SRL = 4'b1000,
            SRA = 4'b1001,
            ADDW= 4'b1010,
            SUBW= 4'b1011,
            SLLW= 4'b1100,
            SRLW= 4'b1101,
            SRAW= 4'b1110;
  always @(*)begin
      case (alu_op)
          ADD:  res = a + b;
          SUB:  res = a - b;
          AND:  res = a & b;
          OR :  res = a | b;
          XOR:  res = a ^ b;
          SLT:  res = {63'b0, ($signed(a) < $signed(b))};
          SLTU: res = {63'b0, (a < b)};
          SLL:  res = (a << b[5:0]);
          SRL:  res = (a >> b[5:0]);
          SRA:  res = ($signed(a) >>> b[5:0]);
          ADDW: begin
            res[31:0] = a[31:0] + b[31:0];
            res[63:32] = {32{res[31]}};
          end
          SUBW:begin
            res[31:0] = a[31:0] - b[31:0];
            res[63:32] = {32{res[31]}};
          end
          SLLW: begin
            res[31:0] = (a[31:0] << b[4:0]);
            res[63:32] = {32{res[31]}};
          end
          SRLW:begin
            res[31:0] = (a[31:0] >> b[4:0]);
            res[63:32] = {32{res[31]}};
          end
          SRAW:begin
            res[31:0] = ($signed(a[31:0]) >>> b[4:0]);
            res[63:32] = {32{res[31]}};
          end
          default: res = 0;
      endcase
  end
endmodule