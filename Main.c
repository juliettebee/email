#include "Main.h"

int main( int argc, char *argv[] ) {
    if (argc != 2) {
        printf("Please include the folder where you want emails to go as the argument!\n");
        exit(-1);
    }
    // Creating a deamon
    pid_t process_id = 0;
    pid_t sid = 0;
    // Create child process
    process_id = fork();
    // Checking for error
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
    if(sid < 0)
        exit(-1);
    chdir(argv[1]);
    close(STDIN_FILENO);
    close(STDOUT_FILENO);
    close(STDERR_FILENO);
    smtpServer();
    return 0;
}
