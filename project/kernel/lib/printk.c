#include "printk.h"
#include "sbi.h"
#include "stdbool.h"

#ifndef max
#define max(a, b)           \
  ({                        \
    __typeof__(a) _a = (a); \
    __typeof__(b) _b = (b); \
    _a > _b ? _a : _b;      \
  })
#endif

struct fmt_flags {
  bool in_format;
  bool longflag;
  bool sharpflag;
  bool zeroflag;
  bool spaceflag;
  bool sign;
  int width;
  int prec;
};

void putchar(char c) {
  sbi_ecall(SBI_PUTCHAR, 0, c, 0, 0, 0, 0, 0);
}

int isspace(int c) {
  return c == ' ' || (c >= '\t' && c <= '\r');
}

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
  long ret = 0;
  bool neg = false;
  const char *p = nptr;

  while (isspace(*p)) {
    p++;
  }

  if (*p == '-') {
    neg = true;
    p++;
  } else if (*p == '+') {
    p++;
  }

  if (base == 0) {
    if (*p == '0') {
      p++;
      if (*p == 'x' || *p == 'X') {
        base = 16;
        p++;
      } else {
        base = 8;
      }
    } else {
      base = 10;
    }
  }

  while (1) {
    int digit;
    if (*p >= '0' && *p <= '9') {
      digit = *p - '0';
    } else if (*p >= 'a' && *p <= 'z') {
      digit = *p - ('a' - 10);
    } else if (*p >= 'A' && *p <= 'Z') {
      digit = *p - ('A' - 10);
    } else {
      break;
    }

    if (digit >= base) {
      break;
    }

    ret = ret * base + digit;
    p++;
  }

  if (endptr) {
    *endptr = (char *)p;
  }

  return neg ? -ret : ret;
}

// puts without newline
int puts_wo_nl(void (*putch)(char), const char *s) {
  if (!s) {
    return puts_wo_nl(putch, "(null)");
  }
  const char *p = s;
  while (*p) {
    putch(*p++);
  }
  return p - s;
}

int puts(const char *s) {
  puts_wo_nl(putchar, s);
  putchar('\n');
  return 0;
}

static int print_dec_int(void (*putch)(char), unsigned long num, bool is_signed, struct fmt_flags *flags) {
  if (is_signed && ((long)num == -(long)num)) {
    // special case for 0x8000000000000000
    return puts_wo_nl(putch, "-9223372036854775808");
  }

  if (flags->prec == 0 && num == 0) {
    return 0;
  }

  bool neg = false;

  if (is_signed && (long)num < 0) {
    neg = true;
    num = -num;
  }

  char buf[20];
  int decdigits = 0;

  bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);

  do {
    buf[decdigits++] = num % 10 + '0';
    num /= 10;
  } while (num);

  if (flags->prec == -1 && flags->zeroflag) {
    flags->prec = flags->width;
  }

  int written = 0;

  for (int i = flags->width - max(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    putch(' ');
    ++written;
  }

  if (has_sign_char) {
    putch(neg ? '-' : flags->sign ? '+' : ' ');
    ++written;
  }

  for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    putch('0');
    ++written;
  }

  for (int i = decdigits - 1; i >= 0; i--) {
    putch(buf[i]);
    ++written;
  }

  return written;
}

static int vprintfmt(void (*putch)(char), const char *fmt, va_list vl) {
  struct fmt_flags flags = {false, false, false, false, false, false, 0, 0};

  static const char lowerxdigits[] = "0123456789abcdef";
  static const char upperxdigits[] = "0123456789ABCDEF";

  int written = 0;

  for (; *fmt; fmt++) {
    if (flags.in_format) {
      if (*fmt == '#') {
        flags.sharpflag = true;
      } else if (*fmt == '0') {
        flags.zeroflag = true;
      } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
        // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
        flags.longflag = true;
      } else if (*fmt == '+') {
        flags.sign = true;
      } else if (*fmt == ' ') {
        flags.spaceflag = true;
      } else if (*fmt >= '1' && *fmt <= '9') {
        flags.width = strtol(fmt, (char **)&fmt, 10);
        fmt--;
      } else if (*fmt == '.') {
        flags.prec = strtol(fmt + 1, (char **)&fmt, 10);
        fmt--;
      } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
        bool is_long = *fmt == 'p' || flags.longflag;

        unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);

        if (flags.prec == 0 && num == 0 && *fmt != 'p') {
          flags.in_format = false;
          continue;
        }

        // 0x prefix for pointers, or, if # flag is set and non-zero
        bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);

        int hexdigits = 0;
        const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
        char buf[2 * sizeof(unsigned long)];

        do {
          buf[hexdigits++] = xdigits[num & 0xf];
          num >>= 4;
        } while (num);

        if (flags.prec == -1 && flags.zeroflag) {
          flags.prec = flags.width - 2 * prefix;
        }

        for (int i = flags.width - 2 * prefix - max(hexdigits, flags.prec); i > 0; i--) {
          putch(' ');
          ++written;
        }

        if (prefix) {
          putch('0');
          putch(*fmt == 'X' ? 'X' : 'x');
          written += 2;
        }

        for (int i = hexdigits; i < flags.prec; i++) {
          putch('0');
          ++written;
        }

        for (int i = hexdigits - 1; i >= 0; i--) {
          putch(buf[i]);
          ++written;
        }

        flags.in_format = false;
      } else if (*fmt == 'd') {
        long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);

        written += print_dec_int(putch, num, true, &flags);
        flags.in_format = false;
      } else if (*fmt == 'u') {
        unsigned long num = flags.longflag ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);

        written += print_dec_int(putch, num, false, &flags);
        flags.in_format = false;
      } else if (*fmt == 'n') {
        if (flags.longflag) {
          long *n = va_arg(vl, long *);
          *n = written;
        } else {
          int *n = va_arg(vl, int *);
          *n = written;
        }
        flags.in_format = false;
      } else if (*fmt == 's') {
        const char *s = va_arg(vl, const char *);
        written += puts_wo_nl(putch, s);
        flags.in_format = false;
      } else if (*fmt == 'c') {
        int ch = va_arg(vl, int);
        putch(ch);
        ++written;
        flags.in_format = false;
      } else if (*fmt == '%') {
        putch('%');
        ++written;
        flags.in_format = false;
      } else {
        putch(*fmt);
        ++written;
        flags.in_format = false;
      }
    } else if (*fmt == '%') {
      flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    } else {
      putch(*fmt);
      ++written;
    }
  }

  return written;
}

int printk(const char *s, ...) {
  int res = 0;
  va_list vl;
  va_start(vl, s);
  res = vprintfmt(putchar, s, vl);
  va_end(vl);
  return res;
}

