`timescale 1ns/1ps

module Branch(
    input [2:0] bralu_op,
    input [63:0] reg1,
    input [63:0] reg2,
    
    output reg [3:0]br_taken
);
    parameter EQ = 3'b001,
              NE = 3'b010,
              LT = 3'b011,
              GE = 3'b100,
              LTU = 3'b101,
              GEU = 3'b110;
    always @(*) begin
        br_taken[2:0] = bralu_op[2:0];
        case(bralu_op)
            EQ: br_taken[3] = (reg1 == reg2);
            NE: br_taken[3] = (reg1 != reg2);
            LT: br_taken[3] = ($signed(reg1) < $signed(reg2));
            GE: br_taken[3] = ($signed(reg1) >= $signed(reg2));
            LTU:br_taken[3] = (reg1 < reg2);
            GEU:br_taken[3] = (reg1 >= reg2);
            default: br_taken[3] = 0;
        endcase
    end
endmodule