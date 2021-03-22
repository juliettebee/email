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
#include <sys/stat.h>

void smtpServer();
void handleCommand (int);
