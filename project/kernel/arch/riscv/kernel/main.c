#include "kio.h"
#include "clock.h"
#include "proc.h"
#include "mm.h"
#include "sbi.h"

extern uint8_t uapp_start[];

void start_kernel(void) {
  printk("SBI spec version: %#08lx\n", sbi_get_spec_version().value);
  printk("SBI impl id: %#lx\n", sbi_get_impl_id().value);
  printk("SBI impl version: %#08lx\n", sbi_get_impl_version().value);
  printk("SBI machine vendor id: %lu\n", sbi_get_mvendorid().value);
  printk("SBI machine arch id: %lu\n", sbi_get_marchid().value);
  printk("SBI machine imp id: %lu\n", sbi_get_mimpid().value);

  printk("First instruction of user section: %08x @ %p\n", *(uint32_t *)uapp_start, uapp_start);

  sys_puts("===== 2024 ZJU Computer System III =====");

  while (0 && 1) {
    char buf[64];
    struct sbiret ret = sbi_debug_console_read(64, VA2PA(buf), 0);

    if (ret.error) {
      printk("Error reading from console: %ld\n", ret.error);
      sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_SYSTEM_FAILURE);
    }

    if (ret.value == 0) {
      continue;
    }

    buf[ret.value] = '\0';

    printk("Read %ld bytes from console:", ret.value);
    for (int i = 0; i < ret.value; i++) {
      printk(" %02x", buf[i]);
    }
    printk("\n");
  }

  // set first timer
  sbi_set_timer(0);

  schedule(); // noreturn

  __builtin_unreachable();
}
