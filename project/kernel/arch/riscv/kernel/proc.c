#include "types.h"
#include "proc.h"
#include "defs.h"
#include "string.h"
#include "kio.h"
#include "mm.h"
#include "vm.h"
#include "rand.h"
#include "unistd.h"

#define COUNTER_MULTIPLIER 0x1000

extern uint64_t swapper_pg_dir[];
extern uint8_t uapp_start[];
extern uint8_t uapp_end[];
extern uint8_t uapp2_start[];
extern uint8_t uapp2_end[];

static struct task_struct *idle;           // idle process
static struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此
struct task_struct *current;               // 指向当前运行线程的 `task_struct`

// static int *free_pid;
// static volatile int nr_tasks;

struct {
  pid_t free_pid;
  unsigned nr_tasks;
} *pm;

uint64_t get_cycles(void);
void __dummy(void);
void __switch_to(struct task_struct *prev, struct task_struct *next);
void __ret_from_fork(void);

static pid_t create_pid(void) {
  pm->nr_tasks++;
  return pm->free_pid++;
}

void task_init(void) {
  // 1. 调用 kalloc() 为 idle 分配一个物理页
  // 2. 设置 state 为 TASK_RUNNING;
  // 3. 由于 idle 不参与调度 可以将其 counter / priority 设置为 0
  // 4. 设置 idle 的 pid 为 0
  // 5. 将 current 和 task[0] 指向 idle

  pm = (void *)alloc_page();

  idle = (struct task_struct *)alloc_page();
  idle->state = TASK_RUNNING;
  idle->counter = 0;
  idle->priority = 0;
  idle->pid = create_pid();
  idle->ppid = 0;

  current = idle;
  task[0] = idle;

  // 1. 参考 idle 的设置, 为 task[1] ~ task[NR_TASKS - 1] 进行初始化
  // 2. 其中每个线程的 state 为 TASK_RUNNING, counter 为 0, priority 使用 rand() 来设置, pid
  // 为该线程在线程数组中的下标。
  // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 `thread_struct` 中的 `ra` 和 `sp`,
  // 4. 其中 `ra` 设置为 __dummy （见 4.3.2）的地址， `sp` 设置为 该线程申请的物理页的高地址

  for (int i = 1; i < 2; i++) {
    // allocate a new page for each task
    task[i] = (struct task_struct *)alloc_page();
    task[i]->state = TASK_RUNNING;
    task[i]->counter = 0;
    task[i]->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
    task[i]->pid = create_pid();
    task[i]->ppid = 0;

    // set `ra` to __dummy and `sp` to the high address of the page
    task[i]->thread.ra = (uint64_t)__dummy;
    task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;

    task[i]->thread.sepc = USER_START;
    task[i]->thread.sscratch = USER_END;
    task[i]->thread.stval = 0;
    task[i]->thread.scause = 0;

    // sstatus[18] : SUM  = 1 -> S-mode can access U-mode memory
    // sstatus[8]  : SPP  = 0 -> `sret` returns to U-mode
    // sstatus[5]  : SPIE = 1 -> Enable supervisor interrupts after `sret`
    task[i]->thread.sstatus = (1 << 18) | (0 << 8) | (1 << 5);

    // create a new page table for each task
    task[i]->pgd = (pagetable_t)alloc_page();

    // copy swapper_pg_dir to pgd
    memcpy(task[i]->pgd, swapper_pg_dir, PGSIZE);

    task[i]->mm = (struct mm_struct *)alloc_page();
    do_mmap(task[i]->mm, USER_START, uapp_end - uapp_start, VM_READ | VM_WRITE | VM_EXEC);
    do_mmap(task[i]->mm, USER_END - 2 * PGSIZE, 2 * PGSIZE, VM_READ | VM_WRITE);
  }

  sys_puts("...proc_init done!");
}

void do_timer(void) {
  /* 1. 将当前进程的counter--，如果结果大于零则直接返回*/
  /* 2. 否则进行进程调度 */
  // printk("current [PID = %u, PRIORITY = %d, COUNTER = %d]\n", current->pid, current->priority, current->counter);

  if (current == idle || current->counter == 0) {
    // printk("do_timer: schedule [PID = %d]\n", current->pid);
    schedule();
  } else {
    current->counter--;
  }
}

