`timescale 1ns/1ps

module PC_MUX(
    input rst,
    input [63:0] npc,
    input [63:0] npc_exe,
    input [63:0] alu_res,
    input npc_sel,
    // input [3:0] br_taken,
    input jump_if,
    input [63:0]pc_target_if,

    input [63:0]predict_pc_exe,
    input jump_exe, 

    output error_prediction,
    output [63:0] pc
    
);
    wire [63:0]true_pc;
    // always @(*)begin
    //     // if(npc_sel) begin
    //     //     if(br_taken[2:0] == 0) pc = alu_res;    //J-type指令
    //     //     else if(br_taken[3] == 1) pc = alu_res; //B-type跳转成立
    //     //     else pc = npc;                        //B-type跳转不成立
    //     // end
    //     // else pc = npc;
    //     if (jump_if) pc = pc_target_if;
    //     else pc = npc;
    // end
    assign pc = error_prediction ? true_pc : 
                jump_if ? pc_target_if : 
                npc;
    assign true_pc = npc_sel && jump_exe ? alu_res : npc_exe;
    assign error_prediction = (true_pc != predict_pc_exe);


 
endmodule