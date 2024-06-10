module Axi_lite_Mem_Hub #(
    parameter integer AXI_ADDR_WIDTH = 64,
    parameter integer AXI_DATA_WIDTH = 64,
    parameter longint MEM0_BEGIN     = 0,
    parameter longint MEM0_END       = 64'h1000,
    parameter longint MEM1_BEGIN     = 64'h10000,
    parameter longint MEM1_END       = 64'h14000,
    parameter longint MEM2_BEGIN     = 64'h80000000,
    parameter longint MEM2_END       = 64'h88000000
) (
    input clk,
    input rstn,

    AXI_ift.Slave  master0,
    AXI_ift.Slave  master1,
    AXI_ift.Master slave0,
    AXI_ift.Master slave1,
    AXI_ift.Master slave2
);

    AXI_ift #(
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
    ) dummy_axi (
        .clk (clk),
        .rstn(rstn)
    );

    assign dummy_axi.Mw = '{awaddr: 0, awport: 0, awvalid: 0, wdata: 0, wvalid: 0, wstrb: 0, bready: 0};

    assign dummy_axi.Mr = '{araddr: 0, arport: 0, arvalid: 0, rready: 0};

    assign dummy_axi.Sw = '{awready: 0, wready: 0, bresp: 0, bvalid: 0};

    assign dummy_axi.Sr = '{arready: 0, rdata: 0, rresp: 0, rvalid: 0};

    localparam IDLE = 2'b00;
    localparam MASTER0 = 2'b01;
    localparam MASTER1 = 2'b10;

    wire [AXI_ADDR_WIDTH-1:0] waddr[1:0];
    assign waddr[0] = master0.Mw.awaddr;
    assign waddr[1] = master1.Mw.awaddr;
    wire [1:0] wrequest;
    assign wrequest[0] = master0.Mw.awvalid;
    assign wrequest[1] = master1.Mw.awvalid;
    wire [2:0] wismem[1:0];
    genvar i;
    generate
        for (i = 0; i <= 1; i = i + 1) begin : wismem_set
            assign wismem[i][0] = (waddr[i] < MEM0_END) & wrequest[i];
            assign wismem[i][1] = (MEM1_BEGIN <= waddr[i]) & (waddr[i] < MEM1_END) & wrequest[i];
            assign wismem[i][2] = (MEM2_BEGIN <= waddr[i]) & (waddr[i] < MEM2_END) & wrequest[i];
        end
    endgenerate

    reg  [1:0] axi_wtask[2:0];
    wire [2:0] wfinish;
    assign wfinish[0] = slave0.Sw.bvalid;
    assign wfinish[1] = slave1.Sw.bvalid;
    assign wfinish[2] = slave2.Sw.bvalid;
    wire [2:0] wismaster0;
    wire [2:0] wismaster1;
    generate
        for (i = 0; i < 3; i = i + 1) begin
            always @(posedge clk) begin
                if (~rstn) begin
                    axi_wtask[i] <= IDLE;
                end else begin
                    case (axi_wtask[i])
                        IDLE: begin
                            if (wismem[1][i]) axi_wtask[i] <= MASTER1;
                            else if (wismem[0][i]) axi_wtask[i] <= MASTER0;
                        end
                        MASTER0: begin
                            if (wfinish[i] & wismem[1][i]) axi_wtask[i] <= MASTER1;
                            else if (wfinish[i]) axi_wtask[i] <= IDLE;
                        end
                        MASTER1: begin
                            if (wfinish[i] & wismem[0][i]) axi_wtask[i] <= MASTER0;
                            else if (wfinish[i]) axi_wtask[i] <= IDLE;
                        end
                        default: begin
                            axi_wtask[i] <= IDLE;
                        end
                    endcase
                end
            end
            assign wismaster0[i] = axi_wtask[i] == MASTER0;
            assign wismaster1[i] = axi_wtask[i] == MASTER1;
        end
    endgenerate

    always_comb begin
        case (axi_wtask[0])
            MASTER0: slave0.Mw = master0.Mw;
            MASTER1: slave0.Mw = master1.Mw;
            default: slave0.Mw = dummy_axi.Mw;
        endcase
    end

    always_comb begin
        case (axi_wtask[1])
            MASTER0: slave1.Mw = master0.Mw;
            MASTER1: slave1.Mw = master1.Mw;
            default: slave1.Mw = dummy_axi.Mw;
        endcase
    end

    always_comb begin
        case (axi_wtask[2])
            MASTER0: slave2.Mw = master0.Mw;
            MASTER1: slave2.Mw = master1.Mw;
            default: slave2.Mw = dummy_axi.Mw;
        endcase
    end

    always_comb begin
        case (wismaster0)
            3'b001:  master0.Sw = slave0.Sw;
            3'b010:  master0.Sw = slave1.Sw;
            3'b100:  master0.Sw = slave2.Sw;
            default: master0.Sw = dummy_axi.Sw;
        endcase
    end

    always_comb begin
        case (wismaster1)
            3'b001:  master1.Sw = slave0.Sw;
            3'b010:  master1.Sw = slave1.Sw;
            3'b100:  master1.Sw = slave2.Sw;
            default: master1.Sw = dummy_axi.Sw;
        endcase
    end

    //------------------------------------------------

    wire [AXI_ADDR_WIDTH-1:0] raddr[1:0];
    assign raddr[0] = master0.Mr.araddr;
    assign raddr[1] = master1.Mr.araddr;
    wire [1:0] rrequest;
    assign rrequest[0] = master0.Mr.arvalid;
    assign rrequest[1] = master1.Mr.arvalid;
    wire [2:0] rismem[1:0];
    generate
        for (i = 0; i <= 1; i = i + 1) begin : rismem_set
            assign rismem[i][0] = (raddr[i] < MEM0_END) & rrequest[i];
            assign rismem[i][1] = (MEM1_BEGIN <= raddr[i]) & (raddr[i] < MEM1_END) & rrequest[i];
            assign rismem[i][2] = (MEM2_BEGIN <= raddr[i]) & (raddr[i] < MEM2_END) & rrequest[i];
        end
    endgenerate

    reg  [1:0] axi_rtask[2:0];
    wire [2:0] rfinish;
    assign rfinish[0] = slave0.Sr.rvalid;
    assign rfinish[1] = slave1.Sr.rvalid;
    assign rfinish[2] = slave2.Sr.rvalid;
    wire [2:0] rismaster0;
    wire [2:0] rismaster1;
    generate
        for (i = 0; i < 3; i = i + 1) begin
            always @(posedge clk) begin
                if (~rstn) begin
                    axi_rtask[i] <= IDLE;
                end else begin
                    case (axi_rtask[i])
                        IDLE: begin
                            if (rismem[1][i]) axi_rtask[i] <= MASTER1;
                            else if (rismem[0][i]) axi_rtask[i] <= MASTER0;
                        end
                        MASTER0: begin
                            if (rfinish[i] & rismem[1][i]) axi_rtask[i] <= MASTER1;
                            else if (rfinish[i]) axi_rtask[i] <= IDLE;
                        end
                        MASTER1: begin
                            if (rfinish[i] & rismem[0][i]) axi_rtask[i] <= MASTER0;
                            else if (rfinish[i]) axi_rtask[i] <= IDLE;
                        end
                        default: begin
                            axi_rtask[i] <= IDLE;
                        end
                    endcase
                end
            end
            assign rismaster0[i] = axi_rtask[i] == MASTER0;
            assign rismaster1[i] = axi_rtask[i] == MASTER1;
        end
    endgenerate

    always_comb begin
        case (axi_rtask[0])
            MASTER0: slave0.Mr = master0.Mr;
            MASTER1: slave0.Mr = master1.Mr;
            default: slave0.Mr = dummy_axi.Mr;
        endcase
    end

    always_comb begin
        case (axi_rtask[1])
            MASTER0: slave1.Mr = master0.Mr;
            MASTER1: slave1.Mr = master1.Mr;
            default: slave1.Mr = dummy_axi.Mr;
        endcase
    end

    always_comb begin
        case (axi_rtask[2])
            MASTER0: slave2.Mr = master0.Mr;
            MASTER1: slave2.Mr = master1.Mr;
            default: slave2.Mr = dummy_axi.Mr;
        endcase
    end

    always_comb begin
        case (rismaster0)
            3'b001:  master0.Sr = slave0.Sr;
            3'b010:  master0.Sr = slave1.Sr;
            3'b100:  master0.Sr = slave2.Sr;
            default: master0.Sr = dummy_axi.Sr;
        endcase
    end

    always_comb begin
        case (rismaster1)
            3'b001:  master1.Sr = slave0.Sr;
            3'b010:  master1.Sr = slave1.Sr;
            3'b100:  master1.Sr = slave2.Sr;
            default: master1.Sr = dummy_axi.Sr;
        endcase
    end

endmodule
