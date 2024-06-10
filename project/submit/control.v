module Control(
  input [31:0] inst,
// control sign 
  output reg is_load,
  output reg we_reg,
  output reg we_mem,
  output reg npc_sel,
  output reg [1:0]alu_asel,
  output reg [1:0]alu_bsel,
  output reg [1:0]wb_sel,
  output reg [2:0]immgen_op,
  output reg [2:0]bralu_op,
  output reg [2:0]memdata_width,
  output reg [3:0]alu_op,
  output reg use_rs1,
  output reg use_rs2,

  output reg [1:0]csr_ret,
  output reg [2:0]csr_sel,
  output reg we_csr

);

// inst code
  wire [6:0] op_code;
  wire [2:0] funct3;
  wire funct7_1;
  wire [11:0]csr_imm;

  assign op_code = inst[6:0];
  assign funct3  = inst[14:12];
  assign funct7_1= inst[30];
  assign csr_imm = inst[31:20];

  always @(*) begin
    is_load = 0;
    we_reg = 0;    //寄存器写使能
    we_mem = 0;    //内存写使能
    npc_sel = 0;   //pc写回选择
    alu_op = 0;    //alu模式
    immgen_op = 0; //立即数生成type
    bralu_op = 0;  //branch操作
    wb_sel = 0;    //寄存器写回选择
    alu_asel = 0;
    alu_bsel = 0;
    memdata_width = 0 ;//数据类型
    use_rs1 = 0;
    use_rs2 = 0;
    we_csr = 0;
    csr_ret = 0;
    csr_sel = 0;
    case (op_code)
        7'b0110011:begin
            alu_asel = 1; alu_bsel=1; wb_sel = 1; we_reg = 1; use_rs1 = 1; use_rs2 = 1;
            case({funct7_1,funct3})
                4'b0000: alu_op = 0;//add
                4'b1000: alu_op = 1;//sub
                4'b0111: alu_op = 2;//and
                4'b0110: alu_op = 3;//or
                4'b0100: alu_op = 4;//xor
                4'b0010: alu_op = 5;//slt
                4'b0011: alu_op = 6;//sltu
                4'b0001: alu_op = 7;//sll
                4'b0101: alu_op = 8;//srl
                4'b1101: alu_op = 9;//sra
                default: alu_op = 0;
            endcase
        end                     //R-type
        7'b0010011:begin
            alu_asel = 1; alu_bsel = 2; we_reg = 1; immgen_op = 1; wb_sel = 1; use_rs1 = 1;
            case(funct3)
                3'b000: alu_op = 0;//addi
                3'b010: alu_op = 5;//slti
                3'b011: alu_op = 6;//sltiu
                3'b100: alu_op = 4;//xori
                3'b110: alu_op = 3;//ori
                3'b111: alu_op = 2;//andi
                3'b001: alu_op = 7;//slli
                3'b101: begin
                    if(funct7_1) alu_op = 9;//srai
                    else alu_op = 8;//srli
                end
            endcase
        end                    //I-type
        7'b0000011:begin
            alu_asel = 1; alu_bsel = 2; we_reg = 1; immgen_op = 1; wb_sel = 2; use_rs1 = 1; is_load = 1;
            case(funct3)
                3'b000: memdata_width = 3'b100;//lb
                3'b001: memdata_width = 3'b011;//lh
                3'b010: memdata_width = 3'b010;//lw
                3'b011: memdata_width = 3'b001;//ld
                3'b100: memdata_width = 3'b111;//lbu
                3'b101: memdata_width = 3'b110;//lhu
                3'b110: memdata_width = 3'b101;//lwu
                default:memdata_width = 3'b000;
            endcase
        end                    //load
        7'b0100011:begin
            alu_asel = 1; alu_bsel = 2; immgen_op = 2; we_mem = 1; use_rs1 = 1; use_rs2 = 1;
            case(funct3)
                3'b000: memdata_width = 3'b100;//sb
                3'b001: memdata_width = 3'b011;//sh
                3'b010: memdata_width = 3'b010;//sw
                3'b011: memdata_width = 3'b001;//sd
                default:memdata_width = 3'b000;
            endcase
        end                    //store
        7'b1100011:begin
            alu_asel = 2; alu_bsel = 2; immgen_op = 3; npc_sel = 1; use_rs1 = 1 ;use_rs2 = 1;
            case(funct3)
                3'b000: bralu_op = 3'b001;//beq
                3'b001: bralu_op = 3'b010;//bne
                3'b100: bralu_op = 3'b011;//blt
                3'b101: bralu_op = 3'b100;//bge
                3'b110: bralu_op = 3'b101;//bltu
                3'b111: bralu_op = 3'b110;//bgeu
                default:bralu_op = 0;
            endcase
        end                    //B-type
        7'b0110111:begin
            immgen_op = 4; we_reg = 1; alu_bsel = 2; wb_sel = 1; 
        end                    //lui
        7'b0010111:begin
            immgen_op = 4; we_reg = 1; alu_asel = 2; alu_bsel = 2; wb_sel = 1;
        end                    //auipc
        7'b1101111:begin
            immgen_op = 5; we_reg = 1; alu_asel = 2; alu_bsel = 2; wb_sel = 3; npc_sel = 1;
        end                    //jal
        7'b1100111:begin
            immgen_op = 1; we_reg = 1; alu_asel = 1; alu_bsel = 2; wb_sel = 3; npc_sel = 1; use_rs1 = 1;
        end                    //jalr
        7'b0011011:begin
            immgen_op = 1; we_reg = 1; alu_asel = 1; alu_bsel = 2; wb_sel = 1; use_rs1 = 1;
            case(funct3)
                3'b000: alu_op = 10;//addiw
                3'b001: alu_op = 12;//slliw
                3'b101: begin
                    if(funct7_1) alu_op = 14;//sraiw
                    else alu_op = 13;//srliw
                end
                default: alu_op = 0 ;
            endcase
        end                    //addiw,slliw,srliw,sraiw
        7'b0111011:begin
            alu_asel = 1; alu_bsel=1; wb_sel = 1; we_reg = 1; use_rs1 = 1; use_rs2 = 1;
            case({funct7_1,funct3})
                4'b0000: alu_op = 10;//addw
                4'b1000: alu_op = 11;//subw
                4'b0001: alu_op = 12;//sllw
                4'b0101: alu_op = 13;//srlw
                4'b1101: alu_op = 14;//sraw
                default: alu_op = 0 ;
            endcase
        end
        7'b1110011:begin    //csr
            wb_sel = 1;we_reg = 1;we_csr = 1;alu_asel = 3;
            case(funct3)
                3'b000:begin    //ecall, eret
                    case(csr_imm)
                        12'h002: csr_ret = 2'b00; //uret
                        12'h102: csr_ret = 2'b01; //sret
                        12'h302: csr_ret = 2'b11; //mret
                        default:csr_ret = 2'b00;
                    endcase
                end
                3'b001:begin    //csrrw 
                    use_rs1 = 1;
                    csr_sel = 1;
                end         
                3'b010:begin    //csrrs
                    use_rs1 = 1;
                    csr_sel = 2;
                end
                3'b011:begin    //csrrc
                    use_rs1 = 1;
                    csr_sel = 3;
                end
                3'b101:begin    //csrrwi
                    use_rs1 = 0;
                    csr_sel = 4;
                end
                3'b110:begin    //csrrsi
                    use_rs1 = 0;
                    csr_sel = 5;
                end
                3'b111:begin    //csrrci
                    use_rs1 = 0;
                    csr_sel = 6;
                end
                default: begin
                    csr_sel = 0;
                    csr_ret = 2'b00;
                end
            endcase
        end
        default: alu_op = 0;
    endcase
  end

endmodule