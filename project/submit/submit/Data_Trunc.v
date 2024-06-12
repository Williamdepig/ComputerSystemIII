`timescale 1ns/1ps

module Data_Trunc(
    input [63:0] rw_rdata,
    input [63:0] res,
    input [2:0] memdata_width,

    output reg [63:0] dmem
);
    parameter DW = 3'b001,
               W = 3'b010,
              HW = 3'b011,
               B = 3'b100,
              UW = 3'b101,
             UHW = 3'b110,
              UB = 3'b111;
    always @(*)begin
        case(memdata_width)
            DW: dmem = rw_rdata;
             W: begin
                dmem[31:0] = rw_rdata[res[2:0]*8 +:32];
                dmem[63:32] = {32{dmem[31]}};
             end
            HW: begin
                dmem[15:0] = rw_rdata[res[2:0]*8 +:16];
                dmem[63:16] = {48{dmem[15]}};
             end
             B: begin
                dmem[7:0] = rw_rdata[res[2:0]*8 +:8];
                dmem[63:8] = {56{dmem[7]}};
             end
            UW: begin
                dmem[31:0] = rw_rdata[res[2:0]*8 +:32];
                dmem[63:32] = 0;
             end
           UHW: begin
                dmem[15:0] = rw_rdata[res[2:0]*8 +:16];
                dmem[63:16] = 0;
             end
            UB: begin
                dmem[7:0] = rw_rdata[res[2:0]*8 +:8];
                dmem[63:8] = 0;
             end
       default: dmem = 0;
        endcase
    end
endmodule