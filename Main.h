#include <stdio.h>
#include <string.h>
#include <sys/socket.h>

typedef struct {
    char domain[64];
} ServerConfig;

void smtpServer(ServerConfig config);
