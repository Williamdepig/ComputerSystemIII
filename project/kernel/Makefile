export
CROSS_=riscv64-linux-gnu-
GCC=${CROSS_}gcc
LD=${CROSS_}ld
OBJCOPY=${CROSS_}objcopy
OBJDUMP=${CROSS_}objdump
NM=${CROSS_}nm

ISA=rv64i_zicsr_zifencei
ABI=lp64

INCLUDE = -I $(shell pwd)/include
CF = -march=$(ISA) -mabi=$(ABI) -mcmodel=medany -fno-builtin -ffunction-sections -fdata-sections -nostartfiles -nostdlib -nostdinc -static -lgcc -Wall -Wextra -Wl,--nmagic -g3 -O1 #-Wl,--gc-sections
CFLAG = ${CF} ${INCLUDE}

.PHONY:all run debug clean
all:
	${MAKE} -C lib all
	${MAKE} -C user all
	${MAKE} -C arch/riscv all
	# Build Finished OK

run: all
	# Launch the qemu ......
	@qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -bios default

debug: all
	# Launch the qemu for debug ......
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
	${MAKE} -C user clean
	${MAKE} -C arch/riscv clean
	rm -f vmlinux vmlinux.asm System.map .gdb_history
	# Clean Finished
