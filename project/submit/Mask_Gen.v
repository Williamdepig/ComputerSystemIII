`timescale 1ns/1ps

module Mask_Gen(
    input [63:0] res,
    input [2:0] memdata_width,

    output reg [7:0]rw_wmask
); 
    reg [7:0]rw_wmask1;
    parameter DW = 3'b001,
               W = 3'b010,
              HW = 3'b011,
               B = 3'b100,
              UW = 3'b101,
             UHW = 3'b110,
              UB = 3'b111;
    always @(*)begin
        case(memdata_width)
            DW: rw_wmask1 = 8'hff;
             W: rw_wmask1 = 8'h0f;
            HW: rw_wmask1 = 8'h03;
             B: rw_wmask1 = 8'h01;
            UW: rw_wmask1 = 8'h0f;
           UHW: rw_wmask1 = 8'h03;
            UB: rw_wmask1 = 8'h01;
            default: rw_wmask1 = 0; 
        endcase
        rw_wmask = rw_wmask1 << res[2:0];
    end
endmodule