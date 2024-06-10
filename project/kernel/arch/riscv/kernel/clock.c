// clock.c

#include "sbi.h"
#include "clock.h"
unsigned long TIMECLOCK = 0x30000;

unsigned long get_cycles() {
    unsigned long time;
    asm volatile (
        "rdtime %[time]"
        : [time] "=r" (time)
        : : "memory"
    );
    return time;
}

void clock_set_next_event() {
    unsigned long next_time = get_cycles() + TIMECLOCK;
    sbi_set_timer(next_time);
} 