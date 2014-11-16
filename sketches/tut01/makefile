LIBLITMUS = /home/rts/code/liblitmus/
ARCH = /home/rts/code/liblitmus/arch/x86/include/

T=transcoding
P=tut01
f=filter
OBJECTS=
CFLAGS =-I${ARCH} -I${LIBLITMUS}/include -g -Wall
LDLIBS=-L${ARCH} -L${LIBLITMUS} -llitmus `pkg-config --libs libavformat libavcodec libswscale libavutil libavfilter sdl`
CC=gcc

$(P): $(OBJECTS)
$(T): $(OBJECTS)



