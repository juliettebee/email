cc=clang
cflags=-o email

all: compile

compile: Main.c
	$(cc) $(cflags) $?
