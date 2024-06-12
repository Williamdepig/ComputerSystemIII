# ComputerSystemIII

- xpart 共享库。
- kernel 是 lab3 的代码，仅实现了虚拟内存映射。
- frame 中存放框架代码。

FINISH:

- 已完成 `TWU` 状态机。
- 增加 `PageStruct` 结构体，存放 `PTE` 。
- `MMU` 编写完成。
- `TLB` 编写完成

`TLB`：
就是在 lab2 中实现的 `cache` 的翻版。

- 删除 `writeback` 操作。
- 由于 `TLB` 只和 `TWU` 交互，因此展开总线接口。
- 修改为 `64` 位数据传输，而非 `128` 位。

`TWU`：
根据输入的虚拟地址与 `satp` 中存储的 `ppn`，与 `Dcache` 交互得到 `pte`。

- 状态机实现。
- 读取的每级页表项都检查 `RWX` 与 `V` 位，如果 `RWX` 位不为零，则就是叶子页表项，直接返回。否则一共读取三级页表并返回页表项。

1. 如果 `TLB` 没有请求，保持 `IDLE` 状态。
2. 