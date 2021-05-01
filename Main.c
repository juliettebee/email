#include "Main.h"

int main (int argc, char *argv[]) {
    // Getting config
    if (argc < 3) {
        printf("✉️  Juliette's SMTP server\n./email [Email storage path] [Domain]\n");
        return 0;
    }

    if (strlen(argv[2]) > 64) {
        printf("The domain cannot be above 64 characters!\n");
        return 0;
    }

    ServerConfig config = {0};
    strcpy(config.domain, argv[2]);

    printf("%s", argv[1]);
    // Creating a deamon
    pid_t process_id = 0;
    pid_t sid = 0;
    process_id = fork();
    if (process_id < 0) {
        printf("Error in forking!");
        exit(-1);
    }
    if (process_id > 0) {
        printf("Bye!");
        exit(0);
    }
    umask(0);
    sid = setsid();
    if (sid < 0)
        exit(-1);

    chdir(argv[1]);
    close(STDIN_FILENO);
    close(STDOUT_FILENO);
    close(STDERR_FILENO);
        
    // todo: daemon this
    smtpServer(config);
}
