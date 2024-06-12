ASM_SRC		= $(sort $(wildcard *.S))
C_SRC       = $(sort $(wildcard *.c))
OBJ		    = $(patsubst %.S,%.o,$(ASM_SRC)) $(patsubst %.c,%.o,$(C_SRC))

# INCLUDE += -I $(shell pwd)/include

CFLAG := ${CFLAG} -I $(shell pwd)/../include

all:$(OBJ)

%.o:%.S
	${GCC}  ${CFLAG} -c $<

%.o:%.c
	${GCC}  ${CFLAG} -c $<

clean:
	rm -f *.o
