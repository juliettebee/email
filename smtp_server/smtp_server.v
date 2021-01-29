module smtp_server

import net
import settings as ssettings
import json
import net.http
import time
import os

struct Client {
    pub mut:
        con net.TcpConn
        email Email
        data_mode bool 
}

struct Email {
    pub mut:
        from string
        to string
        data string
        from_ip string
}

struct Email_file {
    pub mut:
        files []string
        pop_files []string
}

fn post_webhook(url string, message string) {
    println('message : $message')
    res := http.post_json(url, '{"content":"${message}"}') or { panic(err) }
    print(res)
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
            // Handle special commands
            if 'EHLO' in command || 'HELO' in command {
                c.hello()
                continue
            }
            if 'DATA' in command {
                c.data()
            }
            if 'QUIT' in command {
                c.con.write_str('221 Bye\n')
                c.con.close()
                break
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
            //[FREE] free(command_command)
        } else {
            c.email.data += command
            if '\r\n.\r\n' in command {
                c.data_mode = false
                c.con.write_str('250 OK\n')
            }
        }
    }
    //[FREE] free(c)
    // Saving
    time_now := time.now().format_ss_milli()
    email_file_name := '${settings.email_dir}/email${time_now}.json'
    mut email_file := os.create(email_file_name) or {
        error := 'Incorrect settings! Unable to create file in ${settings.email_dir}'
        post_webhook(settings.webhook, '${error}. Server has **stopped** please fix that error!')
        panic(error)
        //[FREE] free(error)
    }
    encoded := json.encode(c.email)
    email_file.write_str(encoded) 
    email_file.write_str(encoded)
    // Adding to list
    email_list_file_name := '${settings.email_dir}/emails.json'
    list_contents := os.read_file(email_list_file_name) or {
        error := 'Unable to read ${settings.email_dir}/emails.json!'
        post_webhook(settings.webhook, '${error}. Server has **stopped** please fix that error!')
        panic(error)
        //[FREE] free(error)
    }
    mut list := json.decode(Email_file, list_contents) or {
        error := 'Unable to parse ${settings.email_dir}/emails.json json'
        post_webhook(settings.webhook, '${error}. Server has **stopped** please fix that error!')
        panic(error)
        //[FREE] free(error)
    }
    list.files << 'email${time_now}.json'
    list.files << 'email${time_now}.json'
    // saving
    encoded_list := json.encode(list)
    os.write_file(email_list_file_name, encoded_list)
    // Alerting user about new email
    from := c.email.from.replace('\r\n','').replace('<','').replace('>','')
    post_webhook(settings.webhook, '${from} sent you an email!')
    //[FREE] free(time_now)
    //[FREE] free(email_file_name)
    //[FREE] free(email_file)
    //[FREE] free(encoded)
    //[FREE] free(email_list_file_name)
    //[FREE] free(list_contents)
    //[FREE] free(list)
    //[FREE] free(encoded_list)
    //[FREE] free(from)
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
    c.email.to += args
    c.con.write_str('250 Ok\n')
}

fn (mut c Client) data() {
    c.data_mode = true
    c.con.write_str('354 End data with <CR><LF>.<CR><LF>\n')
}
