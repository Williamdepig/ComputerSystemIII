`include "Define.vh"
`include "ExceptStruct.vh"
`include "CSRStruct.vh"
`include "TimerStruct.vh"

module CSRModule (
    input         clk,
    input         rst,
    input         fence_wb,
    input         csr_we_wb,
    input  [11:0] csr_addr_wb,
    input  [63:0] csr_val_wb,
    input  [11:0] csr_addr_id,
    output [63:0] csr_val_id,

    input [63:0] pc_wb,
    input [31:0] inst_wb,
    input        valid_wb,
    input [ 1:0] csr_ret_wb,
    input        csr_we_wb_temp,

    input TimerStruct::TimerPack   time_out,
    input ExceptStruct::ExceptPack except_wb,

    output [ 1:0] priv,
    output        switch_mode,
    output        fence_flush,
    output [63:0] pc_csr,

    output        cosim_interrupt,
    output [63:0] cosim_cause,

    output CSRStruct::CSRPack cosim_csr_info
);

    import ExceptStruct::ExceptPack;

    wire       [63:0] _time = time_out._time;
    wire              time_int = time_out.time_int;

    ExceptPack        except_commit;
    wire       [31:0] mcounteren_priv;
    CommitExceptExamine Commitexceptexmaine (
        .valid        (valid_wb),
        .pc_wb        (pc_wb),
        .priv         (priv),
        .mcounteren   (mcounteren_priv),
        .csr_ret_wb   (csr_ret_wb),
        .inst_wb      (inst_wb),
        .csr_we_wb    (csr_we_wb_temp),
        .except_wb    (except_wb),
        .except_commit(except_commit)
    );

    wire is_sstatus_w = (csr_addr_wb == `SSTATUS) & csr_we_wb;
    wire is_sie_w = (csr_addr_wb == `SIE) & csr_we_wb;
    wire is_stvec_w = (csr_addr_wb == `STVEC) & csr_we_wb;
    wire is_sscratch_w = (csr_addr_wb == `SSCRATCH) & csr_we_wb;
    wire is_sepc_w = (csr_addr_wb == `SEPC) & csr_we_wb;
    wire is_scause_w = (csr_addr_wb == `SCAUSE) & csr_we_wb;
    wire is_stval_w = (csr_addr_wb == `STVAL) & csr_we_wb;
    wire is_sip_w = (csr_addr_wb == `SIP) & csr_we_wb;
    wire is_satp_w = (csr_addr_wb == `SATP) & csr_we_wb;
    wire is_mstatus_w = (csr_addr_wb == `MSTATUS) & csr_we_wb;
    wire is_medeleg_w = (csr_addr_wb == `MEDELEG) & csr_we_wb;
    wire is_mideleg_w = (csr_addr_wb == `MIDELEG) & csr_we_wb;
    wire is_mie_w = (csr_addr_wb == `MIE) & csr_we_wb;
    wire is_mtvec_w = (csr_addr_wb == `MTVEC) & csr_we_wb;
    wire is_mcounteren_w = (csr_addr_wb == `MCOUNTEREN) & csr_we_wb;
    wire is_mscratch_w = (csr_addr_wb == `MSCRATCH) & csr_we_wb;
    wire is_mepc_w = (csr_addr_wb == `MEPC) & csr_we_wb;
    wire is_mcause_w = (csr_addr_wb == `MCAUSE) & csr_we_wb;
    wire is_mtval_w = (csr_addr_wb == `MTVAL) & csr_we_wb;
    wire is_mip_w = (csr_addr_wb == `MIP) & csr_we_wb;
    wire is_mcycle_w = (csr_addr_wb == `MCYCLE) & csr_we_wb;
    wire is_minstret_w = (csr_addr_wb == `MINSTRET) & csr_we_wb;

    reg  [63:0] mcycle_reg;
    always @(posedge clk) begin
        if (rst) begin
            mcycle_reg <= 64'b0;
        end else begin
            mcycle_reg <= mcycle_reg + 64'b1;
        end
    end
    wire [63:0] mcycle = mcycle_reg;
    wire [63:0] cycle = mcycle_reg;

    reg  [63:0] minstret_reg;
    always @(posedge clk) begin
        if (rst) begin
            minstret_reg <= 64'b0;
        end else if (valid_wb & ~switch_mode) begin
            minstret_reg <= minstret_reg + 64'b1;
        end
    end
    wire [63:0] minstret = minstret_reg;
    wire [63:0] instret = minstret_reg;

    reg  [63:0] _mie_reg;
    always @(posedge clk) begin
        if (rst) begin
            _mie_reg <= 64'h0;
        end else if (is_mie_w) begin
            _mie_reg <= csr_val_wb;
        end else if (is_sie_w) begin
            {_mie_reg[9:8], _mie_reg[5:4], _mie_reg[1:0]} <= {csr_val_wb[9:8], csr_val_wb[5:4], csr_val_wb[1:0]};
        end
    end
    wire [63:0] mie = _mie_reg;
    wire [63:0] sie = {54'b0, _mie_reg[9:8], 2'b0, _mie_reg[5:4], 2'b0, _mie_reg[1:0]};

    wire        mtip = time_int;
    wire        meip = 1'b0;
    wire        msip = 1'b0;
    reg heip_reg, seip_reg, ueip_reg, htip_reg, stip_reg, utip_reg, hsip_reg, ssip_reg, usip_reg;
    always @(posedge clk) begin
        if (rst) begin
            {heip_reg, seip_reg, ueip_reg, htip_reg, stip_reg, utip_reg, hsip_reg, ssip_reg, usip_reg} <= 9'b0;
        end else if (is_mip_w) begin
            {heip_reg, seip_reg, ueip_reg, htip_reg, stip_reg, utip_reg, hsip_reg, ssip_reg, usip_reg} <= {
                csr_val_wb[10:8], csr_val_wb[6:4], csr_val_wb[2:0]
            };
        end else if (is_sip_w) begin
            {seip_reg, ueip_reg, stip_reg, utip_reg, ssip_reg, usip_reg} <= {
                csr_val_wb[9:8], csr_val_wb[5:4], csr_val_wb[1:0]
            };
        end
    end
    wire [63:0] mip = {
        52'b0,
        meip,
        heip_reg,
        seip_reg,
        ueip_reg,
        mtip,
        htip_reg,
        stip_reg,
        utip_reg,
        msip,
        hsip_reg,
        ssip_reg,
        usip_reg
    };
    wire [63:0] sip = {54'b0, seip_reg, ueip_reg, 2'b0, stip_reg, utip_reg, 2'b0, ssip_reg, usip_reg};

    reg [63:0] satp_reg;
    always @(posedge clk) begin
        if (rst) begin
            satp_reg <= 64'b0;
        end else if (is_satp_w) begin
            satp_reg <= csr_val_wb;
        end
    end
    wire [63:0] satp = satp_reg;

    reg [63:0] stvec_reg;
    always @(posedge clk) begin
        if (rst) begin
            stvec_reg <= 64'b0;
        end else if (is_stvec_w) begin
            stvec_reg <= csr_val_wb;
        end
    end
    wire [63:0] stvec = stvec_reg;

    reg  [63:0] mtvec_reg;
    always @(posedge clk) begin
        if (rst) begin
            mtvec_reg <= 64'b0;
        end else if (is_mtvec_w) begin
            mtvec_reg <= csr_val_wb;
        end
    end
    wire [63:0] mtvec = mtvec_reg;

    reg  [63:0] mcounteren_reg;
    always @(posedge clk) begin
        if (rst) begin
            mcounteren_reg <= 64'b0;
        end else if (is_mcounteren_w) begin
            mcounteren_reg <= csr_val_wb;
        end
    end
    wire [63:0] mcounteren = mcounteren_reg;
    assign mcounteren_priv = mcounteren_reg[31:0];

    reg [63:0] sscratch_reg;
    always @(posedge clk) begin
        if (rst) begin
            sscratch_reg <= 64'b0;
        end else if (is_sscratch_w) begin
            sscratch_reg <= csr_val_wb;
        end
    end
    wire [63:0] sscratch = sscratch_reg;

    reg  [63:0] mscratch_reg;
    always @(posedge clk) begin
        if (rst) begin
            mscratch_reg <= 64'b0;
        end else if (is_mscratch_w) begin
            mscratch_reg <= csr_val_wb;
        end
    end
    wire [63:0] mscratch = mscratch_reg;

    reg  [63:0] medeleg_reg;
    always @(posedge clk) begin
        if (rst) begin
            medeleg_reg <= 64'b0;
        end else if (is_medeleg_w) begin
            medeleg_reg <= csr_val_wb;
        end
    end
    wire [63:0] medeleg = medeleg_reg;

    reg  [63:0] mideleg_reg;
    always @(posedge clk) begin
        if (rst) begin
            mideleg_reg <= 64'b0;
        end else if (is_mideleg_w) begin
            mideleg_reg <= csr_val_wb;
        end
    end
    wire [63:0] mideleg = mideleg_reg;

    wire        m_trap;
    wire        s_trap;
    wire        m_ret;
    wire        s_ret;

    reg  [ 1:0] priv_reg;
    reg [1:0] mpp_reg, hpp_reg;
    reg spp_reg, mpie_reg, hpie_reg, spie_reg, upie_reg, mie_reg, hie_reg, sie_reg, uie_reg;

    always @(posedge clk) begin
        if (rst) begin
            priv_reg <= 2'b11;
        end else if (m_trap) begin
            priv_reg <= 2'b11;
        end else if (s_trap) begin
            priv_reg <= 2'b01;
        end else if (m_ret) begin
            priv_reg <= mpp_reg;
        end else if (s_ret) begin
            priv_reg <= {1'b0, spp_reg};
        end
    end
    assign priv = priv_reg;

    always @(posedge clk) begin
        if (rst) begin
            {mpp_reg, hpp_reg, spp_reg, mpie_reg, hpie_reg, spie_reg, upie_reg, mie_reg, hie_reg, sie_reg, uie_reg} <=
                13'b0;
        end else if (m_trap) begin
            mie_reg  <= 1'b0;
            mpie_reg <= mie_reg;
            mpp_reg  <= priv_reg;
        end else if (s_trap) begin
            sie_reg  <= 1'b0;
            spie_reg <= sie_reg;
            spp_reg  <= priv[0];
        end else if (m_ret) begin
            mie_reg  <= mpie_reg;
            mpie_reg <= 1'b1;
            mpp_reg  <= 2'b0;
        end else if (s_ret) begin
            sie_reg  <= spie_reg;
            spie_reg <= 1'b1;
            spp_reg  <= 1'b0;
        end else if (is_mstatus_w) begin
            {mpp_reg, hpp_reg, spp_reg, mpie_reg, hpie_reg, spie_reg, upie_reg, mie_reg, hie_reg, sie_reg, uie_reg} <=
                csr_val_wb[12:0];
        end else if (is_sstatus_w) begin
            {spp_reg, spie_reg, upie_reg, sie_reg, uie_reg} <= {csr_val_wb[9], csr_val_wb[5:4], csr_val_wb[1:0]};
        end
    end
    wire [63:0] mstatus = {
        51'b0, mpp_reg, hpp_reg, spp_reg, mpie_reg, hpie_reg, spie_reg, upie_reg, mie_reg, hie_reg, sie_reg, uie_reg
    };
    wire [63:0] sstatus = {55'b0, spp_reg, 2'b0, spie_reg, upie_reg, 2'b0, sie_reg, uie_reg};

    ExceptPack except_final;
    reg [63:0] mepc_reg;
    always @(posedge clk) begin
        if (rst) begin
            mepc_reg <= 64'b0;
        end else if (m_trap) begin
            mepc_reg <= except_final.epc;
        end else if (is_mepc_w) begin
            mepc_reg <= csr_val_wb;
        end
    end
    wire [63:0] mepc = mepc_reg;

    reg  [63:0] sepc_reg;
    always @(posedge clk) begin
        if (rst) begin
            sepc_reg <= 64'b0;
        end else if (s_trap) begin
            sepc_reg <= except_final.epc;
        end else if (is_sepc_w) begin
            sepc_reg <= csr_val_wb;
        end
    end
    wire [63:0] sepc = sepc_reg;

    reg  [63:0] mcause_reg;
    always @(posedge clk) begin
        if (rst) begin
            mcause_reg <= 64'b0;
        end else if (m_trap) begin
            mcause_reg <= except_final.ecause;
        end else if (is_mcause_w) begin
            mcause_reg <= csr_val_wb;
        end
    end
    wire [63:0] mcause = mcause_reg;

    reg  [63:0] scause_reg;
    always @(posedge clk) begin
        if (rst) begin
            scause_reg <= 64'b0;
        end else if (s_trap) begin
            scause_reg <= except_final.ecause;
        end else if (is_scause_w) begin
            scause_reg <= csr_val_wb;
        end
    end
    wire [63:0] scause = scause_reg;

    reg  [63:0] mtval_reg;
    always @(posedge clk) begin
        if (rst) begin
            mtval_reg <= 64'b0;
        end else if (m_trap) begin
            mtval_reg <= except_final.etval;
        end else if (is_mtval_w) begin
            mtval_reg <= csr_val_wb;
        end
    end
    wire [63:0] mtval = mtval_reg;

    reg  [63:0] stval_reg;
    always @(posedge clk) begin
        if (rst) begin
            stval_reg <= 64'b0;
        end else if (s_trap) begin
            stval_reg <= except_final.etval;
        end else if (is_stval_w) begin
            stval_reg <= csr_val_wb;
        end
    end
    wire [63:0] stval = stval_reg;

    wire [ 1:0] csr_ret = csr_ret_wb;
    assign s_ret       = csr_ret[0] & ~s_trap & ~m_trap;
    assign m_ret       = csr_ret[1] & ~s_trap & ~m_trap;
    assign switch_mode = s_ret | m_ret | s_trap | m_trap;

    wire fence = fence_wb;
    assign fence_flush = fence;

    wire       [63:0] mask_interrupt = mie & mip;
    wire       [63:0] enable_interrupt_m = mask_interrupt & ~mideleg & {64{(priv == 2'b11 & mie_reg) | (priv < 2'b11)}};
    wire       [63:0] enable_interrupt_s = mask_interrupt & mideleg & {64{(priv == 2'b01 & sie_reg) | (priv == 2'b00)}};
    wire       [63:0] enable_interrupt = enable_interrupt_m | enable_interrupt_s;
    wire              interrupt = |enable_interrupt;
    wire              except = except_commit.except;

    ExceptPack        except_interrupt;
    assign except_interrupt.except = interrupt;
    assign except_interrupt.epc    = pc_wb;
    assign except_interrupt.etval  = 64'b0;
    wire [63:0] cause = enable_interrupt[11] ? `MEI : enable_interrupt[3] ?
        `MSI : enable_interrupt[7] ? `MTI : enable_interrupt[10] ? `HEI : enable_interrupt[2] ? `HSI :
        enable_interrupt[6] ? `HTI : enable_interrupt[9] ? `SEI : enable_interrupt[1] ? `SSI : enable_interrupt[5] ?
        `STI : enable_interrupt[8] ? `UEI : enable_interrupt[0] ? `USI : enable_interrupt[4] ? `UTI : 64'b0;
    assign except_interrupt.ecause = cause;
    assign except_final            = interrupt ? except_interrupt : except_commit;

    wire s_trap_int = (|((64'b1 << {1'b0, cause[62:0]}) & enable_interrupt_s)) & valid_wb;
    wire s_trap_exp = ~interrupt & except & |((64'b1 << except_commit.ecause) & medeleg);
    assign s_trap = (s_trap_int | s_trap_exp) & (priv == 2'b01);
    assign m_trap = (interrupt & valid_wb | except) & ~s_trap;

    assign pc_csr = m_trap ? mtvec : s_trap ? stvec : m_ret ? mepc : s_ret ? sepc : fence ? (pc_wb+4) : 64'b0;


    // wire is_sstatus_r=csr_addr_id==`SSTATUS;
    // wire is_sie_r=csr_addr_id==`SIE;
    // wire is_stvec_r=csr_addr_id==`STVEC;
    // wire is_sscratch_r=csr_addr_id==`SSCRATCH;
    // wire is_sepc_r=csr_addr_id==`SEPC;
    // wire is_scause_r=csr_addr_id==`SCAUSE;
    // wire is_sip_r=csr_addr_id==`SIP;
    // wire is_mstatus_r=csr_addr_id==`MSTATUS;
    // wire is_medeleg_r=csr_addr_id==`MEDELEG;
    // wire is_mideleg_r=csr_addr_id==`MIDELEG;
    // wire is_mie_r=csr_addr_id==`MIE;
    // wire is_mtvec_r=csr_addr_id==`MTVEC;
    // wire is_mscratch_r=csr_addr_id==`MSCRATCH;
    // wire is_mepc_r=csr_addr_id==`MEPC;
    // wire is_mcause_r=csr_addr_id==`MCAUSE;
    // wire is_mip_r=csr_addr_id==`MIP;
    // assign csr_val_id=is_mie_r?mie:is_sie_r?sie:is_mip_r?mip:is_sip_r?sip:
    //             is_stvec_r?stvec:is_mtvec_r?mtvec:is_sscratch_r?sscratch:
    //             is_mscratch_r?mscratch:is_medeleg_r?medeleg:is_mideleg_r?mideleg:
    //             is_mepc_r?mepc:is_sepc_r?sepc:is_mcause_r?mcause:is_scause_r?scause:
    //             is_mtval_r?mtval:is_stval_r?stval:64'b0;
    wire [63:0] compress_2                                             [7:0];
    wire [ 2:0] compress_index_2 = {csr_addr_id[10], csr_addr_id[1:0]};
    assign compress_2[`MCYCLE_COMPRESS]   = mcycle;
    assign compress_2[1]                  = 64'b0;
    assign compress_2[`MINSTRET_COMPRESS] = minstret;
    assign compress_2[3]                  = 64'b0;
    assign compress_2[`CYCLE_COMPRESS]    = cycle;
    assign compress_2[`TIME_COMPRESS]     = _time;
    assign compress_2[`INSTRET_COMPRESS]  = instret;
    assign compress_2[7]                  = 64'b0;

    wire [63:0] compress                                                            [31:0];
    wire [ 4:0] compress_index = {csr_addr_id[9], csr_addr_id[6], csr_addr_id[2:0]};
    assign compress[`SSTATUS_COMPRESS]    = sstatus;
    assign compress[1]                    = 64'b0;
    assign compress[2]                    = 64'b0;
    assign compress[3]                    = 64'b0;
    assign compress[`SIE_COMPRESS]        = sie;
    assign compress[`STVEC_COMPRESS]      = stvec;
    assign compress[6]                    = 64'b0;
    assign compress[7]                    = 64'b0;
    assign compress[`SSCRATCH_COMPRESS]   = sscratch;
    assign compress[`SEPC_COMPRESS]       = sepc;
    assign compress[`SCAUSE_COMPRESS]     = scause;
    assign compress[`STVAL_COMPRESS]      = stval;
    assign compress[`SIP_COMPRESS]        = sip;
    assign compress[13]                   = 64'b0;
    assign compress[14]                   = 64'b0;
    assign compress[15]                   = 64'b0;
    assign compress[`MSTATUS_COMPRESS]    = mstatus;
    assign compress[17]                   = 64'b0;
    assign compress[`MEDELEG_COMPRESS]    = medeleg;
    assign compress[`MIDELEG_COMPRESS]    = mideleg;
    assign compress[`MIE_COMPRESS]        = mie;
    assign compress[`MTVEC_COMPRESS]      = mtvec;
    assign compress[`MCOUNTEREN_COMPRESS] = 64'b0;
    assign compress[23]                   = 64'b0;
    assign compress[`MSCRATCH_COMPRESS]   = mscratch;
    assign compress[`MEPC_COMPRESS]       = mepc;
    assign compress[`MCAUSE_COMPRESS]     = mcause;
    assign compress[`MTVAL_COMPRESS]      = mtval;
    assign compress[`MIP_COMPRESS]        = mip;
    assign compress[29]                   = 64'b0;
    assign compress[30]                   = 64'b0;
    assign compress[31]                   = 64'b0;

    wire is_satp_r=csr_addr_id==`SATP;

    assign csr_val_id                     = is_satp_r ? satp :
                                            csr_addr_id[11] ? compress_2[compress_index_2] : compress[compress_index];

    assign cosim_interrupt                = interrupt;
    assign cosim_cause                    = except_final.ecause;

    assign cosim_csr_info.sstatus         = sstatus;
    assign cosim_csr_info.sie             = sie;
    assign cosim_csr_info.stvec           = stvec;
    assign cosim_csr_info.sscratch        = sscratch;
    assign cosim_csr_info.sepc            = sepc;
    assign cosim_csr_info.scause          = scause;
    assign cosim_csr_info.stval           = stval;
    assign cosim_csr_info.sip             = sip;
    assign cosim_csr_info.satp            = satp;
    assign cosim_csr_info.mstatus         = mstatus;
    assign cosim_csr_info.mie             = mie;
    assign cosim_csr_info.mtvec           = mtvec;
    assign cosim_csr_info.mcounteren      = mcounteren;
    assign cosim_csr_info.mscratch        = mscratch;
    assign cosim_csr_info.mepc            = mepc;
    assign cosim_csr_info.mcause          = mcause;
    assign cosim_csr_info.mtval           = mtval;
    assign cosim_csr_info.mip             = mip;
    assign cosim_csr_info.medeleg         = medeleg;
    assign cosim_csr_info.mideleg         = mideleg;
    assign cosim_csr_info.mcycle          = mcycle;
    assign cosim_csr_info.minstret        = minstret;
    assign cosim_csr_info.priv            = {62'b0, priv};
    assign cosim_csr_info.switch_mode     = {63'b0, switch_mode};
    assign cosim_csr_info.pc_csr          = pc_csr;
    assign cosim_csr_info.cosim_epc       = except_final.epc;
    assign cosim_csr_info.cosim_cause     = except_final.ecause;
    assign cosim_csr_info.cosim_tval      = except_final.etval;
    assign cosim_csr_info.csr_ret         = {62'b0, csr_ret};

endmodule
