LIBLITMUS = /home/rts/litmus-rt/liblitmus/
ARCH = /home/rts/litmus-rt/liblitmus/arch/x86/include/

P=base_task
OBJECTS=
CFLAGS =-I${ARCH} -I${LIBLITMUS}/include -g -Wall
LDLIBS=-L${ARCH} -L${LIBLITMUS} -llitmus
CC=c99

$(P): $(OBJECTS)
