#include "Main.h"

int main (int argc, char *argv[]) {
    // Getting config
    if (argc < 2) {
        printf("✉️  Juliette's SMTP server\n./email [Domain]\n");
        return 0;
    }

    if (strlen(argv[1]) > 64) {
        printf("The domain cannot be above 64 characters!\n");
        return 0;
    }

    ServerConfig config;
    strcpy(config.domain, argv[1]);
    printf("%s", config.domain);
    // todo: daemon this
    smtpServer(config);
}
