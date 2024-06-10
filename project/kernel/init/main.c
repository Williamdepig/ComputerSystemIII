#include "printk.h"
#include "mm.h"
#include "proc.h"

extern void test();
extern char _stext[];
extern char _srodata[];
int start_kernel() {
    // printk("%d ZJU Computer System II\n", 2023);
    printk("%dSystemIII\n", 2024);
    // printk("_stext = %x\n", *_stext);       // 读
    // printk("_srodata = %x\n", *_srodata);
    // *_stext = 0;                            // 写
    // *_srodata = 0;
    // printk("_stext = %x\n", *_stext);
    // printk("_srodata = %x\n", *_srodata);
    test(); // DO NOT DELETE !!!
	return 0;
}
