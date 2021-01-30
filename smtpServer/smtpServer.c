#include "../Main.h"

void smtpServer() {
    // Creating file endpoint
    int socketStatus = socket(AF_INET, SOCK_STREAM, 0);
    if (socketStatus == -1) {
        printf("Error!");
        return;
    }
    // Binding
    struct sockaddr_in addr, clientAddr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(25);
    int bindStatus = bind(socketStatus, (struct sockaddr *) &addr, sizeof(addr));
    if (bindStatus == -1) {
        printf("Error!");
        return;
    }
    // Starting to listen
    int listenStatus = listen(socketStatus, 5);
    if (listenStatus == -1) {
        printf("Error!");
        return;
    }
    // Now lets start accepting!
    while (1) {
        char buff[1000];
        int accepting = accept(socketStatus, (struct sockaddr *) &addr, &clientAddr);
        if (accepting == -1) {
            printf("Error!");
            continue;
        }
        // Reading connection
        int readStatus = read(accepting, buff, sizeof(buff));
        printf("Buf : %s", buff);
        return;
    }
}
