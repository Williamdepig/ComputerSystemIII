`include "Define.vh"

module CrossBar (
    input         wen_cpu,
    input         ren_cpu,
    output        mem_stall,
    output [63:0] rdata_cpu,
    input  [63:0] address_cpu,

    output        wen_cpu_to_mem,
    output        ren_cpu_to_mem,
    input         mem_stall_from_mem,
    input  [63:0] rdata_cpu_from_mem,

    output        wen_cpu_to_mmio,
    output        ren_cpu_to_mmio,
    input         mem_stall_from_mmio,
    input  [63:0] rdata_cpu_from_mmio
);

    wire mem_rom = address_cpu < (`ROM_BASE + `ROM_LEN);
    wire mem_buffer = (`BUFFER_BASE <= address_cpu) & (address_cpu < (`BUFFER_BASE + `BUFFER_LEN));
    wire mem_mem = (`MEM_BASE <= address_cpu) & (address_cpu < (`MEM_BASE + `MEM_LEN));
    wire is_mem = mem_rom | mem_buffer | mem_mem;

    wire mmio_mtime = (`MTIME_BASE == address_cpu);
    wire mmio_mtimcmp = (`MTIMECMP_BASE == address_cpu);
    wire mmio_disp = (`DISP_BASE == address_cpu);
    wire mmio_uart = (`UART_BASE <= address_cpu) & ((`UART_BASE + `UART_LEN) > address_cpu);
    wire mmio_icache = (`ICACHE_BASE == address_cpu);
    wire mmio_dcache = (`DCACHE_BASE == address_cpu);
    wire is_mmio = mmio_mtime | mmio_mtimcmp | mmio_dcache | mmio_icache | mmio_uart | mmio_disp;

    assign wen_cpu_to_mem  = is_mem ? wen_cpu : 1'b0;
    assign wen_cpu_to_mmio = is_mmio ? wen_cpu : 1'b0;
    assign ren_cpu_to_mem  = is_mem ? ren_cpu : 1'b0;
    assign ren_cpu_to_mmio = is_mmio ? ren_cpu : 1'b0;

    assign mem_stall       = is_mem ? mem_stall_from_mem : is_mmio ? mem_stall_from_mmio : 1'b0;
    assign rdata_cpu       = is_mem ? rdata_cpu_from_mem : is_mmio ? rdata_cpu_from_mmio : 64'b0;
endmodule
