OUTPUT_ARCH( "riscv" )

ENTRY(_start)

SECTIONS
{
    . = 0x0;
    _start = .;

    .text.init : {
        *(.text.init)
    }

    .text : {
        *(.text .text.*)
    }

    .rodata : {
        *(.srodata .srodata.*)
        *(.rodata .rodata*)
    }

    .data : {
        *(.sdata .sdata*)
        *(.data .data.*)
    }

    .bss : {
        *(.bss .bss.*)
        *(.sbss .sbss.*)
    }

    .debug : {
        *(.note.*)
    }
}
