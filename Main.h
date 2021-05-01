#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netdb.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>

typedef struct {
    char domain[64];
} ServerConfig;

void smtpServer (ServerConfig config);
void handleSocket (int sock, ServerConfig config);
