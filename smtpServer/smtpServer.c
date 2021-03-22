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
//    getaddrinfo(NULL, "25", &info, &res);
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

    printf("Starting to listen\n");
    while (1) {
        addr_size = sizeof clientAddr;
        int acceptStatus = accept(sock, (struct sockaddr *)&clientAddr, &addr_size);
        // un need
        struct sockaddr_in *sin = (struct sockaddr_in *)&clientAddr;
        unsigned char *ip = (unsigned char *)&sin->sin_addr.s_addr;

        printf("%d.%d.%d.%d\n", ip[0], ip[1], ip[2], ip[3]);
        // end un need
        
        if (acceptStatus == -1)
            continue;

        int pid;
        if ((pid = fork()) == -1)
            close(acceptStatus);
        else if (pid > 0)
            close(acceptStatus);
        else if (pid == 0)
            handleCommand(acceptStatus);

   }
} 

void handleCommand (int sock) {
    write(sock, "220 ESMTP Juliette's SMTP Server \n", strlen("220 ESMTP Juliette's SMTP Server \n"));

    bool dataMode = false;
    time_t now = time(0);
    char fileName[40];
    snprintf(fileName, sizeof fileName, "email%ld.txt", now);
    FILE *dataFile;

    while (1) {
        printf("loop\n");
        // First, we need to get input
        char buff[1000];
        int res = read(sock, buff, sizeof buff);
//        printf("%s", buff);
        // If we're in data mode we need to write instead of parse commands so that takes place first
        if (dataMode) {
            // So we need to conver the buffer to a char pointer as the buffer tends to have weird characters that we would rather not have in a file
            char *diffBuff = malloc(res * sizeof(char *));
            diffBuff = buff;
            // Writing
            fprintf(dataFile, "%s", diffBuff);
            if (strstr(diffBuff, ".\r\n") != NULL) {
                dataMode = false;
                char msg[7] = "250 Ok\n";
                write(sock, msg, sizeof msg);
                continue;
            }
            continue;
        }
        // Now we need to parse the command
        // Getting first four characters
        char firstFour[4] = "";
        strncpy(firstFour, buff, sizeof firstFour);
        // Getting command if its in YAML like form
        char splitter[] = ":";
        char *command = strtok(buff, splitter);
        // Now checking for command
        if (strstr(firstFour, "DATA") != NULL) {
            char msg[36] = "354 End data with <CR><LF>.<CR><LF>\n";
            write(sock, msg, sizeof msg);
            dataMode = true;
            dataFile = fopen(fileName, "w+");
            if (dataFile == NULL) {
                perror("Unable to create file, ");
                exit(0);
            }
            printf("== SENT COMMAND DATA ==\n");
        } else if (strstr(firstFour, "EHLO") != NULL || strstr(firstFour, "HELO") != NULL) {
            char msg[10] = "250 Hello\n";
            write(sock, msg, sizeof msg);
            printf("== SENT COMMAND HELLO ==\n");
        } else if (strstr(firstFour, "QUIT") != NULL) {
            printf("== SENT COMMAND QUIT ==\n");
            printf("closing socket\n");
            close(sock);
            printf("Closed socket\n");
            fclose(dataFile);
            printf("Closed data file\n");
            return;
            printf("This should not run\n");
        } else if (strstr(command, "MAIL FROM") != NULL) {
            char msg[7] = "250 OK\n";
            write(sock, msg, sizeof msg);
            printf("== SENT COMMAND FROM ==\n");
        } else if (strstr(command, "RCPT TO") != NULL) {
            char msg[7] = "250 Ok\n";
            write(sock, msg, sizeof msg);
            printf("== SENT COMMAND TO ==\n");
        } else {
            char msg[22] = "500 I don't know that\n";
            write(sock, msg, sizeof msg);
            printf("== SENT COMMAND NOT KNOWN ==\n");
        }
    }
}
