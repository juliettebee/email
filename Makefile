cc=gcc
files=Main.c smtpServer/smtpServer.c

all: compile
	./email

compile:
	$(cc) $(files) -o email 

clean:
	rm email

memcheck: compile
	valgrind --leak-check=full -v --log-file=valgrind-out.txt ./email

deploy: compile
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables-save
	./email
