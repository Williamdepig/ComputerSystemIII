`ifndef __CSR_STRUCT__
`define __CSR_STRUCT__
package CSRStruct;

    typedef struct {
        logic [63:0] sstatus;
        logic [63:0] sie;
        logic [63:0] stvec;
        logic [63:0] sscratch;
        logic [63:0] sepc;
        logic [63:0] scause;
        logic [63:0] stval;
        logic [63:0] sip;
        logic [63:0] satp;

        logic [63:0] mstatus;
        logic [63:0] mie;
        logic [63:0] mtvec;
        logic [63:0] mcounteren;
        logic [63:0] mscratch;
        logic [63:0] mepc;
        logic [63:0] mcause;
        logic [63:0] mtval;
        logic [63:0] mip;

        logic [63:0] medeleg;
        logic [63:0] mideleg;

        logic [63:0] mcycle;
        logic [63:0] minstret;

        logic [63:0] priv;
        logic [63:0] switch_mode;
        logic [63:0] pc_csr;
        logic [63:0] cosim_epc;
        logic [63:0] cosim_cause;
        logic [63:0] cosim_tval;
        logic [63:0] csr_ret;
    } CSRPack;

endpackage

`endif