void schedule(void) {
  if (pm->nr_tasks < 2) {
    // no task to schedule
    return;
  }

  struct task_struct *min_counter = NULL;

  // kill zombie process
  for (unsigned i = 1; i < pm->nr_tasks; i++) {
    if (task[i]->state == TASK_ZOMBIE) {
      printk("\e[31mKILL [PID = %u]\e[0m\n", task[i]->pid);
      free_mm(task[i]->mm);
      free_pages((uint64_t)task[i]->pgd); // TODO: free all pages
      free_pages((uint64_t)task[i]);
      task[i--] = task[--pm->nr_tasks];
    }
  }

  // find first task with counter > 0
  unsigned i = 1;
  for (; i < pm->nr_tasks; i++) {
    if (task[i]->counter > 0) {
      min_counter = task[i];
      break;
    }
  }

  if (min_counter == NULL) {
    // all tasks are counter == 0
    min_counter = task[1];
    for (unsigned i = 1; i < pm->nr_tasks; i++) {
      task[i]->counter = COUNTER_MULTIPLIER * task[i]->priority;
      printk("\e[32mSET [PID = %u, PRIORITY = %lu, COUNTER = %lu]\e[0m\n", task[i]->pid, task[i]->priority,
             task[i]->counter);

      if (task[i]->counter > 0 && task[i]->counter < min_counter->counter) {
        min_counter = task[i];
      }
    }
  } else {
    // continue to find the task with min counter
    for (; i < pm->nr_tasks; i++) {
      if (task[i]->counter > 0 && task[i]->counter < min_counter->counter) {
        min_counter = task[i];
      }
    }
  }

  if (min_counter != current) {
    switch_to(min_counter);
  }
}

void switch_to(struct task_struct *next) {
  printk("\e[33mswitch to [PID = %u @ \e[36m%p\e[33m, PRIORITY = %lu, COUNTER = %lu], satp = %lx\e[0m\n", next->pid,
         next, next->priority, next->counter, csr_read(satp));
  struct task_struct *prev = current;
  current = next;
  __switch_to(prev, next);
}

struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr) {
  struct vm_area_struct *vma = mm->mmap;

  while (vma) {
    if (addr >= vma->vm_start && addr < vma->vm_end) {
      return vma;
    }
    vma = vma->vm_next;
  }

  return NULL;
}

uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t length, int flags) {
  // create a new vma
  struct vm_area_struct *new_vma = (struct vm_area_struct *)alloc_page();

  // check for overlap
  for (uint64_t i = addr; i < addr + length; i += PGSIZE) {
    if (find_vma(mm, i) != NULL) {
      addr = get_unmapped_area(mm, length);
      break;
    }
  }

  new_vma->vm_mm = mm;
  new_vma->vm_start = addr;
  new_vma->vm_end = addr + length;
  new_vma->vm_flags = flags;
  new_vma->vm_prev = NULL;
  new_vma->vm_next = NULL;

  printk("do_mmap: [ADDR = %lx, LENGTH = %lx, PROT = %x]\n", addr, length, flags);

  struct vm_area_struct *vma = mm->mmap;

  if (!vma) {
    mm->mmap = new_vma;
  } else {
    while (vma->vm_next && vma->vm_next->vm_start < addr) {
      vma = vma->vm_next;
    }

    if (vma->vm_next) {
      new_vma->vm_next = vma->vm_next;
      new_vma->vm_prev = vma;
      vma->vm_next->vm_prev = new_vma;
      vma->vm_next = new_vma;
    } else {
      vma->vm_next = new_vma;
      new_vma->vm_prev = vma;
    }
  }

  return addr;
}

void free_vma(struct mm_struct *mm, struct vm_area_struct *vma) {
  if (vma->vm_prev) {
    vma->vm_prev->vm_next = vma->vm_next;
  } else {
    mm->mmap = vma->vm_next;
  }

  if (vma->vm_next) {
    vma->vm_next->vm_prev = vma->vm_prev;
  }

  free_pages((uint64_t)vma);
}

void free_mm(struct mm_struct *mm) {
  struct vm_area_struct *vma = mm->mmap;
  while (vma) {
    struct vm_area_struct *next = vma->vm_next;
    free_vma(mm, vma);
    vma = next;
  }

  free_pages((uint64_t)mm);
}

uint64_t get_unmapped_area(struct mm_struct *mm, uint64_t length) {
  // find the first unmapped area with enough length

  for (uint64_t start = USER_START;; start += PGSIZE) {
    int found = 1;
    for (uint64_t i = 0; i < length; i += PGSIZE) {
      if (find_vma(mm, start + i) != NULL) {
        found = 0;
        start += i;
        break;
      }
    }

    if (found) {
      return start;
    }
  }
}

