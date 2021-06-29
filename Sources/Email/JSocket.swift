//
//  JSocket.swift
//  
//
//  Created by Juliette on 6/17/21.
//

import Foundation
#if os(Linux)
import Glibc
#elseif os(macOS)
import Darwin
#endif

struct JSocket {
    let fd: Int32
    var closed = false
    
    public func read () -> String {
        var buffer = [UInt8](repeating: 0, count: 2000)
        
        #if os(Linux)
        let result = Glibc.read(fd, &buffer, 2000)
        #elseif os(macOS)
        let result = Darwin.read(fd, &buffer, 2000)
        #endif
        
        if result == 0 {
            return ""
        } else if result == -1 {
            return ""
        } else {
            let strResult = String(cString: buffer)
            return strResult
        }
    }
    
    public mutating func close () {
        #if os(Linux)
        Glibc.close(fd)
        #elseif os(macOS)
        Darwin.close(fd)
        #endif
    
        self.closed = true
        
        log("Closed connection")
    }
}

extension String {
    func write (_ fd: inout JSocket) {
        
        if fd.closed {
            return
        }
        
        #if os(Linux)
        let out = Glibc.write(fd.fd, self, self.lengthOfBytes(using: .utf8))
        #elseif os(macOS)
        let out = Darwin.write(fd.fd, self, self.lengthOfBytes(using: .utf8))
        #endif
        
        if out == -1 && errno == 32 {
            // If it sigpipes close the socket so its marked as closed and we no longer write to it
            fd.close()
        } else if out == -1 {
            let str = String(cString: strerror(errno))
            log("Error writing \(str) (\(errno))")
        }
    }
}
