# ComputerSystemIII

xpart 共享库：

- project 代码。
- frame 中存放框架代码。

## 硬件

`TLB`：
就是在 lab2 中实现的 `cache` 的翻版。

- 删除 `writeback` 操作。
- 由于 `TLB` 只和 `TWU` 交互，因此展开总线接口。
- 修改为 `64` 位数据传输，而非 `128` 位。

`TWU`：
根据输入的虚拟地址与 `satp` 中存储的 `ppn`，与 `Dcache` 交互得到 `pte`。

- 状态机实现。
- 读取的每级页表项都检查 `RWX` 与 `V` 位，如果 `RWX` 位不为零，则就是叶子页表项，直接返回。否则一共读取三级页表并返回页表项。

## 软件

`I/O`：

- I/O 流抽象 struct FILE, stdin, stdout, stderr
- I/O 流控制 fflush, fclose, feof
- 窄字符输入 fgetc, getc, getchar, fgets, gets
- 窄字符输出 fputc, putc, putchar, fputs, puts
- 窄字符格式输出 printf, fprintf, vprintf, vfprintf

`syscall`：

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
