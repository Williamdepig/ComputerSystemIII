module ForwardingUnit(
    input [4:0]rs1_addr_id,
    input [63:0]rs1_data_id,
    input [4:0]rs2_addr_id,
    input [63:0]rs2_data_id,
    input [4:0]rd_addr_exe,
    input [4:0]rd_addr_mem,
    input [4:0]rd_addr_wb,
    input [11:0]csr_addr_id,
    input [63:0]csr_val_id,
    input [11:0]csr_addr_exe,
    input [63:0]csr_val_exe,
    input [11:0]csr_addr_mem,
    input [63:0]csr_val_mem,
    input [11:0]csr_addr_wb,
    input [63:0]csr_val_wb,

    input [63:0]alu_res_exe,
    input [63:0]npc_exe,
    input [1:0]wb_sel_exe,
    input we_reg_exe,
    input we_csr_exe,

    input [63:0]alu_res_mem,
    input [63:0]npc_mem,
    input [1:0]wb_sel_mem,
    input we_reg_mem,
    input we_csr_mem,
    input [63:0]dmem_mem,

    input we_reg_wb,
    input we_csr_wb,
    input [63:0]rd_data,


    output reg [63:0]rs1_data_idexe,
    output reg [63:0]rs2_data_idexe,
    output reg [63:0]csr_val_idexe
);
always@(*) begin
    if (rs1_addr_id == rd_addr_exe && rs1_addr_id != 0 && we_reg_exe == 1) begin
        case(wb_sel_exe) 
            2'b00: rs1_data_idexe = 0;
            2'b01: rs1_data_idexe = alu_res_exe;
            2'b11: rs1_data_idexe = npc_exe;
            default: rs1_data_idexe = 0;
        endcase
    end
    else if (rs1_addr_id == rd_addr_mem && rs1_addr_id != 0 && we_reg_mem == 1) begin
        case(wb_sel_mem) 
            2'b00: rs1_data_idexe = 0;
            2'b01: rs1_data_idexe = alu_res_mem;
            2'b10: rs1_data_idexe = dmem_mem;
            2'b11: rs1_data_idexe = npc_mem;
            default: rs1_data_idexe = 0;
        endcase
    end
    else if (rs1_addr_id == rd_addr_wb && rs1_addr_id != 0 && we_reg_wb == 1)begin
        rs1_data_idexe = rd_data;
    end
    else begin
        rs1_data_idexe = rs1_data_id;
    end

    if (rs2_addr_id == rd_addr_exe && rs2_addr_id != 0 && we_reg_exe == 1) begin
        case(wb_sel_exe) 
            2'b00: rs2_data_idexe = 0;
            2'b01: rs2_data_idexe = alu_res_exe;
            2'b11: rs2_data_idexe = npc_exe;
            default: rs2_data_idexe = 0;
        endcase
    end
    else if (rs2_addr_id == rd_addr_mem && rs2_addr_id != 0 && we_reg_mem == 1) begin
        case(wb_sel_mem) 
            2'b00: rs2_data_idexe = 0;
            2'b01: rs2_data_idexe = alu_res_mem;
            2'b10: rs2_data_idexe = dmem_mem;
            2'b11: rs2_data_idexe = npc_mem;
            default: rs1_data_idexe = 0;
        endcase
    end
    else if (rs2_addr_id == rd_addr_wb && rs2_addr_id != 0 && we_reg_wb == 1)begin
        rs2_data_idexe = rd_data;
    end
    else begin
        rs2_data_idexe = rs2_data_id;
    end
    
    if (csr_addr_id == csr_addr_exe && we_csr_exe == 1) csr_val_idexe = csr_val_exe;
    else if (csr_addr_id == csr_addr_mem && we_csr_mem == 1) csr_val_idexe = csr_val_mem;
    else if (csr_addr_id == csr_addr_wb && we_csr_wb == 1) csr_val_idexe = csr_val_wb;
    else csr_val_idexe = csr_val_id;
end


endmodule