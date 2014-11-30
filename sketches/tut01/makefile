LIBLITMUS = /home/rts/litmus-rt/liblitmus/
ARCH = /home/rts/litmus-rt/liblitmus/arch/x86/include/

P=filter_part_1
OBJECTS=
CFLAGS =-I${ARCH} -I${LIBLITMUS}/include -g -Wall
LDLIBS=-L${ARCH} -L${LIBLITMUS} -llitmus `pkg-config --libs libavformat libavcodec libswscale libavutil libavfilter sdl`
CC=gcc

$(P): $(OBJECTS)


