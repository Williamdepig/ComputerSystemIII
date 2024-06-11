`include "PageStruct.vh"

module PTEDecode(
    input [63:0] pte,
    output PageStruct::PTEPack pte_pack
)

    assign pte_pack.v = pte[0];
    assign pte_pack.r = pte[1];
    assign pte_pack.w = pte[2];
    assign pte_pack.x = pte[3];
    assign pte_pack.u = pte[4];
    assign pte_pack.g = pte[5];
    assign pte_pack.a = pte[6];
    assign pte_pack.d = pte[7];
    assign pte_pack.rsw = pte[9:8];
    assign pte_pack.ppn = pte[53:10] << 12;

endmodule