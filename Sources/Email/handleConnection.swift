//
//  handleConnection.swift
//  
//
//  Created by Juliette on 6/17/21.
//

import Foundation

func handleConnection (connection: JSocket, folder: URL) {
    "220 ESMTP Juliette's SMTP Server \n".write(connection)
}
