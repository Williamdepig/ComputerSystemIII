.section .text
.global _start1
_start1:
    li t0, 1
    li t1, 0x5000000
    sb t0, 0(t1)
    sb t0, 8(t1)
test1:
    addi x1, x0, 1
    addi x2, x0, 1
    addi x4, x0, 5
fibonacci:
    add x3, x1, x2
    add x1, x2, x3
    add x2, x1, x3
    j .fibonacci.continue
extra_test0:
    lla x1, extra_test2
    addi x1, x1, -0x100
    jalr x1, 0x100(x1)
.fibonacci.continue:
    addi x4, x4, -1
    bne x0, x4, fibonacci
    addi x5, x0, 0x63D
    bne x2, x5, fail1

    li x1, 0x45
    li x2, 0x457
    srli x2, x2, 4
    beq x1, x2, extra_test0
fail1:
    unimp
    j fail1
pass1:
    li x1,0x80000000
    jr x1
    unimp
extra_test3:
    lui x1, 0x7ffff
    csrw mscratch, x1
    csrr x2, mscratch
    bne x1, x2, fail1

    li x1, 0x0c
    csrwi mscratch, 0x0c
    csrr x2, mscratch
    bne x1, x2, fail1

    li x3, 0x120
    or x1, x1, x3
    csrs mscratch, x3
    csrr x2, mscratch
    bne x1, x2, fail1

    ori x1, x1, 0x18
    csrsi mscratch, 0x18
    csrr x2, mscratch
    bne x1, x2, fail1

    li x3, 0x110
    csrc mscratch, x3
    not x3, x3
    and x1, x1, x3
    csrr x2, mscratch
    bne x1, x2, fail1

    li x3, 0x0c
    not x3, x3
    and x1, x1, x3
    csrci mscratch, 0x0c

    csrr x2, mscratch
    bne x1, x2, fail1

    j pass1
    unimp
extra_test2:
    j extra_test3
    unimp
