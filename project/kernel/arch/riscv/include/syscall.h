#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include "types.h"
#include "unistd.h"
#include "proc.h"

int sys_ni_syscall(void);

ssize_t sys_read(unsigned fd, void *buf, size_t count);
ssize_t sys_write(unsigned fd, const void *buf, size_t count);

void sys_exit(int status);

void sys_sched_yield(void);

int sys_kill(pid_t pid, int sig);

pid_t sys_getpid(void);
pid_t sys_getppid(void);

// simplified clone(2)
int sys_clone(struct pt_regs *regs);

// simplified execve(2)
int sys_execve(struct pt_regs *regs);

#endif
