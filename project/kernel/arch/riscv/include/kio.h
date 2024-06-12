#ifndef __KIO_H__
#define __KIO_H__

// kernel i/o functionality

#include "stddef.h"

int sys_puts(const char *s);

int printk(const char *, ...) __attribute__((format(printf, 1, 2)));

#endif
