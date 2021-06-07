//
//  handleConnection.swift
//  
//
//  Created by Juliette on 6/5/21.
//

import Foundation

func handleConnection (connection: JSocket, folder: URL) {
    let hello = "+OK POP3 server ready\n"
    hello.write(connection)
    
    var files: [URL]? = nil
    
    do {
        files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
    } catch {
        print(error)
        connection.close()
        return
    }
    
    if files == nil {
        connection.close()
        return
    }
    
    while (true) {
        let input = connection.read()
        let components = input.components(separatedBy: " ")
        let command = components[0].trimmingCharacters(in: CharacterSet.newlines)
        var argument: String? = nil
        if components.count == 2 {
            argument = input.components(separatedBy: " ")[1]
        }
        
        print("\(command) : \(argument ?? "none")")
        
        let messages = files!.count
        var size = 0
        var sizes: [Int] = []
        for file in files! {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: file.relativePath)
                let fileSize = attributes[FileAttributeKey.size] as? NSNumber ?? NSNumber(0)
                size = size + fileSize.intValue
                sizes.append(fileSize.intValue)
            } catch {
                print(error)
                continue
            }
        }
        
        switch command {
        case "STAT":
            print("Stat cmd")
            let msg = "+OK \(messages) \(size)\n"
            msg.write(connection)
        case "LIST":
            print("List cmd")
            var msg = "+OK \(messages) Messages (\(size) octets)\n"
            var i = 1
            for _ in files! {
                msg.append("\(i) \(sizes[i - 1])\n")
                i = i + 1
            }
            msg.append(".\n")
            msg.write(connection)
        case "RETR":
            print("RETR cmd")
                        
            if Int(argument!.components(separatedBy: "\r")[0]) == nil {
                print("fuck")
                print(argument ?? "No argument!")
                break
            }
            
            let argAsInt = Int(argument!.components(separatedBy: "\r")[0])! - 1
            
            var msg = "+OK \(sizes[argAsInt]) octets \n"
            var contents: String?
            do {
                contents = try String(contentsOf: files![argAsInt])
            } catch {
                print(error)
                break
            }
            msg.append(contents ?? "ERROR")
            msg.append("\n.\n")
            msg.write(connection)
        case "DELE":
            if Int(argument!.components(separatedBy: "\r")[0]) == nil {
                print("fuck")
                print(argument ?? "No argument!")
                break
            }
            
            let argAsInt = Int(argument!.components(separatedBy: "\r")[0])! - 1
            
            let msg = "+OK message \(argAsInt + 1) deleted\n"
            
            do {
                try FileManager.default.removeItem(at: files![argAsInt])
            } catch {
                print(error)
            }
            
            msg.write(connection)
        case "QUIT":
            let msg = "+OK have a good day\n"
            msg.write(connection)
            connection.close()
        default:
            let msg = "-ERR I dont know that command \n"
            msg.write(connection)
        }
    }
    
}
