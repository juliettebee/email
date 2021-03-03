cc=gcc
files=Main.c smtpServer/smtpServer.c 

all: compile

compile:
	$(cc) -pthread $(files) -o email 

clean:
	rm email

memcheck: compile
	valgrind --leak-check=full -v --log-file=valgrind-out.txt ./email

deploy: compile
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 25 -j REDIRECT --to-port 2525
	iptables-save
	./email
