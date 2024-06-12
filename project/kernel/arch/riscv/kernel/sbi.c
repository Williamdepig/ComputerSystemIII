#include "types.h"
#include "sbi.h"

// https://github.com/riscv-non-isa/riscv-sbi-doc/blob/master/riscv-sbi.adoc

#define SBI_EXT_BASE 0x10
#define SBI_BASE_GET_SPEC_VERSION 0
#define SBI_BASE_GET_IMPL_ID 1
#define SBI_BASE_GET_IMPL_VERSION 2
#define SBI_BASE_PROBE_EXT 3
#define SBI_BASE_GET_MVENDORID 4
#define SBI_BASE_GET_MARCHID 5
#define SBI_BASE_GET_MIMPID 6

#define SBI_EXT_TIME 0x54494d45 // "TIME"
#define SBI_TIME_SET_TIMER 0

#define SBI_EXT_DEBUG_CONSOLE 0x4442434e // "DBCN"
#define SBI_DBCN_WRITE 0
#define SBI_DBCN_READ 1
#define SBI_DBCN_WRITE_BYTE 2

#define SBI_EXT_SYSTEM_RESET 0x53525354 // "SRST"
#define SBI_SRST_SYSTEM_RESET 0

static inline struct sbiret sbi_ecall(int, int, uint64_t, uint64_t, uint64_t, uint64_t, uint64_t, uint64_t)
    __attribute__((always_inline));

static inline struct sbiret sbi_ecall(int eid, int fid, uint64_t arg0, uint64_t arg1, uint64_t arg2, uint64_t arg3,
                                      uint64_t arg4, uint64_t arg5) {
  register uint64_t a0 asm("a0") = arg0;
  register uint64_t a1 asm("a1") = arg1;
  register uint64_t a2 asm("a2") = arg2;
  register uint64_t a3 asm("a3") = arg3;
  register uint64_t a4 asm("a4") = arg4;
  register uint64_t a5 asm("a5") = arg5;
  register uint64_t a6 asm("a6") = fid;
  register uint64_t a7 asm("a7") = eid;
  asm volatile("ecall"
               : "+r"(a0), "+r"(a1)
               : "r"(a0), "r"(a1), "r"(a2), "r"(a3), "r"(a4), "r"(a5), "r"(a6), "r"(a7)
               : "memory");
  return (struct sbiret) {a0, a1};
}

struct sbiret sbi_get_spec_version(void) {
  return sbi_ecall(SBI_EXT_BASE, SBI_BASE_GET_SPEC_VERSION, 0, 0, 0, 0, 0, 0);
}

struct sbiret sbi_get_impl_id(void) {
  return sbi_ecall(SBI_EXT_BASE, SBI_BASE_GET_IMPL_ID, 0, 0, 0, 0, 0, 0);
}

struct sbiret sbi_get_impl_version(void) {
  return sbi_ecall(SBI_EXT_BASE, SBI_BASE_GET_IMPL_VERSION, 0, 0, 0, 0, 0, 0);
}

struct sbiret sbi_probe_extension(uint64_t ext) {
  return sbi_ecall(SBI_EXT_BASE, SBI_BASE_PROBE_EXT, ext, 0, 0, 0, 0, 0);
}

struct sbiret sbi_get_mvendorid(void) {
  return sbi_ecall(SBI_EXT_BASE, SBI_BASE_GET_MVENDORID, 0, 0, 0, 0, 0, 0);
}

struct sbiret sbi_get_marchid(void) {
  return sbi_ecall(SBI_EXT_BASE, SBI_BASE_GET_MARCHID, 0, 0, 0, 0, 0, 0);
}

struct sbiret sbi_get_mimpid(void) {
  return sbi_ecall(SBI_EXT_BASE, SBI_BASE_GET_MIMPID, 0, 0, 0, 0, 0, 0);
}

struct sbiret sbi_set_timer(uint64_t stime_value) {
  return sbi_ecall(SBI_EXT_TIME, SBI_TIME_SET_TIMER, stime_value, 0, 0, 0, 0, 0);
}

struct sbiret sbi_debug_console_write(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi) {
  return sbi_ecall(SBI_EXT_DEBUG_CONSOLE, SBI_DBCN_WRITE, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
}

struct sbiret sbi_debug_console_read(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi) {
  return sbi_ecall(SBI_EXT_DEBUG_CONSOLE, SBI_DBCN_READ, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
}

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
  return sbi_ecall(SBI_EXT_DEBUG_CONSOLE, SBI_DBCN_WRITE_BYTE, byte, 0, 0, 0, 0, 0);
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
  return sbi_ecall(SBI_EXT_SYSTEM_RESET, SBI_SRST_SYSTEM_RESET, reset_type, reset_reason, 0, 0, 0, 0);
}
