cc=gcc
files=main.c smtpServer/smtpServer.c

all: compile
	./email

compile:
	$(cc) $(files) -o email 

clean:
	rm email

memcheck: compile
	valgrind --leak-check=full \
         --show-leak-kinds=all \
         --track-origins=yes \
         --verbose \
         --log-file=valgrind-out.txt \
		 ./email
