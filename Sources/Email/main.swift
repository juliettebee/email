import Foundation

let arguments = CommandLine.arguments

if arguments.count < 3 {
    print("\(arguments[0]) [Path to email storage folder] [Domain]")
    exit(EXIT_SUCCESS)
}

let folder = URL(string: CommandLine.arguments[1])!
let domain = CommandLine.arguments[2]

let socketFd = socket(2, 1, 6)

if socketFd == -1 {
    log("Error creating socket, \(errno)")
    exit(EXIT_FAILURE)
}

#if os(Linux)
var hints = addrinfo(ai_flags: AI_PASSIVE, ai_family: AF_INET, ai_socktype: Int32(1), ai_protocol: 0, ai_addrlen: 0, ai_addr: nil, ai_canonname: nil, ai_next: nil)
#elseif os(macOS)
var hints = addrinfo(ai_flags: AI_PASSIVE, ai_family: AF_INET, ai_socktype: SOCK_STREAM, ai_protocol: 0, ai_addrlen: 0, ai_canonname: nil, ai_addr: nil, ai_next: nil)
#endif

var res: UnsafeMutablePointer<addrinfo>? = nil
let addrInfoResult = getaddrinfo(nil, "2525", &hints, &res)

if addrInfoResult != 0 {
    log("Error getting address info: \(errno)")
    exit(EXIT_FAILURE)
}

guard let addr = res?.pointee.ai_addr, let addrLen = res?.pointee.ai_addrlen else {
    log("Unable to get socket address")
    exit(EXIT_FAILURE)
}

let bindResult = bind(socketFd, addr, socklen_t(addrLen))

if bindResult != 0 {
    log("Error binding, \(errno)")
    exit(EXIT_FAILURE)
}

let list = listen(socketFd, 10)

if list == -1 {
    log("Error listening")
    exit(EXIT_FAILURE)
}

log("Ready!")

//sigignore(SIGPIPE)
signal(SIGPIPE, SIG_IGN)

while (true) {
    var addr = sockaddr()
    var addr_len: socklen_t = 0
    
    let client = accept(socketFd, &addr, &addr_len)
    
    if client == -1 {
        log("Error accepting client")
    }
    
    let queue = DispatchQueue(label: "newSocket")
    queue.async {
        log("New connection")
        var jsock = JSocket(fd: client)
        handleConnection(connection: &jsock, folder: folder, domain: domain)
    }
}
