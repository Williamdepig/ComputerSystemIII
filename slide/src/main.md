---
title: Xpart 展示
separator: <!--s-->
verticalSeparator: <!--v-->
theme: simple
highlightTheme: github
css: custom.css
revealOptions:
    transition: 'slide'
    transitionSpeed: fast
    center: false
    slideNumber: "c/t"
    width: 1000
---

<!-- .slide: data-background="sys3/cover.png" -->

<!--v-->
<!-- .slide: data-background="sys3/background.png" -->

## 最终成果简要介绍

- 64 位 RISC-V 五级流水线 CPU
    - 支持除 ebreak / wfi 外的完整 RV64I_Zicsr_Zifencei 指令集
- 支持 RISC-V Bare 和 Sv39 模式虚拟内存管理的 MMU
    - 包含 TWU 与 TLB
    - 包含 2-bit 分支预测
    - 包含 Icache 与 Dcache
    - 支持 4 KB、2 MB、1 GB 三级页表
- 支持 MSU 三个特权级别
    - 能运行 Lab3 实现的 kernel
- 较为完善的 kernel
    - RISC-V SBI 规范 v2.0
    - C 风格 I/O 流
    - 支持 fork、execve、signal 等系统调用

<!--v-->
<!-- .slide: data-background="sys3/background.png" -->

## CPU 运行 kernel 结果 - 输出

<div class="center">
<img src="sys3/lab3kernel.avif" width="90%">
</div>

<!--v-->
<!-- .slide: data-background="sys3/background.png" -->

## CPU 运行 kernel 结果 - 波形

```asm
            80200090:	18029073          	csrrw	zero,satp,t0
            80200094:	12000073          	sfence.vma	zero,zero

_after_satp:
    ffffffe000200098:	00008067          	jalr	zero,0(ra)
```

- CPI 约为 2.164

<div class="center">
<img src="sys3/wave.avif">
</div>

<!--s-->
<!-- .slide: data-background="sys3/background.png" -->

<div class="middle center">
<div style="width: 100%">

# Xpart 硬件部分

</div>
</div>

<!--v-->
<!-- .slide: data-background="sys3/background.png" -->

## 整体设计思路 - MMU

<div class="center">
<img src="sys3/mmu.avif" width="70%">
</div>

<!--v-->
<!-- .slide: data-background="sys3/background.png" -->

## 整体设计思路 - TLB 与 TWU

- TLB:
  - 在 lab2 中实现的 Cache 的“翻版”
  - 用于加速地址转换过程
  - 删除 write back 功能
  - 修改为 64 位传输而非 128 位
- TWU:
  - 根据输入的虚拟地址与 satp 中储存的 ppn，与 Dcache 交互得到 pte
  - 状态机实现
  - 读取的每级页表项检查权限位，进行相应的逐级查找并返回

<!--v-->
<!-- .slide: data-background="sys3/background.png" -->

## TWU 状态机

1. 如果没有来自 TLB 的请求，保持 IDLE 阶段
2. 接收来自 TLB 的 request、va，进入 L2；<br>将 vpn[2] << 3 加上 satp.ppn 作为 pa 与 Dcache 交互
<img src="sys3/tlb.avif" align="right" width="30%" style="padding-right: 30px;">
3. 检查 Dcache 返回 pte 的权限位：
    - RWX 位不为零，则叶页表项；返回 IDLE 阶段，并把 pte 传回 TLB
    - 否则进入 L1 阶段，将 vpn[1] << 3 加上 pte.ppn，进行下一级读取
    - L1 与 L0 阶段同理
4. 将 pte 发送回 TLB，此时传入的 va 能够命中 TLB，即可将 offset + pte.ppn 作为映射完成的物理地址向对应的 cache 传递

<!--s-->
<!-- .slide: data-background="sys3/background.png" -->

<div class="middle center">
<div style="width: 100%">

# Xpart 软件部分

</div>
</div>

<!--v-->
<!-- .slide: data-background="sys3/background.png" -->

## I/O 功能

根据 C 语言与 POSIX 标准，实现了部分阻塞 I/O API：

- I/O 流抽象 struct FILE, stdin, stdout, stderr
- I/O 流控制 fflush, fclose, feof
- 窄字符输入 fgetc, getc, getchar, fgets, gets
- 窄字符输出 fputc, putc, putchar, fputs, puts
- 窄字符格式输出 printf, fprintf, vprintf, vfprintf

<div class="mul-cols">
<div class="col">

使用 read / write 系统调用实现

```c
printf("Enter a line: ");
fflush(stdout);
fgets(buf, sizeof buf, stdin);
printf("\nYou entered: %s\n", buf);
```

</div>
<div class="col">

<div style="text-align: center;">
<img src="sys3/input.avif" width="90%">
</div>

</div>
</div>

<!--v-->
<!-- .slide: data-background="sys3/background.png" -->

## 系统调用

内核支持的系统调用：

```c
pid_t getpid(void);
pid_t fork(void);
int execve(const char *, char *const [], char *const []);
ssize_t read(int, void *, size_t);
ssize_t write(int, const void *, size_t);
int close(int);
void exit(int);
pid_t getppid(void);
int kill(pid_t, int);
int reboot(int);
int clock_gettime(clockid_t, struct timespec *);
int sched_get_priority_max(int);
int sched_get_priority_min(int);
int sched_yield(void);
sighandler_t signal(int, sighandler_t);
```

<!--v-->
<!-- .slide: data-background="sys3/background.png" -->

## 系统调用演示

- vmlinux 中含有 uapp1 与 uapp2 两个用户程序

<div style="text-align: center;">
<img src="sys3/syscalls.avif" width="70%">
</div>

<!--v-->
<!-- .slide: data-background="sys3/background.png" -->

## 对 RISC-V SBI 的支持

- 迁移到 RISC-V SBI 规范 v2.0，完整支持以下 SBI 扩展：
    - Base Extension (EID #0x10)
    - Timer Extension (EID #0x54494D45 "TIME")
    - System Reset Extension (EID #0x53525354 "SRST")
    - Debug Console Extension (EID #0x4442434E "DBCN")

```c
struct sbiret sbi_get_spec_version(void);
struct sbiret sbi_get_impl_id(void);
struct sbiret sbi_get_impl_version(void);
struct sbiret sbi_probe_extension(uint64_t ext);
struct sbiret sbi_get_mvendorid(void);
struct sbiret sbi_get_marchid(void);
struct sbiret sbi_get_mimpid(void);
struct sbiret sbi_set_timer(uint64_t stime_value);
struct sbiret sbi_debug_console_write(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi);
struct sbiret sbi_debug_console_read(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi);
struct sbiret sbi_debug_console_write_byte(uint8_t byte);
struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason);
```

<!--s-->
<!-- .slide: data-background="sys3/ending.png" -->
