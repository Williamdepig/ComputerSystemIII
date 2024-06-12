C_SRC       = $(sort $(wildcard *.c))
S_SRC       = $(sort $(wildcard *.S))
OBJ		    = $(patsubst %.c,%.o,$(C_SRC)) $(patsubst %.S,%.o,$(S_SRC))

# file = printk.o

all:$(OBJ)

%.o:%.c
	${GCC} ${CFLAG} -c $<

%.o:%.S
	${GCC} ${CFLAG} -c $<

clean:
	rm -f *.o
