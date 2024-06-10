`timescale 1ns / 1ps

// Copyright 2023 Sycuricon Group
// Author: Jinyan Xu (phantom@zju.edu.cn)
module RAM #(
    parameter longint MEM_DEPTH = 4096,
    parameter         FILE_PATH = "testcase.hex"
) (
    input clk,
    input rstn,

    Mem_ift.Slave mem_ift
);

    wire                         ren;
    wire                         wen;
    wire [$clog2(MEM_DEPTH)-4:0] r_addr;
    wire [$clog2(MEM_DEPTH)-4:0] w_addr;
    wire [                 63:0] rw_wdata;
    wire [                  7:0] rw_wmask;
    reg  [                127:0] rw_rdata;
    wire                         wvalid;
    wire                         rvalid;

    reg                          wstate;
    always @(posedge clk) begin
        if (~rstn) wstate <= 1'b0;
        else begin
            case (wstate)
                1'b0: if (wen) wstate <= 1'b1;
                1'b1: wstate <= 1'b0;
            endcase
        end
    end
    assign wen               = mem_ift.Mw.wen;
    assign w_addr            = {mem_ift.Mw.waddr[$clog2(MEM_DEPTH)-1:4], wstate};
    assign rw_wdata          = wstate ? mem_ift.Mw.wdata[127:64] : mem_ift.Mw.wdata[63:0];
    assign rw_wmask          = wstate ? mem_ift.Mw.wmask[15:8] : mem_ift.Mw.wmask[7:0];
    assign mem_ift.Sw.wvalid = wstate;

    reg [1:0] rstate;
    always @(posedge clk) begin
        if (~rstn) rstate <= 2'b0;
        else begin
            case (rstate)
                2'b00:   if (ren) rstate <= 2'b01;
                2'b01:   rstate <= 2'b10;
                2'b10:   if (~ren) rstate <= 2'b00;
                default: rstate <= 2'b00;
            endcase
        end
    end
    assign ren               = mem_ift.Mr.ren;
    assign r_addr            = {mem_ift.Mr.raddr[$clog2(MEM_DEPTH)-1:4], rstate[0]};
    assign mem_ift.Sr.rdata  = rw_rdata;
    assign mem_ift.Sr.rvalid = rstate == 2'b10;

    integer        i;
    (* ram_style = "block" *)reg     [63:0] mem[0:(MEM_DEPTH/8-1)];

    initial begin
        $display("%s:%d", FILE_PATH, MEM_DEPTH);
        $readmemh(FILE_PATH, mem);
    end

    always @(posedge clk) begin
        if (rstn) begin
            if (wen) begin
                for (i = 0; i < 8; i = i + 1) begin
                    if (rw_wmask[i]) begin
                        mem[w_addr][i*8+:8] <= rw_wdata[i*8+:8];
                    end
                end
            end
        end
    end

    always @(posedge clk) begin
        if (rstn) begin
            if (ren & rstate == 2'b00 | rstate == 2'b01) begin
                rw_rdata[127:64] <= mem[r_addr];
                rw_rdata[63:0]   <= rw_rdata[127:64];
            end
        end
    end

endmodule
