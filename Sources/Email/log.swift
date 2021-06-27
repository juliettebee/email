//
//  handleConnection.swift
//  
//
//  Created by Juliette on 6/27/21.
//

import Foundation

func log (_ message: String) {
    let logFile = URL(string: FileManager.default.currentDirectoryPath)!.appendingPathComponent("logFile")
    var contents = ""
    
    do {
        contents = try String(contentsOfFile: logFile.path)
        contents = contents.appending(message.appending("\n"))
    } catch {
        print(error)
        contents = message.appending("\n")
    }
    
    do {
        try contents.write(toFile: logFile.path, atomically: false, encoding: .utf8)
    } catch {
        print("ERROR LOGGING, \(error)")
        exit(EXIT_FAILURE)
    }
    
    print(message)
}
