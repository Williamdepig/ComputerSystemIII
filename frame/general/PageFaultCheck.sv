`include "PageStruct.vh"

module PageFaultCheck(
    input if_request,
    input wen,
    input ren,
    input [1:0]priv,
    input PageStruct::PTEPack pte_pack,
    input translator_enable,
    output reg page_fault
);

always @(*)begin
    page_fault = 0;
    if(~translator_enable)begin
        page_fault = 0;
    end
    else if(~pte_pack.v | (~pte_pack.r & pte_pack.w))begin
        page_fault = 1;
    end
    else if(pte_pack.r | pte_pack.x)begin
        page_fault = (if_request & ~pte_pack.x) | (wen & ~pte_pack.w) | (ren & ~pte_pack.r) | ~(priv[0]^pte_pack.u);
    end
    else begin
        page_fault = 0;
    end
end


endmodule