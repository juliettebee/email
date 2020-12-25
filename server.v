module server

import net

pub fn run() {
    // Opens port 90
	l := net.listen_tcp(587) or {
		panic(err)
	}
    // Waiting for a request
    for {
        // Accepting request
        // If it breaks just continue looping
		new_conn := l.accept() or {
			continue
		}
        // Handling connection
        handle_connection(new_conn)
	}
}

fn handle_connection(connection net.TcpConn) {
    println('$connection.sock')
    for {
        mut buf := []byte{len: 100, init: 0}
        read := connection.read(mut buf) or {
            println('error reading')
            return
        }
        println(read)
        for str in buf {
            print(str)
        }
    }
}
