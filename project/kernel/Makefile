export
CROSS	:=	riscv64-linux-gnu-
GCC		:=	${CROSS}gcc
LD		:=	${CROSS}ld
OBJCOPY	:=	${CROSS}objcopy
OBJDUMP	:=	${CROSS}objdump

ISA		:=	rv64imafd_zifencei
ABI		:=	lp64

INCLUDE := 	-I $(shell pwd)/include -I $(shell pwd)/arch/riscv/include
CF 		:= 	-g3 -march=$(ISA) -mabi=$(ABI) -mcmodel=medany	-fPIE	\
			-fno-builtin -ffunction-sections -fdata-sections	\
			-nostartfiles -nostdlib -nostdinc -static -lgcc -Wl,--nmagic -Wl,--gc-sections
CFLAG 	:= 	${CF} ${INCLUDE}

.PHONY:all run debug clean
all:
	${MAKE} -C lib all
	${MAKE} -C init all
	${MAKE} -C arch/riscv all
	@echo -e '\n'Build Finished OK

run: all
	@echo Launch the qemu ......
	@qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -bios default 

debug: all
	@echo Launch the qemu for debug ......
	@qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -bios default -S -s

SPIKE_CONF = $(CURDIR)/../../../repo/sys-3-project/spike/
spike_run:all
	spike --kernel=arch/riscv/boot/Image $(SPIKE_CONF)/fw_jump.elf

spike_debug:all
	spike -H --rbb-port=9824 --kernel=arch/riscv/boot/Image $(SPIKE_CONF)/fw_jump.elf

spike_bridge:
	openocd -f $(SPIKE_CONF)/spike.cfg

clean:
	${MAKE} -C lib clean
	${MAKE} -C init clean
	${MAKE} -C arch/riscv clean
	$(shell test -f vmlinux && rm vmlinux)
	$(shell test -f System.map && rm System.map)
	@echo -e '\n'Clean Finished
