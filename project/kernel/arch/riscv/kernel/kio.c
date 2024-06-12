#include "stdarg.h"
#include "kio.h"
#include "sbi.h"
#include "mm.h"
#include "ctype.h"
#include "stdbool.h"

static int sys_putchar(int c) {
  sbi_debug_console_write_byte(c);
  return (char)c;
}

int sys_puts(const char *s) {
  while (*s) {
    sys_putchar(*s++);
  }
  sys_putchar('\n');
  return 0;
}

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl);

int printk(const char *s, ...) {
  int res = 0;
  va_list vl;
  va_start(vl, s);
  res = vprintfmt(sys_putchar, s, vl);
  va_end(vl);
  return res;
}
