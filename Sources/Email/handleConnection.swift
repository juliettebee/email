//
//  handleConnection.swift
//  
//
//  Created by Juliette on 6/17/21.
//

import Foundation

func handleConnection (connection: JSocket, folder: URL) {
    "220 ESMTP Juliette's SMTP Server \n".write(connection)
    
    var dataMode = false
    
//    let dataFile = URL(fileURLWithPath: folder.absoluteString).appendingPathComponent(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .long))
    
    let dataFile = URL(fileURLWithPath: folder.absoluteString).appendingPathComponent(UUID().uuidString)

    while (true) {
        let input = connection.read()
        
        if dataMode {
            
            var contents = ""

            do {
                contents = try String(contentsOf: dataFile, encoding: .utf8)
                contents = contents.appending(input)
            } catch {
                contents = input
            }

            do {
                try contents.write(toFile: dataFile.path, atomically: false, encoding: .utf8)
            } catch {
                print("Error (36), \(error)")
            }
            
            if input.contains("\r\n.") {
                dataMode = false
                "250 Ok\n".write(connection)
            }
            continue
        }
        
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
        case "DATA":
            dataMode = true
            "354 End data with <CR><LF>.<CR><LF>\n".write(connection)
        case "QUIT":
            connection.close()
            return
        default:
            "500 I don't know that\n".write(connection)
        }
    }
}
