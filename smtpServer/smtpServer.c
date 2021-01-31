#include "../Main.h"

void smtpServer() {
    // We need this for accepting 
    struct sockaddr_storage clientAddr;
    socklen_t addr_size;
    // Creating a struct that contains info 
    struct addrinfo info, *res;
    memset(&info, 0, sizeof info); // TODO: free info
    info.ai_family = AF_UNSPEC;
    info.ai_socktype = SOCK_STREAM;
    info.ai_flags = AI_PASSIVE;
    // Setting port
    getaddrinfo(NULL, "2525", &info, &res); // Port 25 is reserved unless sudo
    // Creating the socket file
    int sock = socket(res->ai_family, res->ai_socktype, res->ai_protocol);    
    // Checking for error
    if (sock == -1) {
        perror("Unable to create socket, ");
        return;
    }
    // Now lets bind it 
    int binder = bind(sock, res->ai_addr, res->ai_addrlen); 
    if (binder == -1) {
        perror("Unable to bind, ");
        return;
    }
    // Listening for remote connections
    int listener = listen(sock, 5);
    if (listener == -1) {
       perror("Unable to listen, ");
       return;
    } 
    // Now lets accept them
    while (1) {
        addr_size = sizeof clientAddr;
        int acceptStatus = accept(sock, (struct sockaddr *)&clientAddr, &addr_size);
        if (acceptStatus == -1) {
            perror("Unable to accept, ");
            continue;
        }
        handleRequest(acceptStatus);
    }
    freeaddrinfo(res);
}

void handleRequest(int accepting) {
    // Creating a blank email
    Email email;
    email.dataMode = false;
    email.from = "";
    email.fromip = "";
    char first[33] = "220 ESMTP Juliette's SMTP server\n";
    write(accepting, first, sizeof(first)); 
    // Creating a blank file thats going to hold data
    time_t now = time(0);
    char fileName[40];
    snprintf(fileName, sizeof fileName, "email%ld.txt", now);
    FILE *dataFile = fopen(fileName, "w+");
    if (dataFile == NULL) {
        perror("Unable to create file, ");
        exit(0);
    }
    // Reading connection
    while(1) {
        char buff[1000] = "";
        printf("buff %s", buff);
        int readStatus = read(accepting, buff, sizeof(buff));
        // Checking if its in data mode
        if (email.dataMode) {
            printf("Data mode\n");
            // Terrible idea:
            // instead of writing data to email objc,
            // lets write it directly to file!
            fprintf(dataFile, "%s", buff);
            if (strstr(buff, ".\r\n") != NULL) {
                email.dataMode = false;            
                char message[7] = "250 Ok\n";
                write(accepting, message, sizeof(message));
            }
        }
        // Handling non normal commands
        char firstFour[4] = ""; // Each non normal command is 4 characters long so we're going to get the first four
        strncpy(firstFour, buff, sizeof(firstFour)); // Creating a sub string
        // Now checking
        if (strstr(firstFour, "EHLO") != NULL || strstr(firstFour, "HELO") != NULL) {
            helloCommand(accepting);
            continue;
        }
        if (strstr(firstFour, "DATA") != NULL) {
            dataCommand(accepting, &email);
            continue;
        }
        if (strstr(firstFour, "QUIT") != NULL) {
            close(accepting);
            fclose(dataFile);
            break;
        }
        // Spliting into command and args
        char splitter[] = ":";
        char *command = strtok(buff, splitter);
        char *args = strtok(NULL, splitter);
        if (args == NULL) // strtok can return null so we need dto check if its null and if it is set it to a blank string
            args = "";
        if (command == NULL)
            command = "";
        // Now lets handle normal commands
        if (strstr(command, "MAIL FROM") != NULL)
            mailFromCommand(accepting, &email, args);
        else if (strstr(command, "RCPT TO") != NULL)
            rcptToCommand(accepting, &email, args);
    }
}

void helloCommand(int file) {
    char message[23] = "220 Hello, Im juliette\n";
    write(file, message, sizeof(message));
}

void dataCommand(int file, Email *email) {
    email->dataMode = true;
    char message[36] = "354 End data with <CR><LF>.<CR><LF>\n";
    write(file, message, sizeof(message));
}

void mailFromCommand(int file, Email *email, char *args) {
    email->from = args;
    char message[7] = "250 Ok\n";
    write(file, message, sizeof(message));
}

void rcptToCommand(int file, Email *email, char *args) {
    snprintf(email->to, sizeof email->to, "%s%s", email->to, args);
    char message[7] = "250 Ok\n";
    write(file, message, sizeof(message));

}

