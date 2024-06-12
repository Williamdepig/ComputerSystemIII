#include "syscall.h"
#include "stddef.h"
#include "stdint.h"

// using a macro to circumvent type checking
#define __ecall(nr, arg0, arg1, arg2, arg3, arg4, arg5, arg6)                                     \
  ({                                                                                              \
    register uint64_t _a7 asm("a7") = (uint64_t)(nr);                                             \
    register uint64_t _a0 asm("a0") = (uint64_t)(arg0);                                           \
    register uint64_t _a1 asm("a1") = (uint64_t)(arg1);                                           \
    register uint64_t _a2 asm("a2") = (uint64_t)(arg2);                                           \
    register uint64_t _a3 asm("a3") = (uint64_t)(arg3);                                           \
    register uint64_t _a4 asm("a4") = (uint64_t)(arg4);                                           \
    register uint64_t _a5 asm("a5") = (uint64_t)(arg5);                                           \
    register uint64_t _a6 asm("a6") = (uint64_t)(arg6);                                           \
    asm volatile("ecall"                                                                          \
                 : "+r"(_a0)                                                                      \
                 : "r"(_a7), "r"(_a0), "r"(_a1), "r"(_a2), "r"(_a3), "r"(_a4), "r"(_a5), "r"(_a6) \
                 : "memory");                                                                     \
    _a0;                                                                                          \
  })

ssize_t read(int fd, void *buf, size_t count) {
  return __ecall(SYS_READ, fd, buf, count, 0, 0, 0, 0);
}

ssize_t write(int fd, const void *buf, size_t count) {
  return __ecall(SYS_WRITE, fd, buf, count, 0, 0, 0, 0);
}

void exit(int status) {
  __ecall(SYS_EXIT, status, 0, 0, 0, 0, 0, 0);
  __builtin_unreachable();
}

int sched_yield(void) {
  return __ecall(SYS_SCHED_YIELD, 0, 0, 0, 0, 0, 0, 0);
}

int kill(pid_t pid, int sig) {
  return __ecall(SYS_KILL, pid, sig, 0, 0, 0, 0, 0);
}

pid_t getpid(void) {
  return __ecall(SYS_GETPID, 0, 0, 0, 0, 0, 0, 0);
}

pid_t getppid(void) {
  return __ecall(SYS_GETPPID, 0, 0, 0, 0, 0, 0, 0);
}

pid_t fork(void) {
  return __ecall(SYS_CLONE, 0, 0, 0, 0, 0, 0, 0);
}

int execve(const char *pathname, char *const argv[], char *const envp[]) {
  return __ecall(SYS_EXECVE, pathname, argv, envp, 0, 0, 0, 0);
}
