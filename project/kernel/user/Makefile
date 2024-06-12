ASM_SRC		= $(filter-out uapp1.S uapp2.S, $(sort $(wildcard *.S)))
C_SRC       = $(filter-out main1.c main2.c, $(sort $(wildcard *.c)))
LIB_OBJ     = $(wildcard ../lib/*.o)
OBJ		    = $(patsubst %.S,%.o,$(ASM_SRC)) $(patsubst %.c,%.o,$(C_SRC)) $(LIB_OBJ)

all: uapp1.o uapp2.o
	${OBJDUMP} -S uapp1.elf > uapp1.asm
	${OBJDUMP} -S uapp2.elf > uapp2.asm

uapp1.o: uapp1.S uapp1.bin
	${GCC} ${CFLAG} -c uapp1.S

uapp2.o: uapp2.S uapp2.bin
	${GCC} ${CFLAG} -c uapp2.S

%.o:%.c
	${GCC} ${CFLAG} -c $<

%.o:%.S
	${GCC} ${CFLAG} -c $<

uapp1.bin: $(OBJ) main1.o
	${GCC} ${CFLAG} -fpie -pie -T link.lds -o uapp1.elf ${OBJ} main1.o
	${OBJCOPY} uapp1.elf -O binary uapp1.bin

uapp2.bin: $(OBJ) main2.o
	${GCC} ${CFLAG} -fpie -pie -T link.lds -o uapp2.elf ${OBJ} main2.o
	${OBJCOPY} uapp2.elf -O binary uapp2.bin

clean:
	rm -f *.o uapp1.o uapp1.elf uapp1.bin uapp1.asm uapp2.o uapp2.elf uapp2.bin uapp2.asm
