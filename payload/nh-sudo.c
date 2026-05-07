/* NH_SETUP_VERSION: 2.0 default */
/* Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default */
#include <errno.h>
#include <grp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int is_skip_option(const char *arg) {
    return strcmp(arg, "-n") == 0 ||
           strcmp(arg, "-E") == 0 ||
           strcmp(arg, "-H") == 0 ||
           strcmp(arg, "-S") == 0 ||
           strcmp(arg, "-k") == 0 ||
           strcmp(arg, "-K") == 0;
}

int main(int argc, char **argv) {
    int i = 1;

    while (i < argc) {
        if (strcmp(argv[i], "--") == 0) {
            i++;
            break;
        }
        if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "-l") == 0) {
            return 0;
        }
        if (is_skip_option(argv[i])) {
            i++;
            continue;
        }
        if ((strcmp(argv[i], "-u") == 0 || strcmp(argv[i], "-g") == 0) && i + 1 < argc) {
            i += 2;
            continue;
        }
        if (argv[i][0] == '-') {
            i++;
            continue;
        }
        break;
    }

    if (setgroups(0, NULL) != 0 && errno != EPERM) {
        perror("setgroups");
        return 1;
    }
    if (setgid(0) != 0) {
        perror("setgid");
        return 1;
    }
    if (setuid(0) != 0) {
        perror("setuid");
        return 1;
    }

    setenv("HOME", "/root", 1);
    setenv("USER", "root", 1);
    setenv("LOGNAME", "root", 1);
    setenv("SHELL", "/usr/bin/zsh", 1);
    setenv("PATH", "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", 1);

    if (i >= argc) {
        execl("/usr/bin/zsh", "zsh", "-l", (char *)NULL);
        execl("/bin/bash", "bash", "--login", (char *)NULL);
        execl("/bin/sh", "sh", (char *)NULL);
        perror("exec shell");
        return 127;
    }

    execvp(argv[i], &argv[i]);
    perror(argv[i]);
    return 127;
}
