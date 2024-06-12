#ifndef __PROC_H__
#define __PROC_H__

#include "vm.h"
#include "defs.h"
#include "types.h"
#include "stddef.h" // offsetof
#include "unistd.h"

#define NR_TASKS (1 + 9) // 用于控制 最大线程数量 （idle 线程 + 3 内核线程）

#define TASK_RUNNING 0
#define TASK_READY 1
#define TASK_ZOMBIE 2

#define PRIORITY_MIN 1
#define PRIORITY_MAX 8

/* vm_area_struct vm_flags */
#define VM_READ PTE_R
#define VM_WRITE PTE_W
#define VM_EXEC PTE_X

typedef uint64_t *pagetable_t;

struct vm_area_struct {
  struct mm_struct *vm_mm; /* The mm_struct we belong to. */
  uint64_t vm_start;       /* Our start address within vm_mm. */
  uint64_t vm_end;         /* The past-the-end address within vm_mm. */

  /* linked list of VM areas per task, sorted by address */
  struct vm_area_struct *vm_prev;
  struct vm_area_struct *vm_next;

  uint64_t vm_flags; /* Flags as listed above. */
};

struct mm_struct {
  struct vm_area_struct *mmap; /* list of VMAs */
};

struct pt_regs {
  union {
    uint64_t x[32];

    struct {
      uint64_t zero;
      uint64_t ra;
      uint64_t sp;
      uint64_t gp;
      uint64_t tp;
      uint64_t t0;
      uint64_t t1;
      uint64_t t2;
      uint64_t s0;
      uint64_t s1;
      uint64_t a0;
      uint64_t a1;
      uint64_t a2;
      uint64_t a3;
      uint64_t a4;
      uint64_t a5;
      uint64_t a6;
      uint64_t a7;
      uint64_t s2;
      uint64_t s3;
      uint64_t s4;
      uint64_t s5;
      uint64_t s6;
      uint64_t s7;
      uint64_t s8;
      uint64_t s9;
      uint64_t s10;
      uint64_t s11;
      uint64_t t3;
      uint64_t t4;
      uint64_t t5;
      uint64_t t6;
    };
  };
  uint64_t sepc;
};

_Static_assert(sizeof(struct pt_regs) == SIZEOF_PT_REGS, "pt_regs wrong size; fix in defs.h");

struct thread_struct {
  uint64_t ra;
  uint64_t sp;
  uint64_t s[12];

  uint64_t sepc;
  uint64_t sstatus;
  uint64_t sscratch;
  uint64_t stval;
  uint64_t scause;
};

struct task_struct {
  uint64_t state;
  volatile uint64_t counter;
  uint64_t priority;
  pid_t pid;
  pid_t ppid;

  volatile struct thread_struct thread;

  pagetable_t pgd;

  struct mm_struct *mm;
};

_Static_assert(offsetof(struct task_struct, thread) == OFFSETOF_TS_THREAD, "wrong offset; fix in defs.h");

/* 线程初始化 创建 NR_TASKS 个线程 */
void task_init(void);

/* 在时钟中断处理中被调用 用于判断是否需要进行调度 */
void do_timer(void);

/* 调度程序 选择出下一个运行的线程 */
void schedule(void);

/* 线程切换入口函数 */
void switch_to(struct task_struct *next);

// syscall entry
void syscall(struct pt_regs *regs);

/*
 * @mm          : current thread's mm_struct
 * @address     : the va to look up
 *
 * @return      : the VMA if found or NULL if not found
 */
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr);

/*
 * @mm     : current thread's mm_struct
 * @addr   : the suggested va to map
 * @length : memory size to map
 * @flags  : pte flags
 *
 * @return : start va
 */
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t length, int flags);

uint64_t get_unmapped_area(struct mm_struct *mm, uint64_t length);

uint64_t walk_page_table(pagetable_t pgtbl, uint64_t va);

void free_vma(struct mm_struct *mm, struct vm_area_struct *vma);

void free_mm(struct mm_struct *mm);

#endif
