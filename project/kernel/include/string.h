#ifndef __STRING_H__
#define __STRING_H__

#include "stdint.h"

void *memset(void *dst, int c, size_t len);
void *memcpy(void *dst, const void *src, size_t len);

char *strcpy(char *dst, const char *src);
size_t strlen(const char *s);
int strcmp(const char *s1, const char *s2);
int strcasecmp(const char *s1, const char *s2);

#endif