int do_fork(struct pt_regs *regs) {
  if (pm->nr_tasks >= NR_TASKS) {
    printk("\e[31mdo_fork: task limit reached\e[0m\n");
    return -1;
  }

  struct task_struct *tsk = (struct task_struct *)alloc_page();
  tsk->state = TASK_RUNNING;
  tsk->counter = 0;
  tsk->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
  tsk->pid = create_pid();

  printk("\e[45mdo_fork\e[0m: \e[32m%u -> %u\e[0m\n", current->pid, tsk->pid);

  tsk->thread.ra = (uint64_t)__ret_from_fork;
  tsk->thread.sp = (uint64_t)tsk + (regs->sp - (uint64_t)current);

  // copy registers
  struct pt_regs *new_regs = (struct pt_regs *)tsk->thread.sp;
  memcpy(new_regs, regs, sizeof(struct pt_regs));
  new_regs->a0 = 0;
  new_regs->sp = tsk->thread.sp;

  tsk->thread.sepc = regs->sepc;
  tsk->thread.sstatus = (current->thread.sstatus & ~(1 << 8)) | (1 << 5) | (1 << 18);
  tsk->thread.sscratch = csr_read(sscratch);
  tsk->thread.stval = 0;
  tsk->thread.scause = 0;

  struct vm_area_struct *vma = current->mm->mmap;
  tsk->mm = (struct mm_struct *)alloc_page();
  tsk->mm->mmap = NULL;

  tsk->pgd = (pagetable_t)alloc_page();
  memcpy(tsk->pgd, swapper_pg_dir, PGSIZE);

  while (vma) {
    do_mmap(tsk->mm, vma->vm_start, vma->vm_end - vma->vm_start, vma->vm_flags);

    uint64_t start_vm = PGROUNDDOWN(vma->vm_start);
    uint64_t end_vm = PGROUNDUP(vma->vm_end);
    for (uint64_t va = start_vm; va < end_vm; va += PGSIZE) {
      uint64_t pte = walk_page_table(current->pgd, va);
      if (!pte) {
        continue;
      }
      uint64_t pa = (pte >> 10) << 12;
      get_page(PA2VA(pa));
      uint64_t perm = pte & 0x3ff;
      perm &= ~PTE_W;
      perm |= PTE_S;
      create_mapping(current->pgd, va, pa, PGSIZE, perm);
      create_mapping(tsk->pgd, va, pa, PGSIZE, perm);
    }
    vma = vma->vm_next;
  }

  asm volatile("sfence.vma\n"
               "fence.i\n");

  task[pm->nr_tasks - 1] = tsk;
  return tsk->pid;
}

uint64_t walk_page_table(pagetable_t pgtbl, uint64_t va) {
  uint64_t pte = pgtbl[VPN2(va)];
  if (!(pte & PTE_V)) {
    return 0;
  }

  pgtbl = (pagetable_t)PA2VA((pte >> 10) << 12);
  pte = pgtbl[VPN1(va)];

  pgtbl = (pagetable_t)PA2VA((pte >> 10) << 12);
  pte = pgtbl[VPN0(va)];

  return pte;
}

void do_execve(struct pt_regs *regs) {
  /* Create a new process*/
  struct task_struct *tsk = (struct task_struct *)alloc_page();
  tsk->state = TASK_RUNNING;
  tsk->counter = current->counter;
  tsk->priority = current->priority;
  tsk->pid = current->pid;
  tsk->mm = (struct mm_struct *)alloc_page();

  printk("\e[32mexecve: %u\e[0m\n", current->pid);

  tsk->thread.ra = (uint64_t)__dummy;
  tsk->thread.sp = (uint64_t)tsk + PGSIZE;
  tsk->pgd = (pagetable_t)alloc_page();

  /* copy swapper_pg_dir to pgd */
  memcpy(tsk->pgd, swapper_pg_dir, PGSIZE);
  uint64_t addr_uapp = alloc_pages((uapp2_end - uapp2_start + PGSIZE - 1) / PGSIZE);

  /* copy user app to the new address */
  memcpy((void *)addr_uapp, uapp2_start, uapp2_end - uapp2_start);

  /* map the user app to the new address */
  create_mapping(tsk->pgd, USER_START, VA2PA(addr_uapp), uapp2_end - uapp2_start, PTE_R | PTE_W | PTE_X | PTE_U);
  create_mapping(tsk->pgd, USER_END - PGSIZE, VA2PA(alloc_page()) - PGSIZE, PGSIZE, PTE_R | PTE_W | PTE_U);
  do_mmap(tsk->mm, USER_START, uapp2_end - uapp2_start, VM_READ | VM_WRITE | VM_EXEC);
  do_mmap(tsk->mm, USER_END - 2 * PGSIZE, 2 * PGSIZE, VM_READ | VM_WRITE);

  /* Set up registers */
  struct pt_regs *new_regs = (struct pt_regs *)tsk->thread.sp;
  memcpy(new_regs, regs, sizeof(struct pt_regs));
  new_regs->a0 = 0;
  new_regs->sp = tsk->thread.sp;

  tsk->thread.sepc = regs->sepc;
  tsk->thread.sstatus = (csr_read(sstatus) & ~(1 << 8)) | (1 << 5) | (1 << 18);
  tsk->thread.sscratch = USER_END;
  tsk->thread.stval = 0;
  tsk->thread.scause = 0;

  printk("uapp_start = %#lx, uapp_end = %#lx\n", VA2PA(uapp_start), VA2PA(uapp_end));
  printk("uapp2_start = %#lx, uapp2_end = %#lx\n", VA2PA(uapp2_start), VA2PA(uapp2_end));

  asm volatile("sfence.vma\n"
               "fence.i\n");

  task[current->pid] = tsk;
  task[pm->nr_tasks++] = current;
  current->pid = 99;
  current->state = TASK_ZOMBIE;
  schedule();
};

void do_kill(pid_t pid, int sig) {
  (void)sig;
  for (unsigned i = 1; i < pm->nr_tasks; i++) {
    if (task[i]->pid == pid) {
      task[i]->state = TASK_ZOMBIE;
      return schedule();
    }
  }
}
