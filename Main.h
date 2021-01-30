#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>
#include <netdb.h>
#include <stdlib.h>

typedef struct email {
    char *from;
    char *fromip;
    bool dataMode;
    char to[1000];
} Email;

void smtpServer();
void helloCommand();
void handleRequest(int accepting);
void dataCommand(int file, Email *email); 
void mailFromCommand(int file, Email *email, char *args);
void rcptToCommand(int file, Email *email, char *args);
