#ifndef __MM_H__
#define __MM_H__

#include "defs.h"
#include "types.h"

#define VA2PA(x) ((uint64_t)(x) - PA2VA_OFFSET)
#define PA2VA(x) ((uint64_t)(x) + PA2VA_OFFSET)
#define PFN2PHYS(x) (((uint64_t)(x) << 12) + PHY_START)
#define PHYS2PFN(x) (((uint64_t)(x) - PHY_START) >> 12)

void mm_init(void);

uint64_t alloc_pages(uint64_t);
uint64_t alloc_page(void);
void free_pages(uint64_t);

uint64_t get_page(uint64_t);
void put_page(uint64_t);

uint64_t kalloc(void) __attribute__((deprecated("use alloc_page instead")));
void kfree(uint64_t) __attribute__((deprecated("use free_pages instead")));

#endif
