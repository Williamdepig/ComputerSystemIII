#include "syscall.h"
#include "kio.h"
#include "string.h"
#include "clock.h"
#include "proc.h"
#include "sbi.h"
#include "vm.h"
#include "mm.h"

// convenient macro to generate scause
#define __SCAUSE(is_intr, code) ((uint64_t)(is_intr) << (8 * sizeof(uint64_t) - 1) | (code))

// User software interrupt
#define SCAUSE_USI __SCAUSE(1, 0)
// Supervisor software interrupt
#define SCAUSE_SSI __SCAUSE(1, 1)
// User timer interrupt
#define SCAUSE_UTI __SCAUSE(1, 4)
// Supervisor timer interrupt
#define SCAUSE_STI __SCAUSE(1, 5)
// User external interrupt
#define SCAUSE_UEI __SCAUSE(1, 8)
// Supervisor external interrupt
#define SCAUSE_SEI __SCAUSE(1, 9)

// Instruction address misaligned
#define SCAUSE_IADDR_MISALIGNED __SCAUSE(0, 0)
// Instruction access fault
#define SCAUSE_IADDR_FAULT __SCAUSE(0, 1)
// Illegal instruction
#define SCAUSE_II __SCAUSE(0, 2)
// Breakpoint
#define SCAUSE_BREAKPOINT __SCAUSE(0, 3)
// Load address misaligned
#define SCAUSE_LADDR_MISALIGNED __SCAUSE(0, 4)
// Load access fault
#define SCAUSE_LADDR_FAULT __SCAUSE(0, 5)
// Store/AMO address misaligned
#define SCAUSE_SADDR_MISALIGNED __SCAUSE(0, 6)
// Store/AMO access fault
#define SCAUSE_SADDR_FAULT __SCAUSE(0, 7)
// Environment call from U-mode
#define SCAUSE_ECALL_U __SCAUSE(0, 8)
// Environment call from S-mode
#define SCAUSE_ECALL_S __SCAUSE(0, 9)
// Instruction page fault
#define SCAUSE_IPF __SCAUSE(0, 12)
// Load page fault
#define SCAUSE_LPF __SCAUSE(0, 13)
// Store/AMO page fault
#define SCAUSE_SPF __SCAUSE(0, 15)

static const char *scause_str(uint64_t scause) {
  switch (scause) {
    case SCAUSE_USI:
      return "User software interrupt";
    case SCAUSE_SSI:
      return "Supervisor software interrupt";
    case SCAUSE_UTI:
      return "User timer interrupt";
    case SCAUSE_STI:
      return "Supervisor timer interrupt";
    case SCAUSE_UEI:
      return "User external interrupt";
    case SCAUSE_SEI:
      return "Supervisor external interrupt";
    case SCAUSE_IADDR_MISALIGNED:
      return "Instruction address misaligned";
    case SCAUSE_IADDR_FAULT:
      return "Instruction access fault";
    case SCAUSE_II:
      return "Illegal instruction";
    case SCAUSE_BREAKPOINT:
      return "Breakpoint";
    case SCAUSE_LADDR_MISALIGNED:
      return "Load address misaligned";
    case SCAUSE_LADDR_FAULT:
      return "Load access fault";
    case SCAUSE_SADDR_MISALIGNED:
      return "Store/AMO address misaligned";
    case SCAUSE_SADDR_FAULT:
      return "Store/AMO access fault";
    case SCAUSE_ECALL_U:
      return "Environment call from U-mode";
    case SCAUSE_ECALL_S:
      return "Environment call from S-mode";
    case SCAUSE_IPF:
      return "Instruction page fault";
    case SCAUSE_LPF:
      return "Load page fault";
    case SCAUSE_SPF:
      return "Store/AMO page fault";
    default:
      return "Unknown";
  }
}

