`timescale 1ns/1ps

module MEM_WB_Reg(
    input clk,
    input flush,
    input stall,
    input rst,
    input valid_mem,
    input except_happen_mem,
    output reg valid_wb,
//以下三个数据将在每个阶段寄存器组间继承
    input [63:0]pc_mem,
    input [63:0]npc_mem,
    input [31:0]inst_mem,
    output reg [63:0]pc_wb,   
    output reg [63:0]npc_wb,
    output reg [31:0]inst_wb,
//以下是之后使用到的控制信号
    input we_reg_mem,
    input we_mem_mem,
    input we_csr_mem,
    input [1:0]wb_sel_mem,
    input [1:0]csr_ret_mem,
    input [3:0]br_taken_mem,
    output reg we_reg_wb,
    output reg we_mem_wb,
    output reg we_csr_wb,
    output reg [1:0]wb_sel_wb,
    output reg [1:0]csr_ret_wb,
    output reg [3:0]br_taken_wb,
//以下是之后使用到的数据
    input [4:0]rd_mem,
    input [11:0]csr_addr_mem,
    input [63:0]csr_val_mem,
    input [63:0]alu_res_mem,
    input [63:0]dmem_mem,
    input [63:0]rs1_data_mem,
    input [63:0]rs2_data_mem,
    input [63:0]rw_wdata,
    output reg [4:0]rd_wb,
    output reg [11:0]csr_addr_wb,
    output reg [63:0]csr_val_wb,
    output reg [63:0]alu_res_wb,
    output reg [63:0]dmem_wb,
    output reg [63:0]rs1_data_wb,
    output reg [63:0]rs2_data_wb,
    output reg [63:0]mem_wdata_wb
);

    always @(posedge clk) begin
        if (rst) begin  //重置
            pc_wb <= 0;
            npc_wb <= 0;
            inst_wb <= 0;
            valid_wb <= 0;
            
            we_reg_wb <= 0;
            we_mem_wb <= 0;
            we_csr_wb <= 0;
            csr_ret_wb <= 0;
            wb_sel_wb <= 0;
            br_taken_wb <= 0;

            rd_wb <= 0;
            csr_addr_wb <= 0;
            csr_val_wb <= 0;
            alu_res_wb <= 0;
            dmem_wb <= 0; 
            rs1_data_wb <= 0;
            rs2_data_wb <= 0;
            mem_wdata_wb <= 0;
        end
        else if(~stall)begin      //传递所需信号和数据
            if (flush) begin
                pc_wb <= 0;
                npc_wb <= 0;
                inst_wb <= 0;
                valid_wb <= 0;
                
                we_reg_wb <= 0;
                we_mem_wb <= 0;
                we_csr_wb <= 0;
                csr_ret_wb <= 0;
                wb_sel_wb <= 0;
                br_taken_wb <= 0;

                rd_wb <= 0;
                csr_addr_wb <= 0;
                csr_val_wb <= 0;
                alu_res_wb <= 0;
                dmem_wb <= 0; 
                rs1_data_wb <= 0;
                rs2_data_wb <= 0;
                mem_wdata_wb <= 0;
            end
            else if(except_happen_mem)begin
                pc_wb <= pc_mem;
                npc_wb <= 0;
                inst_wb <= inst_mem;
                valid_wb <= valid_mem;
                
                we_reg_wb <= 0;
                we_mem_wb <= 0;
                we_csr_wb <= 0;
                csr_ret_wb <= 0;
                wb_sel_wb <= 0;
                br_taken_wb <= 0;

                rd_wb <= 0;
                csr_addr_wb <= 0;
                csr_val_wb <= 0;
                alu_res_wb <= 0;
                dmem_wb <= 0; 
                rs1_data_wb <= 0;
                rs2_data_wb <= 0;
                mem_wdata_wb <= 0;
            end
            else begin
                pc_wb <= pc_mem;
                npc_wb <= npc_mem;
                inst_wb <= inst_mem;
                valid_wb <= valid_mem;
                
                we_reg_wb <= we_reg_mem;
                we_mem_wb <= we_mem_mem;
                we_csr_wb <= we_csr_mem;
                csr_ret_wb <= csr_ret_mem;
                wb_sel_wb <= wb_sel_mem;
                br_taken_wb <= br_taken_mem;
                
                rd_wb <= rd_mem;
                csr_addr_wb <= csr_addr_mem;
                csr_val_wb <= csr_val_mem;
                alu_res_wb <= alu_res_mem;
                dmem_wb <= dmem_mem;
                rs1_data_wb <= rs1_data_mem;
                rs2_data_wb <= rs2_data_mem;
                mem_wdata_wb <= rw_wdata;
            end
        end
        else begin
            pc_wb <= pc_wb;
            npc_wb <= npc_wb;
            inst_wb <= inst_wb;
            valid_wb <= valid_wb;
            
            we_reg_wb <= we_reg_wb;
            we_mem_wb <= we_mem_wb;
            we_csr_wb <= we_csr_wb;
            csr_ret_wb <= csr_ret_wb;
            wb_sel_wb <= wb_sel_wb;
            br_taken_wb <= br_taken_wb;

            rd_wb <= rd_wb;
            csr_addr_wb <= csr_addr_wb;
            csr_val_wb <= csr_val_wb;
            alu_res_wb <= alu_res_wb;
            dmem_wb <= dmem_wb; 
            rs1_data_wb <= rs1_data_wb;
            rs2_data_wb <= rs2_data_wb;      
            mem_wdata_wb <= mem_wdata_wb;   
        end
    end

endmodule
