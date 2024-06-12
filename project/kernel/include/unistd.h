#ifndef __UNISTD_H__
#define __UNISTD_H__

// for now, this file defines syscall numbers

#define SYS_NI_SYSCALL 42
#define SYS_READ 63
#define SYS_WRITE 64
#define SYS_EXIT 93
#define SYS_SCHED_YIELD 124
#define SYS_KILL 129
#define SYS_GETPID 172
#define SYS_GETPPID 173
#define SYS_CLONE 220
#define SYS_EXECVE 221

typedef int pid_t;
typedef long ssize_t;

#endif
