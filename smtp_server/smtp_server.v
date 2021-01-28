module smtp_server

import net
import settings as ssettings

struct Client {
    pub mut:
        con net.TcpConn
        email Email
        data_mode bool 
}

struct Email {
    pub mut:
        from string
        to []string
        data string
        from_ip string
}

pub fn start() {
    // Getting settings
    settings := ssettings.load()
    // Open a port and start listening
    l := net.listen_tcp(25) or { panic(err) }
    // Waiting for request & handling
    for {
        new_request := l.accept() or { continue }
        // Checking if ip is blocked
        addr := new_request.sock.address() or {
            new_request.close()
            continue
        }
        if addr.saddr in settings.blocked_ips {
           new_request.close()
           continue
        }
        // We are going to handle it concerntly so if we are getting multiple connections we dont have to worry
        go handle(new_request)
//[FREE]        free(new_request)
    }
//[FREE]    free(settings)
}

fn handle(con net.TcpConn) {
    // We need settings
    settings := ssettings.load()
    // Lets send info
    con.write_str('220 ${settings.domain} Juliette SMTP\n')
    // Creating variables
    mut c := Client{con: con, email: Email{}}
    // Handling commands
    for {
        // Reading input 
        mut buf := []byte{len:100}
        con.read(mut buf) or {
            con.write_str('Unable to parse!\n')
            continue
        }
        // Converting
        mut command := string{}
        for byre in buf {
            command += byre.str() 
        }
        //[FREE]    free(buf)
        if !c.data_mode {
            if 'EHLO' in command || 'HELO' in command {
                c.hello()
                continue
            }
            if 'DATA' in command {
                c.data()
            }
            command_command := command.split(':')
            //[FREE] free(command)
            // Now lets handle command
            match(command_command[0]) {
                'MAIL FROM' {
                    c.from(command_command[1])
                } 
                'RCPT TO' {
                    c.to(command_command[1])
                }
                else {}
            }
            print(c.email)
            //[FREE] free(command_command)
        } else {
            print('data')
            c.email.data += command
            if '\r\n.\r\n' in command {
                c.data_mode = false
                c.con.write_str('250 OK\n')
            }
        }
    }
    //[FREE] free(c)
}

fn (mut c Client) hello() {
    c.con.write_str('220 Hello, Im juliette\n')
} 

fn (mut c Client) from(args string) {
    c.email.from = args
    c.con.write_str('250 Ok\n')
}

fn (mut c Client) to(args string) {
    c.email.to << args
    c.con.write_str('250 Ok\n')
}

fn (mut c Client) data() {
    c.data_mode = true
    c.con.write_str('354 End data with <CR><LF>.<CR><LF>\n')
}
