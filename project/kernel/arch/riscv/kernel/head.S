.extern start_kernel
.extern _srodata
  .section .text.init
  .globl _start
_start:
  la sp, stack_top
  li t0, 0xffffffdf80000000
  sub sp, sp, t0

  call setup_vm
  call relocate

  call mm_init
  call setup_vm_final
  call task_init

  la a0, _traps
  csrw stvec, a0

  li a0, 32  #0b100000
  csrs sie, a0

  # li a0, 0x50000
  # xor a1, a1, a1
  # xor a2, a2, a2
  # xor a3, a3, a3
  # xor a4, a4, a4
  # xor a5, a5, a5
  # xor a6, a6, a6
  # xor a7, a7, a7
  # ecall

  rdtime a0
  li t0, 0x30000
  add a0, a0, t0
  call sbi_set_timer

  li a0, 2
  csrs sstatus, a0
  # jal _srodata
  jal start_kernel

relocate:
  li t0, 0xffffffdf80000000 # PA2VA_OFFSET
  add ra, ra, t0
  add sp, sp, t0

  la t0, _after_satp
  csrw stvec, t0


  # set satp with early_pgtbl‘s physical address

  la t0, early_pgtbl
  li t1, 0xffffffdf80000000
  sub t0, t0, t1
  li t1, 8
  slli t1, t1, 60     # mode 部分设置为 8
  srli t0, t0, 12     # PPN 部分设置为页表物理地址右移 12 位
  or t0, t0, t1
  csrw satp, t0

  # flush tlb
_after_satp:
  sfence.vma zero, zero
  fence.i

  ret

  .section .stack.entry
  .globl stack_bottom
stack_bottom:
  .space 0x1000

  .globl stack_top
stack_top:

#   .section .bss.stack
#   .globl boot_stack
# boot_stack:
#   .space 0x1000

#   .globl stack_top
# stack_top: