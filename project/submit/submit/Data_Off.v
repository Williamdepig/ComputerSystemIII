module Data_Off(
    input [63:0]res,
    input [63:0]rw_wdata0,

    output [63:0]rw_wdata
);
    assign rw_wdata = rw_wdata0 << (8*res[2:0]);
endmodule