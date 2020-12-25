module smtp_server

import net

struct Email {
    pub mut:
        from string
        to []string
        data string
}
pub fn start() {
    // Opens port 25
    l := net.listen_tcp(25) or { panic(err) }
    // Wait for request
    for {
        // Accept request
        new_request := l.accept() or { continue } 
        handle(new_request)
    }
}

fn handle(connection net.TcpConn) {
    // Sending hello
    connection.write_str('220 smtp.juliette.page ESMTP Postfix\n')
    // Creating a blank email
    mut email := Email{}
    // Creating data mode for later
//    mut data_mode := false
    // Reading commands
    for {
        // Reading connection 
        mut buf := []byte{len:100}
        connection.read(mut buf) or { println(err) }
        // Converting to a string array
        mut command := []string{}
        for byre in buf {
            command << byre.str()
        }
        // Then making it upper case
        command = command.map(it.to_upper())
        // Checking commands
        // Checking to see if its hello
        if command[0..4] == ['H','E','L','O'] {
            // Getting args
            mut args :=  ''
            for arg in command[5..command.len] {
                // Seeing to see if its a new line
                // New linese are ignored as they mark end of command
                if arg == '\n' {
                    continue
                }  
                args += arg

            }
            // Replying
            connection.write_str('250 ' + args ) 
            // Getting the sender
        } else if command[0..10] == ['M','A','I','L',' ','F','R','O','M',':'] {
            mut from := ''
            // Getting arg
            for letter in command[11..command.len] {
                if letter == '\n' {
                    continue
                } else {
                    from += letter.str()
                }
            }
            // Adding to our email
            email.from = from
            // Replying
            connection.write_str('250 OK')
        } else if command[0..8] == ['R','C','P','T',' ','T','O',':'] {
            mut to := ''
            // Getting arg
            for letter in command[8..command.len] {
                if letter == '\n' {
                    continue
                } else {
                    to += letter.str()
                }
            }
            email.to << to
            connection.write_str('250 OK')
        }
    }
}
