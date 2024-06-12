#ifndef __VM_H__
#define __VM_H__

#include "types.h"

// Virtual Page Number
#define VPN0(va) (((uint64_t)(va) >> 12) & 0x1ff)
#define VPN1(va) (((uint64_t)(va) >> 21) & 0x1ff)
#define VPN2(va) (((uint64_t)(va) >> 30) & 0x1ff)

// Page Table Entry flags
#define PTE_V 0x001
#define PTE_R 0x002
#define PTE_W 0x004
#define PTE_X 0x008
#define PTE_U 0x010
#define PTE_G 0x020
#define PTE_A 0x040
#define PTE_D 0x080

// RSW: PTE[9:8]: Reserved for Software
#define PTE_S 0x100 // shared

#define csr_read(csr)                                     \
  ({                                                      \
    uint64_t __v;                                         \
    asm volatile("csrr %0, " #csr : "=r"(__v)::"memory"); \
    __v;                                                  \
  })
#define csr_write(csr, val) ({ asm volatile("csrw " #csr ", %0" ::"r"(val) : "memory"); })

void setup_vm(void);
void setup_vm_final(void);
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm);

#endif
