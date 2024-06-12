#ifndef __STDIO_H__
#define __STDIO_H__

#include "stddef.h"
#include "stdarg.h"

#ifndef STRUCT_FILE_BUFSIZ
#define STRUCT_FILE_BUFSIZ 4096
#endif

#define EOF (-1)

struct FILE;

extern struct FILE *stdin;
extern struct FILE *stdout;
extern struct FILE *stderr;

int printf(const char *, ...) __attribute__((format(printf, 1, 2)));
int fprintf(struct FILE *, const char *, ...) __attribute__((format(printf, 2, 3)));
int vprintf(const char *, va_list);
int vfprintf(struct FILE *, const char *, va_list);

int fputc(int c, struct FILE *stream);
#define putc(c, stream) fputc(c, stream)
int putchar(int c);

int fputs(const char *s, struct FILE *stream);
int puts(const char *s);

int fgetc(struct FILE *stream);
#define getc(stream) fgetc(stream)
int getchar(void);

int fgets(char *s, int size, struct FILE *stream);

#endif
