#ifndef __CLOCK_H__
#define __CLOCK_H__

#include "types.h"

uint64_t get_cycles(void);

void clock_set_next_event(void);

#endif
