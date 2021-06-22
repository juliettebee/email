all: compile

compile:
	swift build

run:
	swift run Email $(shell pwd)/tests/emails

deploy: compile
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 25 -j REDIRECT --to-port 2525
	iptables-save

test:
	mkdir -p tests/emails
	elixir tests/tests.exs
	rm -rf tests/emails
