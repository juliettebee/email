import Foundation

let arguments = CommandLine.arguments

if arguments.count < 2 {
    print("\(arguments[0]) [Path to email storage folder]")
}

let folder = URL(string: CommandLine.arguments[1])!

let socketFd = socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP)

if socketFd == -1 {
    print("Error creating socket")
    exit(EXIT_FAILURE)
}

var hints = addrinfo(ai_flags: AI_PASSIVE, ai_family: AF_UNSPEC, ai_socktype: SOCK_STREAM, ai_protocol: 0, ai_addrlen: 0, ai_canonname: nil, ai_addr: nil, ai_next: nil)
var servinfo: UnsafeMutablePointer<addrinfo>? = nil
let addrInfo = getaddrinfo(nil, "2525", &hints, &servinfo)

if addrInfo != 0 {
    print("Error, \(errno)")
    exit(EXIT_FAILURE)
}

let bindResult = bind(socketFd, servinfo!.pointee.ai_addr, socklen_t(servinfo!.pointee.ai_addrlen))

if bindResult == -1 {
    print("Error, \(errno)")
    exit(EXIT_FAILURE)
}

let list = listen(socketFd, 10)

if list == -1 {
    print("Error listening")
    exit(EXIT_FAILURE)
}

while (true) {
    var addr = sockaddr()
    var addr_len: socklen_t = 0
    
    let client = accept(socketFd, &addr, &addr_len)
    
    if client == -1 {
        print("Error accepting client")
    }
    
    let queue = DispatchQueue(label: "newSocket")
    queue.async {
        print("New connection")
        handleConnection(connection: JSocket(fd: client), folder: folder)
    }
}

