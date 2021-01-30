cc=gcc
files=main.c smtpServer/smtpServer.c

all: compile
	./email

compile:
	$(cc) $(files) -o email 

clean:
	rm email

memcheck: compile
	valgrind --leak-check=full -v --log-file=valgrind-out.txt ./email
