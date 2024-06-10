`timescale 1ns / 1ps

module WB_MUX(
    input [1:0] wb_sel,
    input [63:0] npc,
    input [63:0] dmem,
    input [63:0] res,

    output reg [63:0] rf
);

always@(*) begin
    case(wb_sel) 
       2'b00: rf = 0;
       2'b01: rf = res;
       2'b10: rf = dmem;
       2'b11: rf = npc;
    endcase
end
endmodule