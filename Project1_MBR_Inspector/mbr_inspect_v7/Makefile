CC = gcc
CFLAGS = -Wall -Wextra -O2

all: mbr_inspect

mbr_inspect: main.o mbr.o
	$(CC) $(CFLAGS) -o mbr_inspect main.o mbr.o

clean:
	rm -f *.o mbr_inspect
