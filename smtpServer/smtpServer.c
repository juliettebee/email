#include "../Main.h"

void smtpServer (ServerConfig config) {
    struct sockaddr_storage clientAddr;
    socklen_t addrSize;
    struct addrinfo info, *res;
    memset(&info, 0, sizeof info);
    info.ai_family = AF_UNSPEC;
    info.ai_socktype = SOCK_STREAM;
    info.ai_flags = AI_PASSIVE;

    // Setting port
    getaddrinfo(NULL, "2525", &info, &res);

    int sock = socket(res->ai_family, res->ai_socktype, res->ai_protocol); 
    if (sock == -1) {
        perror("Unable to create socket, ");
        exit(0);
    }

    // Now lets bind it 
    int binder = bind(sock, res->ai_addr, res->ai_addrlen); 
    if (binder == -1) {
        perror("Unable to bind, ");
        exit(0);
    }
    // Listening for remote connections
    int listener = listen(sock, 5);
    if (listener == -1) {
        perror("Unable to listen, ");
        exit(0);
    } 

    printf("Starting to listen\n");

    while (1) {
        addrSize = sizeof clientAddr;
        int acceptStatus = accept(sock, (struct sockaddr *)&clientAddr, &addrSize);

        if (acceptStatus == -1)
            continue;

        int pid = fork();

        // Seeing if fork failed 
        if (pid == -1)
            close(acceptStatus); // If it is, drop the socket, not best solution
        // Now seeing if we're the child
        else if (pid == 0)
            handleSocket(acceptStatus, config); // If we are the child, handle the connection
        // Now seeing if we're the parent
        else
            close(acceptStatus); // If we are, close the socket as we don't need it
        
    }

}

void handleSocket (int sock, ServerConfig config) {
    char helloMessage[34] = "220 ESMTP Juliette's SMTP Server \n";
    write(sock, helloMessage, sizeof helloMessage);

    int dataMode = 0;

    time_t now = time(0);
    char fileName[40];
    snprintf(fileName, sizeof fileName, "email%ld.txt", now);
    int dataFile;

    while (1) {
        if (dataMode) {
            char buffer[1010];
            memset(buffer, '\0', 1009);
            int length = recv(sock, &buffer, sizeof buffer - 1, 0);

            if (length == -1)
               continue;
            
           printf("%s", buffer); 
           write(dataFile, buffer, sizeof buffer);
           if (strstr(buffer, ".\r\n") != NULL) { 
               dataMode = 0;
               char msg[8] = "250 OK\n";
               write(sock, msg, sizeof msg);
           }
           continue;
        }

        // Reading
        char buffer[514]; 
        memset(buffer, '\0', 513);
        int length = recv(sock, &buffer, sizeof buffer - 1, 0);  
        if (length == -1) 
            continue;

        // Parsing commands
        // Four character commands
        char firstFour[6];
        strncpy(firstFour, buffer, 4);
        firstFour[5] = '\0';
        // field value style
        char *field = strtok(buffer, ":");
        char *value = strtok(NULL, ":");

        printf("First four %s\n", firstFour);
        printf("Field : %s ... Value : %s\n", field, value);
        if (strcasestr(firstFour, "ehlo") != NULL || strcasestr(firstFour, "helo") != NULL) {
            char msg[11] = "250 Hello\n";
            write(sock, msg, strlen(msg));
            continue;
        } else if (strcasestr(firstFour, "data") != NULL) {
            dataMode = 1;
            char msg[37] = "354 End data with <CR><LF>.<CR><LF>\n";
            write(sock, msg, strlen(msg));
            // Creating the file
            dataFile = open(fileName, O_WRONLY | O_CREAT, 0640);
            continue;
        } else if (strcasestr(firstFour, "quit") != NULL) {
            close(sock);
            close(dataFile);
            printf("quit!\n");
            return;
        } else if (strstr(field, "MAIL FROM") != NULL) {
            char msg[8] = "250 OK\n";
            write(sock, msg, strlen(msg));
        } else if (strstr(field, "RCPT TO") != NULL) {
            // Checking to see if who the email was sent is under the config domain
            strtok(value, "@");
            char *domain = strtok(NULL, "@");
            int i = 0;
            while (domain[i] != '\0') {
                if (domain[i] == '>')
                    domain[i] = '\0';
                i++;
            }

            printf("domain : %s\n", domain);

            if (strcmp(domain, config.domain) == 0) {
                char msg[8] = "250 OK\n";
                write(sock, msg, strlen(msg));
            } else {
                // I dont want other peoples emails 
                char msg[30] = "551 we aren't a relay server\n";
                write(sock, msg, strlen(msg));
                // todo: update closing
                close(sock);
                close(dataFile);
            }
        } else {
            char msg[23] = "500 I don't know that\n";
            write(sock, msg, strlen(msg));
        }

    }
}
