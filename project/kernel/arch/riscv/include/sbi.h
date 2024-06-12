#ifndef __SBI_H__
#define __SBI_H__

#include "types.h"

#define SBI_SUCCESS 0
#define SBI_ERR_FAILED -1
#define SBI_ERR_NOT_SUPPORTED -2
#define SBI_ERR_INVALID_PARAM -3
#define SBI_ERR_DENIED -4
#define SBI_ERR_INVALID_ADDRESS -5
#define SBI_ERR_ALREADY_AVAILABLE -6
#define SBI_ERR_ALREADY_STARTED -7
#define SBI_ERR_ALREADY_STOPPED -8
#define SBI_ERR_NO_SHMEM -9

struct sbiret {
  long error;
  long value;
};

// base extension
struct sbiret sbi_get_spec_version(void);
struct sbiret sbi_get_impl_id(void);
struct sbiret sbi_get_impl_version(void);
struct sbiret sbi_probe_extension(uint64_t ext);
struct sbiret sbi_get_mvendorid(void);
struct sbiret sbi_get_marchid(void);
struct sbiret sbi_get_mimpid(void);

// time extension
struct sbiret sbi_set_timer(uint64_t stime_value);

// debug console extension
struct sbiret sbi_debug_console_write(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi);
struct sbiret sbi_debug_console_read(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi);
struct sbiret sbi_debug_console_write_byte(uint8_t byte);

// system reset extension
#define SBI_SRST_RESET_TYPE_SHUTDOWN 0
#define SBI_SRST_RESET_TYPE_COLD_REBOOT 1
#define SBI_SRST_RESET_TYPE_WARM_REBOOT 2
#define SBI_SRST_RESET_REASON_NONE 0
#define SBI_SRST_RESET_REASON_SYSTEM_FAILURE 1
struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason);

#endif
