//
//  handleConnection.swift
//  
//
//  Created by Juliette on 6/17/21.
//

import Foundation

func handleConnection (connection: JSocket, folder: URL) {
    "220 ESMTP Juliette's SMTP Server \n".write(connection)
    
    while (true) {
        let input = connection.read()
        var command: String = ""
        if input.contains(":") {
            command = input.components(separatedBy: ":")[0]
        } else {
            command = String(input.prefix(4))
        }
        
        switch command {
        case "HELO":
            "250 Hello\n".write(connection)
        case "MAIL FROM":
            "250 Ok\n".write(connection)
        case "RCPT TO":
            "250 Ok\n".write(connection)
        case "QUIT":
            connection.close()
            return
        default:
            "500 I don't know that\n".write(connection)
        }
    }
}