int do_page_fault(struct pt_regs *regs) {
  extern struct task_struct *current;
  extern uint8_t uapp_start[];

  (void)regs;

  /*
   1. 通过 stval 获得访问出错的虚拟内存地址（Bad Address）
   2. 通过 scause 获得当前的 Page Fault 类型
   3. 通过 find_vm() 找到对应的 vm_area_struct
   4. 分配一个页，将这个页映射到对应的用户地址空间
   5. 通过 vm_area_struct 的 vm_flags 对当前的 Page Fault 类型进行检查并处理
       5.1 Instruction Page Fault      -> VM_EXEC
       5.2 Load Page Fault             -> VM_READ
       5.3 Store Page Fault            -> VM_WRITE
   6. 最后调用 create_mapping 对页表进行映射
  */

  const uint64_t stval = csr_read(stval);
  const uint64_t scause = csr_read(scause);

  struct vm_area_struct *vma = find_vma(current->mm, stval);
  // printk("do_page_fault: \e[33m%s\e[0m, sepc = 0x%lx, stval = 0x%lx\e[0m\n", scause_str(scause), regs->sepc, stval);

  if (!vma || (scause == SCAUSE_IPF && !(vma->vm_flags & VM_EXEC))
      || (scause == SCAUSE_LPF && !(vma->vm_flags & VM_READ))
      || (scause == SCAUSE_SPF && !(vma->vm_flags & VM_WRITE))) {
    printk("\e[41mBAD ACCESS\e[0m [PID = %u] vma = %p\n", current->pid, vma);
    return 0;
  }
  printk("vma = %p, ", vma);

  uint64_t va = PGROUNDDOWN(stval);
  uint64_t pa = VA2PA(alloc_page());
  uint64_t perm = vma->vm_flags | PTE_U | PTE_V | PTE_A | PTE_D;

  // handle shared page
  if (scause == SCAUSE_SPF) {
    uint64_t pte = walk_page_table(current->pgd, va);
    if (pte & PTE_S) {
      uint64_t shared_pa = (pte >> 10) << 12;
      memcpy((void *)PA2VA(pa), (void *)PA2VA(shared_pa), PGSIZE);
      printk("\e[45mSHARED PAGE\e[0m [PID = %u], copy %p to %p\n", current->pid, (void *)shared_pa, (void *)pa);
      put_page(PA2VA(shared_pa));
      create_mapping(current->pgd, va, pa, PGSIZE, perm);

      return 1;
    }
  }

  if (vma->vm_start == USER_START) {
    memcpy((void *)PA2VA(pa), (void *)(uapp_start - USER_START + va), PGSIZE);
  }
  create_mapping(current->pgd, va, pa, PGSIZE, perm);

  return 1;
}

void trap_handler(uint64_t scause, struct pt_regs *regs) {
  switch (scause) {
    case SCAUSE_STI:
      // Supervisor timer interrupt
      // printk("\e[45m[S]\e[0m %s\n", scause_str(scause));
      // sbi_debug_console_write_byte('.');
      do_timer();
      clock_set_next_event();
      break;
    case SCAUSE_ECALL_U:
      // Environment call from U-mode
      // printk("\e[45m[S]\e[0m \e[35m%s\e[0m; sepc = \e[36m0x%lx\e[0m\n", scause_str(scause), regs->sepc);
      regs->sepc += 4;
      syscall(regs);
      break;
    case SCAUSE_IPF:
    case SCAUSE_LPF:
    case SCAUSE_SPF:
      printk("\e[45m[S]\e[0m \e[35m%s\e[0m; sepc = \e[36m0x%lx\e[0m, stval = \e[36m0x%lx\e[0m\n", scause_str(scause),
             regs->sepc, csr_read(stval));
      if (!do_page_fault(regs)) {
        // TODO: kill the process
        sys_exit(-1);
      }
      break;
      __attribute__((fallthrough));
    default:
      printk("\e[45m[S]\e[31;49m Unhandled trap: scause = \e[33m%s (0x%lx)\e[31m, sepc = \e[33m0x%lx\e[31m, stval = "
             "\e[33m0x%lx\e[0m\n",
             scause_str(scause), scause, regs->sepc, csr_read(stval));
      sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_SYSTEM_FAILURE);
      __builtin_unreachable();
      break;
  }
}
