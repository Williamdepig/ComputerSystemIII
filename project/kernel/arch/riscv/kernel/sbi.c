#include "types.h"
#include "sbi.h"

struct sbiret sbi_ecall(int ext, int fid, uint64 arg0,
                        uint64 arg1, uint64 arg2,
                        uint64 arg3, uint64 arg4,
                        uint64 arg5)
{
  // #error "Still have unfilled code!"
  // unimplemented
  struct sbiret ecall_ret;
  __asm__ volatile(
    "mv a7, %[ext]\n"
    "mv a6, %[fid]\n"
    "mv a0, %[arg0]\n"
    "mv a1, %[arg1]\n"
    "mv a2, %[arg2]\n"
    "mv a3, %[arg3]\n"
    "mv a4, %[arg4]\n"
    "mv a5, %[arg5]\n"
    "ecall \n"
    "mv %[ecall_ret_error], a0 \n"
    "mv %[ecall_ret_value], a1 "
    : [ecall_ret_error] "=r" (ecall_ret.error), [ecall_ret_value] "=r" (ecall_ret.value)
    : [ext] "r" (ext), [fid] "r" (fid), [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2), [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
    : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "memory"
  );
  return ecall_ret;
}

void sbi_set_timer(uint64 set_time_value){
    sbi_ecall(0x00, 0, set_time_value, 0, 0, 0, 0, 0);
}

// void sbi_console_putchar(char c){
//     sbi_ecall(0x01, 0, (int)c, 0, 0, 0, 0, 0);
// }

// int sbi_console_getchar(){
//     struct sbiret ret;
//     ret = sbi_ecall(0x02, 0, 0, 0, 0, 0, 0, 0);
//     return ret.error;
// }