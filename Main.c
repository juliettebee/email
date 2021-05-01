#include "Main.h"

int main (int argc, char *argv[]) {
    // Getting config
    if (argc < 2) {
        printf("✉️  Juliette's SMTP server\n./email [Domain] [Discord style webhook url (Optional)]\n");
        return 0;
    }

    if (strlen(argv[1]) > 64) {
        printf("The domain cannot be above 64 characters!\n");
        return 0;
    }

    ServerConfig config = {0};
    strcpy(config.domain, argv[1]);
    
    // todo: daemon this
    smtpServer(config);
}
