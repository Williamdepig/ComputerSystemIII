// arch/riscv/kernel/vm.c

#include "mm.h"
#include "vm.h"
#include "defs.h"
#include "string.h"
#include "kio.h"

extern uint8_t _stext[];
extern uint8_t _srodata[];
extern uint8_t _sdata[];

/* early_pgtbl: 用于 setup_vm 进行 1GB 的映射。 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));
/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射。 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm(void) {
  /*
  1. 由于是进行 1GB 的映射 这里不需要使用多级页表
  2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
      high bit 可以忽略
      中间 9 bit 作为 early_pgtbl 的 index
      低 30 bit 作为 页内偏移 这里注意到 30 = 9 + 9 + 12， 即我们只使用根页表， 根页表的每个 entry 都对应 1GB 的区域。
  3. Page Table Entry 的权限 V | R | W | X 位设置为 1
  */

  memset(early_pgtbl, 0, PGSIZE);
  const uint64_t pa = PHY_START;
  const uint64_t va = VM_START;

  // PPN[2]: Sv39 PA[55:30] => PTE[53:28]
  const uint64_t ppn2 = (pa >> 2) & (((1ULL << 26) - 1) << 28);
  early_pgtbl[VPN2(va)] = ppn2 | PTE_A | PTE_D | PTE_V | PTE_R | PTE_W | PTE_X;

  // uncomment to enable identity mapping
  // early_pgtbl[VPN2(pa)] = ppn2 | PTE_A | PTE_D | PTE_V | PTE_R | PTE_W | PTE_X;
}

void setup_vm_final(void) {
  memset(swapper_pg_dir, 0, PGSIZE);

  // No OpenSBI mapping required

  // map .text X|-|R|V
  create_mapping(swapper_pg_dir, (uint64_t)_stext, VA2PA(_stext), _srodata - _stext, PTE_X | PTE_R);

  // map .rodata -|-|R|V
  create_mapping(swapper_pg_dir, (uint64_t)_srodata, VA2PA(_srodata), _sdata - _srodata, PTE_R);

  // map other memory -|W|R|V
  create_mapping(swapper_pg_dir, (uint64_t)_sdata, VA2PA(_sdata), PHY_SIZE - (_sdata - _stext), PTE_W | PTE_R);

  // use swapper_pg_dir as kernel pagetable
  uint64_t satp = (VA2PA(swapper_pg_dir) >> 12) | (8ULL << 60);
  csr_write(satp, satp);

  // flush TLB
  asm volatile("sfence.vma");

  // flush icache
  asm volatile("fence.i");

  sys_puts("...setup_vm_final done!");
}

/* 创建多级页表映射关系 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
  /*
  pgtbl 为根页表的基地址
  va, pa 为需要映射的虚拟地址、物理地址
  sz 为映射的大小
  perm 为映射的读写权限

  将给定的一段虚拟内存映射到物理内存上
  物理内存需要分页
  创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
  可以使用 V bit 来判断页表项是否存在
  */

  printk("pgtbl = %p: map [0x%lx, 0x%lx) -> [0x%lx, 0x%lx), perm = 0x%lx, size = %lu\n", (void *)VA2PA(pgtbl), va, va + sz, pa, pa + sz, perm, sz);

  for (const uint64_t va_end = va + sz; va < va_end; pa += PGSIZE, va += PGSIZE) {
    // level 2 page table
    uint64_t *table = pgtbl;
    uint64_t pte = table[VPN2(va)];

    // VPN2
    if (!(pte & PTE_V)) {
      // allocate a new page table
      uint64_t new_table = alloc_page();
      memset((void *)new_table, 0, PGSIZE);
      // RWX = 0, PPN: [55:12] => [53:10]
      // [63:54] are reserved
      // maps to level 1 page table
      pte = ((VA2PA(new_table) >> 12) << 10) | PTE_V;
      table[VPN2(va)] = pte;
    }

    // VPN1
    // get level 1 page table
    table = (uint64_t *)PA2VA((pte >> 10) << 12);
    pte = table[VPN1(va)];

    if (!(pte & PTE_V)) {
      // allocate a new page table
      uint64_t new_table = alloc_page();
      memset((void *)new_table, 0, PGSIZE);
      // RWX = 0, PPN: [55:12] => [53:10]
      // [63:54] are reserved
      // maps to level 0 page table
      pte = ((VA2PA(new_table) >> 12) << 10) | PTE_V;
      table[VPN1(va)] = pte;
    }

    // VPN0
    // get level 0 page table
    // maps to physical page
    table = (uint64_t *)PA2VA((pte >> 10) << 12);
    pte = ((pa >> 12) << 10) | perm | PTE_A | PTE_D | PTE_V;
    table[VPN0(va)] = pte;
  }
}
