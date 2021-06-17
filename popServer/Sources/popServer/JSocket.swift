//
//  JSocket.swift
//  
//
//  Created by Juliette on 6/5/21.
//

import Foundation
#if os(Linux)
import Glibc
#elseif os(macOS)
import Darwin
#endif

struct JSocket {
    let fd: Int32
    
    public func read () -> String {
        var buffer = UnsafeMutableRawPointer.allocate(byteCount: 2000,alignment: MemoryLayout<CChar>.size)
        
        #if os(Linux)
        let result = Glibc.read(fd, &buffer, 2000)
        #elseif os(macOS)
        let result = Darwin.read(fd, &buffer, 2000)
        #endif
        
        if result == 0 {
            return ""
        } else if result == -1 {
            print("Error: \(errno)")
            return ""
        } else {
            let strResult = withUnsafePointer(to: &buffer) {
              $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: result)) {
                String(cString: $0)
              }
            }
            return strResult
        }
    }
    
    public func close () {
        #if os(Linux)
        Glibc.close(fd)
        #elseif os(macOS)
        Darwin.close(fd)
        #endif
    }
}

extension String {
    func write (_ fd: JSocket) {
        #if os(Linux)
        let out = Glibc.write(fd.fd, self, self.lengthOfBytes(using: .utf8))
        #elseif os(macOS)
        let out = Darwin.write(fd.fd, self, self.lengthOfBytes(using: .utf8))
        #endif
        
        print(out)
        
        if out == -1 {
            print("Error \(errno)")
        }
    }
}
