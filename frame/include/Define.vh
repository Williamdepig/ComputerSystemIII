`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_AND  4'b0010
`define ALU_OR   4'b0011
`define ALU_XOR  4'b0100
`define ALU_SLT  4'b0101
`define ALU_SLTU 4'b0110
`define ALU_SLL  4'b0111
`define ALU_SRL  4'b1000
`define ALU_SRA  4'b1001
`define ALU_ADDW    4'b1010
`define ALU_SUBW    4'b1011
`define ALU_SLLW    4'b1100
`define ALU_SRLW    4'b1101
`define ALU_SRAW    4'b1110
`define ALU_DEFAULT 4'b1111

`define MEM_NO 3'b000
`define MEM_D  3'b001
`define MEM_W  3'b010
`define MEM_H  3'b011
`define MEM_B  3'b100
`define MEM_UB 3'b101
`define MEM_UH 3'b110
`define MEM_UW 3'b111

`define CMP_NO  3'b000
`define CMP_EQ  3'b001
`define CMP_NE  3'b010
`define CMP_LT  3'b011
`define CMP_GE  3'b100
`define CMP_LTU 3'b101
`define CMP_GEU 3'b110

`define LOAD_OPCODE     7'b0000011
`define IMM_OPCODE      7'b0010011
`define AUIPC_OPCODE    7'b0010111
`define IMMW_OPCODE     7'b0011011
`define STORE_OPCODE    7'b0100011
`define REG_OPCODE      7'b0110011
`define LUI_OPCODE      7'b0110111
`define REGW_OPCODE     7'b0111011
`define BRANCH_OPCODE   7'b1100011
`define JALR_OPCODE     7'b1100111
`define JAL_OPCODE      7'b1101111
`define CSR_OPCODE      7'b1110011

`define BEQ_FUNCT3 3'b000
`define BNE_FUNCT3 3'b001
`define BLT_FUNCT3 3'b100
`define BGE_FUNCT3 3'b101
`define BLTU_FUNCT3 3'b110
`define BGEU_FUNCT3 3'b111

`define LB_FUNCT3 3'b000
`define LH_FUNCT3 3'b001
`define LW_FUNCT3 3'b010
`define LD_FUNCT3 3'b011
`define LBU_FUNCT3 3'b100
`define LHU_FUNCT3 3'b101
`define LWU_FUNCT3 3'b110

`define SB_FUNCT3 3'b000
`define SH_FUNCT3 3'b001
`define SW_FUNCT3 3'b010
`define SD_FUNCT3 3'b011

`define ADD_FUNCT3 3'b000
`define SUB_FUNCT3 3'b000
`define SLL_FUNCT3 3'b001
`define SLT_FUNCT3 3'b010
`define SLTU_FUNCT3 3'b011
`define XOR_FUNCT3 3'b100
`define SRL_FUNCT3 3'b101
`define SRA_FUNCT3 3'b101
`define OR_FUNCT3  3'b110
`define AND_FUNCT3 3'b111

`define ADDW_FUNCT3 3'b000
`define SUBW_FUNCT3 3'b000
`define SLLW_FUNCT3 3'b001
`define SRLW_FUNCT3 3'b101
`define SRAW_FUNCT3 3'b101

`define CSR_WRITE 2'b01
`define CSR_SET   2'b10
`define CSR_CLEAR 2'b11

`define TIME_BASE 64'h2000000
`define TIME_LEN 64'h10000
`define MTIME_BASE 64'h200bff8
`define MTIME_LEN 64'h8
`define MTIMECMP_BASE 64'h2004000
`define MTIMECMP_LEN 64'h8

`define DISP_BASE 64'h3000000
`define DISP_LEN 64'h1

`define UART_BASE 64'h4000000
`define UART_LEN 64'h10

`define MMU_BASE 64'h5000000
`define MMU_LEN 64'h10
`define ICACHE_BASE 64'h5000000
`define ICACHE_LEN 64'h8
`define DCACHE_BASE 64'h5000008
`define DCACHE_LEN 64'h8

`define ROM_BASE 64'h0
`define ROM_LEN 64'h1000
`define BUFFER_BASE 64'h10000
`define BUFFER_LEN 64'h4000
`define MEM_BASE 64'h80000000
`define MEM_LEN 64'h80000000

`define USI 64'h8000000000000000
`define SSI 64'h8000000000000001
`define HSI 64'h8000000000000002
`define MSI 64'h8000000000000003
`define UTI 64'h8000000000000004
`define STI 64'h8000000000000005
`define HTI 64'h8000000000000006
`define MTI 64'h8000000000000007
`define UEI 64'h8000000000000008
`define SEI 64'h8000000000000009
`define HEI 64'h800000000000000a
`define MEI 64'h800000000000000b
`define INST_ADDR_UNALIGN  64'h0
`define INST_ACCESS_FAULT  64'h1
`define ILLEAGAL_INST      64'h2
`define BREAKPOINT         64'h3
`define LOAD_ADDR_UNALIGN  64'h4
`define LOAD_ACCESS_FAULT  64'h5
`define STORE_ADDR_UNALIGN 64'h6
`define STORE_ACCESS_FAULT 64'h7
`define U_CALL 64'h8
`define S_CALL 64'h9
`define H_CALL 64'ha
`define M_CALL 64'hb

`define ECALL 32'h00000073
`define EBREAK 32'h00100073

`define MRET  32'h30200073
`define SRET  32'h10200073

`define CYCLE       12'hc00
`define TIME        12'hc01
`define INSTRET     12'hc02
`define MCYCLE      12'hb00
`define MINSTRET    12'hb02
`define CYCLE_COMPRESS      3'b100
`define TIME_COMPRESS       3'b101
`define INSTRET_COMPRESS    3'b110
`define MCYCLE_COMPRESS     3'b000
`define MINSTRET_COMPRESS   3'b010


`define SSTATUS  12'h100
`define SIE      12'h104
`define STVEC    12'h105
`define SSCRATCH 12'h140
`define SEPC     12'h141
`define SCAUSE   12'h142
`define STVAL    12'h143
`define SIP      12'h144
`define SATP     12'h180

`define SSTATUS_COMPRESS  5'b00000
`define SIE_COMPRESS      5'b00100
`define STVEC_COMPRESS    5'b00101
`define SSCRATCH_COMPRESS 5'b01000
`define SEPC_COMPRESS     5'b01001
`define SCAUSE_COMPRESS   5'b01010
`define STVAL_COMPRESS    5'b01011
`define SIP_COMPRESS      5'b01100
`define SATP_COMPRESS     5'b01101

`define MSTATUS     12'h300
`define MEDELEG     12'h302
`define MIDELEG     12'h303
`define MIE         12'h304
`define MTVEC       12'h305
`define MCOUNTEREN   12'h306
`define MSCRATCH    12'h340
`define MEPC        12'h341
`define MCAUSE      12'h342
`define MTVAL       12'h343
`define MIP         12'h344

`define MSTATUS_COMPRESS   5'b10000
`define MEDELEG_COMPRESS   5'b10010
`define MIDELEG_COMPRESS   5'b10011
`define MIE_COMPRESS       5'b10100
`define MTVEC_COMPRESS     5'b10101
`define MCOUNTEREN_COMPRESS 5'b10110
`define MSCRATCH_COMPRESS  5'b11000
`define MEPC_COMPRESS      5'b11001
`define MCAUSE_COMPRESS    5'b11010
`define MTVAL_COMPRESS     5'b11011
`define MIP_COMPRESS       5'b11100