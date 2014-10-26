CC:=gcc
LDFLAGS:=$(shell pkg-config --libs libavformat libavcodec libswscale libavutil sdl)
CFLAGS:=-Wall -ggdb

decode:
	$(CC) $(CFLAGS) $(LDFLAGS) decode.c

all: decode
