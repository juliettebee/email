#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>

typedef struct email {
    char *from;
    char *to;
    char *data;
    char *fromip;
    bool dataMode;
} Email;

void smtpServer();
void helloCommand();
void dataCommand(int file, Email *email); 
void mailFromCommand(int file, Email *email, char *args);
void handleRequest(int accepting);
