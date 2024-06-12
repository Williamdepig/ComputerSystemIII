#ifndef __STDDEF_H__
#define __STDDEF_H__

typedef __PTRDIFF_TYPE__ ptrdiff_t;
typedef __SIZE_TYPE__ size_t;
typedef __WCHAR_TYPE__ wchar_t;

#define NULL ((void *)0)
#define offsetof(type, member) __builtin_offsetof(type, member)

#define likely(x) __builtin_expect(!!(x), 1)
#define unlikely(x) __builtin_expect(!!(x), 0)

#define STDIN_FILENO 0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#endif
