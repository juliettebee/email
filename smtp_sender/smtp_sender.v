module smtp_sender

import net.smtp

// Function to send email!
pub fn send(server string, from string, to string, subject string, body string) {
        client_cfg := smtp.Client{
                server: '$server'
                from: '$from'
        }
                send_cfg := smtp.Mail{
                to: '$to'
                subject: '$subject'
                body: '$body'
        }
        mut client := smtp.new_client(client_cfg) or { panic(err) }
        client.send(send_cfg) or { panic(err) }
        client.quit() or { panic(err) }
}
