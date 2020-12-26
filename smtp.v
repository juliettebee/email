module smtp_server

import net
import time
import os
import json
import settings 
import net.http

struct Email {
    pub mut:
        from string
        to []string
        data string
}

struct Email_file {
    pub mut:
        files []string    
}

fn post_webhook(url string, message string) {
    http.post(url, '{"content":"$message"}')
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
    // Getting settings
    settingsjson := settings.load()
    // Sending hello
    connection.write_str('220 smtp.juliette.page ESMTP Postfix\n')
    // Creating a blank email
    mut email := Email{}
    // Creating data mode for later
    mut data_mode := false
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
        // Seeing if its data mode first as n matter what data wwiill always be adde
        if data_mode {
            // Getting data
            mut data := ''
            for letter in command {
                    data += letter.str()
            }
            // Seeing if they endded it
            if '\r\n.\r\n' in data {
                data_mode = false
                connection.write_str('250 OK\n')
            } else {
                email.data += data
            }

        // Checking to see if its hello
        } else if command[0..4] == ['H','E','L','O'] || command[0..4] == ['E','H','L','O']{
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
            args += '\n'
            // Replying
            connection.write_str('250 ' + args ) 
            // Getting the sender
        }  else if command[0..10] == ['M','A','I','L',' ','F','R','O','M',':'] {
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
            connection.write_str('250 OK\n')
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
            connection.write_str('250 OK\n')
            // Enabling data modde if user requests
        } else if command[0..4] == ['D','A','T','A'] {
           data_mode = true 
           connection.write_str('354 End data with <CR><LF>.<CR><LF>\n') 
        } else if command[0..4] == ['Q','U','I','T'] {
            connection.write_str('221 Bye\n')
            connection.close()
            break
        }
    }
    // Saving email
    time_now := time.now().format_ss_milli()
    email_file_name := '${settingsjson.email_dir}/email${time_now}.json'
    mut email_file := os.create(email_file_name) or {
        error := 'Incorrect settings! Unable to create file in ${settingsjson.email_dir}'
        post_webhook(settingsjson.webhook, '${error}. Server has **stopped** please fix that error!')
        panic(error)
    }
    email_file.write_str(json.encode(email)) 
    email_file.close()
    // Adding to the list
    email_list_file_name := '${settingsjson.email_dir}/emails.json'
    list_contents := os.read_file(email_list_file_name) or {
        error := 'Unable to read ${settingsjson.email_dir}/emails.json!'
        post_webhook(settingsjson.webhook, '${error}. Server has **stopped** please fix that error!')
        panic(error)
    }
    mut list := json.decode(Email_file, list_contents) or {
        error := 'Unable to parse ${settingsjson.email_dir}/emails.json json'
        post_webhook(settingsjson.webhook, '${error}. Server has **stopped** please fix that error!')
        panic(error)
    }
    list.files << 'email${time_now}.json'
    // saving
    os.write_file(email_list_file_name, json.encode(list))
    // Alerting user about new email
    post_webhook(settingsjson.webhook, '${email.from} sent you an email!')
}
