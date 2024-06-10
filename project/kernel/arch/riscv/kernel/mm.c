#include "defs.h"
#include "string.h"
#include "mm.h"

#include "printk.h"

extern char _ekernel[];

struct {
    struct run *freelist;
} kmem;

uint64 kalloc() {
    struct run *r;

    r = kmem.freelist;

    if(r != NULL){
        kmem.freelist = r->next;
    }else{
        printk("kalloc: out of memory\n");
        while (1);
    }
    // memset((void *)r, 0x0, PGSIZE);
    // 为了加快仿真速度，可以不执行清零步骤
    return (uint64) r;
}

void kfree(uint64 addr) {
    struct run *r;

    // PGSIZE align 
    addr = addr & ~(PGSIZE - 1);

    // memset((void *)addr, 0x0, (uint64)PGSIZE);

    r = (struct run *)addr;
    r->next = kmem.freelist;
    kmem.freelist = r;

    return ;
}

void kfreerange(char *start, char *end) {
    char *addr = (char *)PGROUNDUP((uint64)start);
    for (; (uint64)(addr) + PGSIZE <= (uint64)end; addr += PGSIZE) {
        kfree((uint64)addr);
    }
}

void mm_init(void) {
    // kfreerange(_ekernel, (char *)PHY_END);
    // printk("...mm_init done!\n");
    kfreerange(_ekernel, (char *)(PHY_END+PA2VA_OFFSET));
    Log("...mm_init done!");
    return;
}
