CC:=gcc
LDFLAGS:=$(shell pkg-config --libs libavformat libavcodec libswscale libavfilter libavutil sdl)
CFLAGS:=-Wall -ggdb

decode:
	$(CC) $(CFLAGS) $(LDFLAGS) decode.c

transcode:
	$(CC) $(CFLAGS) $(LDFLAGS) transcoding.c

all: decode transcode
