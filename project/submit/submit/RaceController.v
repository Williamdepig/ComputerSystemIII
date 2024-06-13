`timescale 1ns/1ps

module RaceController(
    input is_load_exe,
    input [4:0]rs1_addr_id,
    input [4:0]rs2_addr_id,
    input use_rs1_id,
    input use_rs2_id,
    input [4:0]rd_addr_exe,
    input [4:0]rd_addr_mem,
    input we_reg_exe,
    input we_reg_mem,
    input npc_sel_id,
    input npc_sel_exe,
    input [3:0]br_taken,
    input error_prediction,

    input switch_mode,
    input fence_flush,

    input if_stall,       //取内存的stall
    input mem_stall, 

    output wire stall_PC,
    output wire stall_IFID,
    output wire stall_IDEXE,
    output wire stall_EXEMEM,
    output wire stall_MEMWB,
    output wire flush_IFID,
    output wire flush_IDEXE,
    output wire flush_EXEMEM,
    output wire flush_MEMWB
);
//    assign stall_IFID = (rs1_addr_id == rd_addr_exe & we_reg_exe & rs1_addr_id != 0 & use_rs1_id) | (rs2_addr_id == rd_addr_exe & we_reg_exe & rs2_addr_id != 0 & use_rs2_id) | (rs1_addr_id == rd_addr_mem & we_reg_mem & rs1_addr_id != 0 & use_rs1_id) | (rs2_addr_id == rd_addr_mem & we_reg_mem & rs2_addr_id != 0 & use_rs2_id); 
    wire _switch_mode = switch_mode | fence_flush;
    assign stall_IFID = ((is_load_exe == 1 && rs1_addr_id == rd_addr_exe && we_reg_exe && rs1_addr_id != 0) || (is_load_exe == 1 && rs2_addr_id == rd_addr_exe && we_reg_exe && rs2_addr_id != 0) || stall_IDEXE)&&~error_prediction&&~_switch_mode;
    assign stall_PC = ~_switch_mode&(stall_IFID | if_stall)&~error_prediction;
    assign stall_IDEXE = (stall_EXEMEM || (error_prediction & if_stall))&&~_switch_mode;
    assign stall_EXEMEM = mem_stall & ~_switch_mode;
    assign stall_MEMWB = 0;
    assign flush_IFID = (stall_PC & ~stall_IFID) | _switch_mode | error_prediction;
    assign flush_IDEXE = (stall_IFID & ~stall_IDEXE) | _switch_mode | error_prediction;
    assign flush_EXEMEM = (stall_IDEXE & ~stall_EXEMEM) | _switch_mode;
    assign flush_MEMWB = (stall_EXEMEM & ~stall_MEMWB) | _switch_mode;



endmodule