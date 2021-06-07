//
//  extensions.swift
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

extension String {
//    func write (_ fd: Int32) {
//        #if os(Linux)
//        Glibc.write(fd, self, self.lengthOfBytes(using: .ascii))
//        #elseif os(macOS)
//        Darwin.write(fd, self, self.lengthOfBytes(using: .ascii))
//        #endif
//    }
    
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
