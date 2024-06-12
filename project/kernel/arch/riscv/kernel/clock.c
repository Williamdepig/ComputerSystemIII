#include "sbi.h"
#include "kio.h"

static const uint64_t TIMECLOCK = 0x400;

uint64_t get_cycles(void) {
  uint64_t cycles;
  asm volatile("rdtime %0" : "=r"(cycles)::"memory");
  return cycles;
}

void clock_set_next_event(void) {
  sbi_set_timer(get_cycles() + TIMECLOCK);
}
