all: compile

compile:
	swift build

deploy: compile
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 25 -j REDIRECT --to-port 2525
	iptables-save

test:
	mkdir -p tests/emails
	#swift run Email $(pwd)/tests/emails &
	#sleep 4
	elixir tests/tests.exs
	rm -rf tests/emails
