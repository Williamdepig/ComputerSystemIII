#include "stdio.h"
#include "stdarg.h"
#include "syscall.h"
#include "stdbool.h"

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl);

struct FILE {
  unsigned fd;
  int closed;

  char rdbuf[STRUCT_FILE_BUFSIZ];
  int rdbuf_len;
  int rdbuf_rdpos;

  char wrbuf[STRUCT_FILE_BUFSIZ];
  int wrbuf_wrpos;

  int (*putch)(int c, struct FILE *stream);
  int (*getch)(struct FILE *stream);
};

static struct FILE __io[3];

struct FILE *stdin = &__io[0];
struct FILE *stdout = &__io[1];
struct FILE *stderr = &__io[2];

static void setup_stdio(struct FILE *stream, int fd, int (*putch)(int, struct FILE *), int (*getch)(struct FILE *)) {
  stream->fd = fd;
  stream->closed = 0;
  stream->rdbuf_len = 0;
  stream->rdbuf_rdpos = 0;
  stream->wrbuf_wrpos = 0;
  stream->putch = putch;
  stream->getch = getch;
}

int fputc(int c, struct FILE *stream) {
  return stream->putch(c, stream);
}

int putchar(int c) {
  return fputc(c, stdout);
}

static int __putch_to_internal_buffer(int c, struct FILE *stream) {
  c = (char)c;
  stream->wrbuf[stream->wrbuf_wrpos++] = c;

  if (c == '\n' || stream->wrbuf_wrpos == STRUCT_FILE_BUFSIZ) {
    write(stream->fd, stream->wrbuf, stream->wrbuf_wrpos);
    stream->wrbuf_wrpos = 0;
  }

  return c;
}

static int __getch_from_internal_buffer(struct FILE *stream) {
  if (stream->closed) {
    return EOF;
  }

  if (stream->rdbuf_rdpos == stream->rdbuf_len) {
    stream->rdbuf_len = read(stream->fd, stream->rdbuf, STRUCT_FILE_BUFSIZ);
    stream->rdbuf_rdpos = 0;
  }

  int c = stream->rdbuf[stream->rdbuf_rdpos++];

  if (c == 0x04) {
    // ^D
    stream->closed = 1;
    c = EOF;
  }

  return c;
}

int fputs(const char *s, struct FILE *stream) {
  while (*s) {
    fputc(*s++, stream);
  }
  return 0;
}

int puts(const char *s) {
  while (*s) {
    putchar(*s++);
  }
  putchar('\n');
  return 0;
}

int vfprintf(struct FILE *stream, const char *format, va_list ap) {
  (void)stream;
  // tail = 0;
  int res = vprintfmt(putchar, format, ap);
  return res;
}

int vprintf(const char *format, va_list ap) {
  return vfprintf(stdout, format, ap);
}

int fprintf(struct FILE *stream, const char *format, ...) {
  va_list vl;
  va_start(vl, format);
  int res = vfprintf(stream, format, vl);
  va_end(vl);
  return res;
}

int printf(const char *format, ...) {
  va_list vl;
  va_start(vl, format);
  int res = vprintf(format, vl);
  va_end(vl);
  return res;
}

static int __dummy_putch(int c, struct FILE *stream) {
  (void)c;
  (void)stream;
  return EOF;
}

static int __dummy_getch(struct FILE *stream) {
  (void)stream;
  return EOF;
}

int fgetc(struct FILE *stream) {
  return stream->getch(stream);
}

int getchar(void) {
  return fgetc(stdin);
}

int fgets(char *s, int size, struct FILE *stream) {
  int i = 0;
  while (i < size - 1) {
    int c = fgetc(stream);
    if (c == EOF) {
      break;
    }
    s[i++] = c;
    if (c == '\r') {
      c = '\n';
    }
    if (c == '\n') {
      break;
    }
  }
  s[i] = '\0';
  return i;
}

void __setup_uapp(void) {
  setup_stdio(stdin, 0, __dummy_putch, __getch_from_internal_buffer);
  setup_stdio(stdout, 1, __putch_to_internal_buffer, __dummy_getch);
  setup_stdio(stderr, 2, __putch_to_internal_buffer, __dummy_getch);
}
