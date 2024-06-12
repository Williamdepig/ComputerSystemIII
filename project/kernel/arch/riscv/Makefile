all:
	${MAKE} -C kernel all
	${LD} -T kernel/vmlinux.lds kernel/*.o ../../user/uapp*.o ../../lib/*.o -o ../../vmlinux
	@mkdir -p boot
	${OBJCOPY} -O binary ../../vmlinux boot/Image
	${OBJDUMP} -S ../../vmlinux > ../../vmlinux.asm
	${NM} ../../vmlinux >  ../../System.map

clean:
	${MAKE} -C kernel clean
	$(shell test -d boot && rm -rf boot)
