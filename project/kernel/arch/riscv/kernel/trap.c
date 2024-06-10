// trap.c 
#include "clock.h"
#include "printk.h"
#include "proc.h"
#include "sbi.h"
#include "defs.h"
// unsigned long TIMECLOCK = 0x1000000;
void trap_handler(unsigned long scause, unsigned long sepc) {
    if ((scause >> 63 == 1) && (scause & 0x7FFFFFFFFFFFFFFF) == 5) {
        // printk("[S] Supervisor Mode Timer Interrupt\n");
        // printk("[S]Timer Interrupt\n");
        // sbi_ecall(0x00, 0, TIMECLOCK, 0, 0, 0, 0, 0);
        clock_set_next_event();
        do_timer();
        return;
    }
    Log("scause: %lx, sepc: %lx\n", scause, sepc);
}
