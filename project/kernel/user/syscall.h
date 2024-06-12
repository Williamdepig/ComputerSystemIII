#ifndef __SYSCALL_H__
#define __SYSCALL_H__

// userland syscall.h

#include "unistd.h"
#include "stddef.h"

ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);

void exit(int status) __attribute__((noreturn));

int sched_yield(void);

int kill(pid_t pid, int sig);

pid_t getpid(void);
pid_t getppid(void);

pid_t fork(void);
int execve(const char *pathname, char *const argv[], char *const envp[]);

#endif
