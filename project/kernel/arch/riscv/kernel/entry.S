#include "defs.h"

    .section .text.entry
    .align 2
    .globl _traps
_traps:
    # If sscratch == 0, trap is from S-mode, do not swap stack
    csrrw sp, sscratch, sp
    bnez sp, 1f
    csrrw sp, sscratch, zero # swap back

1:
    # 1. save registers and sepc to stack
    # struct pt_regs {
    #   uint64_t regs[32]; // x0-x31
    #   uint64_t sepc;
    # };

    addi sp, sp, -(SIZEOF_PT_REGS)

    sd x0, 0(sp)
    sd x1, 1*8(sp)
    # x2 is sp, saved later
    sd x3, 3*8(sp)
    sd x4, 4*8(sp)
    sd x5, 5*8(sp)
    sd x6, 6*8(sp)
    sd x7, 7*8(sp)
    sd x8, 8*8(sp)
    sd x9, 9*8(sp)
    sd x10, 10*8(sp)
    sd x11, 11*8(sp)
    sd x12, 12*8(sp)
    sd x13, 13*8(sp)
    sd x14, 14*8(sp)
    sd x15, 15*8(sp)
    sd x16, 16*8(sp)
    sd x17, 17*8(sp)
    sd x18, 18*8(sp)
    sd x19, 19*8(sp)
    sd x20, 20*8(sp)
    sd x21, 21*8(sp)
    sd x22, 22*8(sp)
    sd x23, 23*8(sp)
    sd x24, 24*8(sp)
    sd x25, 25*8(sp)
    sd x26, 26*8(sp)
    sd x27, 27*8(sp)
    sd x28, 28*8(sp)
    sd x29, 29*8(sp)
    sd x30, 30*8(sp)
    sd x31, 31*8(sp)

    addi a1, sp, SIZEOF_PT_REGS
    sd a1, 2*8(sp)

    csrr a1, sepc
    sd a1, 32*8(sp)

    # 2. call trap_handler
    csrr a0, scause
    mv a1, sp # pt_regs
    call trap_handler

    # [[fallthrough]]

    .globl __ret_from_fork
__ret_from_fork:
    # 3. restore sepc and 32 registers (x2(sp) should be restored last) from stack
    ld a0, 32*8(sp)
    csrw sepc, a0

    ld x31, 31*8(sp)
    ld x30, 30*8(sp)
    ld x29, 29*8(sp)
    ld x28, 28*8(sp)
    ld x27, 27*8(sp)
    ld x26, 26*8(sp)
    ld x25, 25*8(sp)
    ld x24, 24*8(sp)
    ld x23, 23*8(sp)
    ld x22, 22*8(sp)
    ld x21, 21*8(sp)
    ld x20, 20*8(sp)
    ld x19, 19*8(sp)
    ld x18, 18*8(sp)
    ld x17, 17*8(sp)
    ld x16, 16*8(sp)
    ld x15, 15*8(sp)
    ld x14, 14*8(sp)
    ld x13, 13*8(sp)
    ld x12, 12*8(sp)
    ld x11, 11*8(sp)
    ld x10, 10*8(sp)
    ld x9, 9*8(sp)
    ld x8, 8*8(sp)
    ld x7, 7*8(sp)
    ld x6, 6*8(sp)
    ld x5, 5*8(sp)
    ld x4, 4*8(sp)
    ld x3, 3*8(sp)
    # x2 is sp, restored later
    ld x1, 1*8(sp)
    # x0 need not be restored

    ld sp, 2*8(sp)

    # swap stack if necessary
    csrrw sp, sscratch, sp
    bnez sp, 2f
    csrrw sp, sscratch, zero # swap back

2:
    # 4. return from trap
    sret


    .globl __dummy
__dummy:
    # switch stack
    csrrw sp, sscratch, sp

    csrw sepc, x0
    sret


    .globl __switch_to
__switch_to:
    # save state to prev process
    sd ra, OFFSETOF_TS_THREAD+0*8(a0)
    sd sp, OFFSETOF_TS_THREAD+1*8(a0)
    sd s0, OFFSETOF_TS_THREAD+2*8(a0)
    sd s1, OFFSETOF_TS_THREAD+3*8(a0)
    sd s2, OFFSETOF_TS_THREAD+4*8(a0)
    sd s3, OFFSETOF_TS_THREAD+5*8(a0)
    sd s4, OFFSETOF_TS_THREAD+6*8(a0)
    sd s5, OFFSETOF_TS_THREAD+7*8(a0)
    sd s6, OFFSETOF_TS_THREAD+8*8(a0)
    sd s7, OFFSETOF_TS_THREAD+9*8(a0)
    sd s8, OFFSETOF_TS_THREAD+10*8(a0)
    sd s9, OFFSETOF_TS_THREAD+11*8(a0)
    sd s10, OFFSETOF_TS_THREAD+12*8(a0)
    sd s11, OFFSETOF_TS_THREAD+13*8(a0)

    # here we can use s0 as a temporary register safely
    csrr s0, sepc
    sd s0, OFFSETOF_TS_THREAD+14*8(a0)
    csrr s0, sstatus
    sd s0, OFFSETOF_TS_THREAD+15*8(a0)
    csrr s0, sscratch
    sd s0, OFFSETOF_TS_THREAD+16*8(a0)
    csrr s0, stval
    sd s0, OFFSETOF_TS_THREAD+17*8(a0)
    csrr s0, scause
    sd s0, OFFSETOF_TS_THREAD+18*8(a0)

    # restore state from next process
    ld s0, OFFSETOF_TS_THREAD+18*8(a1)
    csrw scause, s0
    ld s0, OFFSETOF_TS_THREAD+17*8(a1)
    csrw stval, s0
    ld s0, OFFSETOF_TS_THREAD+16*8(a1)
    csrw sscratch, s0
    ld s0, OFFSETOF_TS_THREAD+15*8(a1)
    csrw sstatus, s0
    ld s0, OFFSETOF_TS_THREAD+14*8(a1)
    csrw sepc, s0

    ld s11, OFFSETOF_TS_THREAD+13*8(a1)
    ld s10, OFFSETOF_TS_THREAD+12*8(a1)
    ld s9, OFFSETOF_TS_THREAD+11*8(a1)
    ld s8, OFFSETOF_TS_THREAD+10*8(a1)
    ld s7, OFFSETOF_TS_THREAD+9*8(a1)
    ld s6, OFFSETOF_TS_THREAD+8*8(a1)
    ld s5, OFFSETOF_TS_THREAD+7*8(a1)
    ld s4, OFFSETOF_TS_THREAD+6*8(a1)
    ld s3, OFFSETOF_TS_THREAD+5*8(a1)
    ld s2, OFFSETOF_TS_THREAD+4*8(a1)
    ld s1, OFFSETOF_TS_THREAD+3*8(a1)
    ld s0, OFFSETOF_TS_THREAD+2*8(a1)
    ld sp, OFFSETOF_TS_THREAD+1*8(a1)
    ld ra, OFFSETOF_TS_THREAD+0*8(a1)

    # update satp
    # t1 = a1->pgd
    li t0, PA2VA_OFFSET
    ld t1, OFFSETOF_TS_THREAD+19*8(a1)
    sub t1, t1, t0 # convert to physical address
    li t0, (8 << 60) # Sv39
    srli t1, t1, 12 # PA >> 12 == PPN
    or t0, t0, t1

    csrw satp, t0

    sfence.vma
    fence.i

    ret
