cc=clang
cflags=-o email

all: compile

compile: Main.c smtpServer/smtpServer.c
	$(cc) $(cflags) $?

deploy: compile
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 25 -j REDIRECT --to-port 2525
	iptables-save
