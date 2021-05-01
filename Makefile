cc=clang
cflags=-o email

all: compile

compile: Main.c smtpServer/smtpServer.c
	$(cc) $(cflags) $?
