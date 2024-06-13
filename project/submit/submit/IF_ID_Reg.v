`timescale 1ns/1ps
`include "Define.vh"
module IF_ID_Reg(
    input clk,
    input flush,
    input stall,
    input rst,
    input valid_if,
    input except_happen_if,
    output reg valid_id,
//以下三个数据将在每个阶段寄存器组间继承
    input [63:0]predict_pc_if,
    input [63:0]pc_if,
    input [63:0]npc_if,
    input [31:0]inst_if,
    output reg [63:0]predict_pc_id,
    output reg [63:0]pc_id,   
    output reg [63:0]npc_id,
    output reg [31:0]inst_id,

    output reg [4:0]rd_addr_id,
    output reg [4:0]rs1_addr_id,
    output reg [4:0]rs2_addr_id,

    output reg [11:0]csr_addr_id

);

    always @(posedge clk) begin
        if (rst) begin  //重置
            predict_pc_id <= 0;
            pc_id <= 0;
            npc_id <= 0;
            inst_id <= 0;
            valid_id <= 0;

            rd_addr_id <= 0;
            rs1_addr_id <= 0;
            rs2_addr_id <= 0;
            csr_addr_id <= 0;     
        end
        else if(~stall)begin      //传递所需信号和数据
            if (flush) begin
                predict_pc_id <= 0;
                pc_id <= 0;
                npc_id <= 0;
                inst_id <= 0;
                valid_id <= 0;

                rd_addr_id <= 0;
                rs1_addr_id <= 0;
                rs2_addr_id <= 0;
                csr_addr_id <= 0; 
            end
            else if (except_happen_if)begin
                predict_pc_id <= predict_pc_if;
                pc_id <= pc_if;
                npc_id <= 0;
                inst_id <= inst_if;
                valid_id <= (inst_if==`ECALL||inst_if==`EBREAK);//发生了一个很tricky的问题，ecall抛异常要valid，但其他指令抛异常不能valid，呃呃

                rd_addr_id <= 0;
                rs1_addr_id <= 0;
                rs2_addr_id <= 0;
                csr_addr_id <= 0;
            end
            else begin
                predict_pc_id <= predict_pc_if;
                pc_id <= pc_if;
                npc_id <= npc_if;
                inst_id <= inst_if;
                valid_id <= valid_if;

                rd_addr_id <= inst_if[11:7];
                rs1_addr_id <= inst_if[19:15];
                rs2_addr_id <= inst_if[24:20];
                csr_addr_id <= inst_if[31:20];     
            end
        end
        else begin
            predict_pc_id <= predict_pc_id;
            pc_id <= pc_id;
            npc_id <= npc_id;
            inst_id <= inst_id;
            valid_id <= valid_id;

            rd_addr_id <= rd_addr_id;
            rs1_addr_id <= rs1_addr_id;
            rs2_addr_id <= rs2_addr_id;
            csr_addr_id <= csr_addr_id;  
        end
    end

endmodule
