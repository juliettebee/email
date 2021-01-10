module smtp_sender 

import settings
import net
import time

// Function to send email!
pub fn send(server string, from string, to string, subject string, body string) {
    // TODO: get mx server from to
    // Getting settings
    settings_json := settings.load()
    conn := net.dial_tcp('$server:25') or { panic(err) }
    // Sending ehlo
    ehlo := 'EHLO ${settings_json.domain}\r\n'
    conn.write(ehlo.bytes()) or { panic(err) }
    // Sending from
    from_command := 'MAIL FROM:<${from}>\r\n'
    conn.write(from_command.bytes()) or { panic(err) }
    // Sening to
    to_command := 'RCPT TO:<${to}>\r\n'
    conn.write(to_command.bytes()) or { panic(err) }
    // Sending ddtaa
    data_command := 'DATA\r\n'
    conn.write(data_command.bytes()) or { panic(err) }
    // Getting date
    now := time.now()
    // Sending from
    data_from := 'From: $from\r\n'
    conn.write(data_from.bytes()) or { panic(err) }
    // Sending to
    data_to :='To: <$to>\r\n' 
    conn.write(data_to.bytes()) or { panic(err) }
    // Sending date
    data_date := 'Date: $now\r\n'
    conn.write(data_date.bytes())
    // Sending subject
    data_subject := 'Subject: $subject\r\n'
    conn.write(data_subject.bytes()) or { panic(err) }
    // Sending body
    conn.write(body.bytes())
    // Sending end of data
    end_of_data := '\r\n.\r\n'
    conn.write(end_of_data.bytes()) or { panic(err) }
    // Leaving
    quit_command := 'QUIT\r\n'
    conn.write(quit_command.bytes()) or { panic(err) }
    conn.close() or { panic(err) }
}

