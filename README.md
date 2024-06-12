# ComputerSystemIII

- xpart 共享库。
- kernel 是 lab3 的代码，仅实现了虚拟内存映射。
- frame 中存放框架代码。

FINISH:

- 已完成 `TWU` 状态机。
- 增加 `PageStruct` 结构体，存放 `PTE` 。
- `MMU` 编写完成。
- `TLB` 编写完成

TODO:

- `sfence.vma` 与 `fence.i` 解码，实际就是给一个刷新信号。
- `MMU` 中需要检测 `page fault`，在 `IFExceptExamine` 与 `MEMExceptExamine` 中增加异常检测。
- 调整 `BTB`，检查是否会发生错误判断导致缺页异常发生。
- cache 中 sfence 强制写回
- 指令的提交