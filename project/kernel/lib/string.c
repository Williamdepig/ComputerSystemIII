#include "string.h"
#include "stdint.h"

void *memset(void *dst, int c, size_t n) {
  uint8_t *cdst = (uint8_t *)dst;
  while (n--) {
    *cdst++ = c;
  }
  return dst;
}

void *memcpy(void *dst, const void *src, size_t n) {
  const uint8_t *csrc = (const uint8_t *)src;
  uint8_t *cdst = (uint8_t *)dst;
  while (n--) {
    *cdst++ = *csrc++;
  }
  return dst;
}

char *strcpy(char *dst, const char *src) {
  char *ret = dst;
  while ((*dst++ = *src++))
    ;
  return ret;
}

size_t strlen(const char *s) {
  size_t len = 0;
  while (*s++) {
    len++;
  }
  return len;
}

int strcmp(const char *s1, const char *s2) {
  while (*s1 && *s2 && *s1 == *s2) {
    s1++;
    s2++;
  }
  return *s1 - *s2;
}

int strcasecmp(const char *s1, const char *s2) {
  while (*s1 && *s2 && (*s1 | 0x20) == (*s2 | 0x20)) {
    s1++;
    s2++;
  }
  return *s1 - *s2;
}
