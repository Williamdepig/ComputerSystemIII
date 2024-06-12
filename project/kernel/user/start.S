    .section .text.init
    .global _start
_start:
    call __setup_uapp
    tail main
