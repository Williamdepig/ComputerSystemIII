OUTPUT_ARCH( "riscv" )
ENTRY(_sbi_start)

SECTIONS
{
  . = 0x80000000 ;
  _sbi_start = . ;
  .sbi.text : {
    ./mini_sbi/sbi_head.o(.text)
    ./mini_sbi/*(.text)
  }
  . = ALIGN(0x10);
  .sbi.rodata : {./mini_sbi/*(.rodata)}
  . = ALIGN(0x10);
  .sbi.data : {./mini_sbi/*(.data)}
  . = ALIGN(0x10);
  .sbi.bss : {./mini_sbi/*(.bss)}

  /* . = 0x80200000 ;
  .payload : {*(.payload)} */
  /* . 代表当前地址 */

  . = 0x80200000;
  _payload_address = .;
  _skernel = .;
  .text : ALIGN(0x1000){
    _stext = .;
    *(.text.init)
    *(.text.entry)
    *(.text .text.*)
    _etext = .;
  }

  .rodata : ALIGN(0x1000){
      _srodata = .;
      *(.rodata .rodata.*)
      _erodata = .;
  }

  .data : ALIGN(0x1000){
      _sdata = .;
      *(.data .data.*)
      _edata = .;
      . = ALIGN(0x1000);

      uapp_start = .;
      *(.uapp1)
      uapp_end = .;
      . = ALIGN(0x1000);

      uapp2_start = .;
      *(.uapp2)
      uapp2_end = .;
      . = ALIGN(0x1000);
  }

  .bss : ALIGN(0x1000){
      _sbss = .;
      *(.bss.stack)
      *(.sbss .sbss.*)
      *(.bss .bss.*)
      _ebss = .;
  }

    .stack : ALIGN(0x1000) {
        _sstack = .;

        *(.stack .stack.*)

        . = ALIGN(0x1000);
        . += 0x20000;

        _estack = .;
    } >ramv AT>ram

    /* 记录kernel代码的结束地址 */
    _ekernel = .;
}
