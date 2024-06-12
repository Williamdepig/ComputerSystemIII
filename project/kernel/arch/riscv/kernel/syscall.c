#include "errno.h"
#include "mm.h"
#include "kio.h"
#include "sbi.h"
#include "proc.h"
#include "syscall.h"

extern struct task_struct *current;

// Convert user virtual address to physical address
uint64_t UVA2PA(const void *uva) {
  uint64_t va = (uint64_t)uva;
  uint64_t pte = walk_page_table(current->pgd, va);
  uint64_t pa = (pte >> 10) << 12;
  return pa + va % PGSIZE;
}

void syscall(struct pt_regs *regs) {
  long ret = -1;
  switch (regs->a7) {
    default:
      printk("\e[33mUnimplemented syscall: %lu\e[0m\n", regs->a7);
      __attribute__((fallthrough));
    case SYS_NI_SYSCALL:
      ret = sys_ni_syscall();
      break;
    case SYS_READ:
      ret = sys_read(regs->a0, (void *)regs->a1, regs->a2);
      break;
    case SYS_WRITE:
      ret = sys_write(regs->a0, (const void *)regs->a1, regs->a2);
      break;
    case SYS_EXIT:
      sys_exit(regs->a0);
      ret = 0;
      break;
    case SYS_SCHED_YIELD:
      sys_sched_yield();
      ret = 0;
      break;
    case SYS_KILL:
      ret = sys_kill(regs->a0, regs->a1);
      break;
    case SYS_GETPID:
      ret = sys_getpid();
      break;
    case SYS_GETPPID:
      ret = sys_getppid();
      break;
    case SYS_CLONE:
      ret = sys_clone(regs);
      break;
    case SYS_EXECVE:
      ret = sys_execve(regs);
      break;
  }

  regs->a0 = ret;
}

int sys_ni_syscall(void) {
  return -ENOSYS;
}

ssize_t sys_read(unsigned fd, void *buf, size_t count) {
  if (fd != STDIN_FILENO) {
    printk("sys_read: unsupported file descriptor: %u\n", fd);
    return -1;
  }

  struct sbiret ret;

  do {
    ret = sbi_debug_console_read(count, UVA2PA(buf), 0);

    if (ret.error) {
      printk("Error reading from console: %ld\n", ret.error);
      return -1;
    }
  } while (ret.value == 0);

  return ret.value;
}

ssize_t sys_write(unsigned fd, const void *buf, size_t count) {
  if (fd != STDOUT_FILENO) {
    printk("sys_write: unsupported file descriptor: %u\n", fd);
    return -1;
  }

  struct sbiret ret = sbi_debug_console_write(count, UVA2PA(buf), 0);

  if (ret.error) {
    printk("Error writing to console: %ld\n", ret.error);
    return -1;
  }

  return ret.value;
}

void sys_exit(int status) {
  printk("\e[31m[S]\e[0m Process %u exited with status %d\n", current->pid, status);
  current->counter = 0;
  current->priority = 0;
  current->state = TASK_ZOMBIE;
  schedule();
}

void sys_sched_yield(void) {
  current->counter = 0;
  schedule();
}

int sys_kill(pid_t pid, int sig) {
  void do_kill(pid_t pid, int sig);
  do_kill(pid, sig);
  return 0;
}

pid_t sys_getpid(void) {
  return current->pid;
}

pid_t sys_getppid(void) {
  return current->ppid;
}

int sys_clone(struct pt_regs *regs) {
  int do_fork(struct pt_regs * regs);
  return do_fork(regs);
}

int sys_execve(struct pt_regs *regs) {
  void do_execve(struct pt_regs * regs);
  do_execve(regs);
  return 0;
}
