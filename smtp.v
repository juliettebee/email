module smtp_server

import net
import time
import os
import json

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

pub fn start(email_dir string) {
    // Opens port 25
    l := net.listen_tcp(25) or { panic(err) }
    // Wait for request
    for {
        // Accept request
        new_request := l.accept() or { continue } 
        handle(new_request, email_dir)
    }
}

fn handle(connection net.TcpConn, email_dir string) {
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
        // Checking to see if its hello
        if command[0..4] == ['H','E','L','O'] || command[0..4] == ['E','H','L','O']{
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
           connection.write_str('354 Send message content; end with .!\n') 
        } else if data_mode {
            // Getting data
            mut data := ''
            for letter in command {
                    data += letter.str()
            }
            // Seeing if they endded it
            if data[0].str() == '.' {
                if data[1].str() == '!' { 
                    print('Out of data')
                    data_mode = false
                    connection.write_str('250 OK\n')
                }
            } else {
                email.data += data
            }
            // Quit command
        } else if command[0..4] == ['Q','U','I','T'] {
            connection.write_str('221 Bye\n')
            connection.close()
            break
        }
    }
    // Saving email
    time_now := time.now().format_ss_milli()
    email_file_name := '$email_dir/${time_now}.json'
    mut email_file := os.create(email_file_name) or {panic('Incorrect settings! Unable to create file') }
    email_file.write_str(json.encode(email)) 
    email_file.close()
    // Adding to the list
    email_list_file_name := '$email_dir/emails.json'
    mut email_list := os.open_file(email_list_file_name, 'w+') or {panic('Incorrect settings! Unable to Open emails.json')}
    mut email_list_contents := os.read_file(email_list_file_name) or { panic('Bad settings!')}
    mut email_list_json := json.decode(Email_file, email_list_contents) or { panic('unable to parse settings')} 
    email_list_json.files << '${time_now}.json' 
    email_list.write_str(json.encode(email_list_json))
    email_list.close()
}
