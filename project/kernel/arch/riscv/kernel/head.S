#include "defs.h"

    .section .text.init
    .globl _start
_start:
    # need to setup sp since setup_vm is a C function
    # s0 is callee-saved, so we can use it as a temporary register
    la sp, _estack

    li s0, PA2VA_OFFSET
    li t0, VM_START
    mv s1, s0

    # If sp >= VM_START, we are already in virtual memory
    # which implies PIE is enabled, GOT is used
    bgeu sp, t0, 2f

    # s1 = PIE ? PA2VA_OFFSET : 0
    li s1, 0

2:
    sub sp, sp, s1

    # setup early virtual memory
    call setup_vm
    # relocate pc to virtual address
    call relocate

    # init memory
    call mm_init

    # setup virtual memory
    call setup_vm_final

    # set stvec = _traps
    la a0, _traps
    csrw stvec, a0

    # init task
    call task_init

    # set sie[STIE] = 1
    # STIE: bit 5
    li a0, 0x20
    csrs sie, a0

    tail start_kernel


relocate:
    # convert to virtual address
    add ra, ra, s0
    add sp, sp, s0

    la t0, 1f
    sub t1, s0, s1 # t1 = PIE ? 0 : PA2VA_OFFSET
    add t0, t0, t1
    csrrw t2, stvec, t0 # this does not need conversion

    # use early_pgtbl as kernel pagetable

    li t0, (8 << 60) # Mode = 8 => Sv39
    la t1, early_pgtbl
    sub t1, t1, s1 # convert page table address to physical address

    srli t1, t1, 12 # PA >> 12 == PPN
    or t0, t0, t1

    # enable virtual memory by setting satp
    # If identity mapping is not used, an exception will be raised when the
    # first instruction is executed after setting satp. stvec is set to the
    # trampoline vector, which will relocate the pc to the correct virtual
    # address. This needs sstatus[SIE] and sie[SSIE] to be set.
    csrsi sie, 0x2
    csrw satp, t0

    # flush TLB
    sfence.vma

    # flush icache
    fence.i

    csrw stvec, t2
    csrci sie, 0x2
    ret

# trampoline vector
1:
    csrr t0, sepc
    add t0, t0, s0
    csrw sepc, t0
    sret
