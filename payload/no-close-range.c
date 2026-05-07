/* NH_SETUP_VERSION: 2.0 default */
/* Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default */
#define _GNU_SOURCE
#include <errno.h>

int close_range(unsigned int first, unsigned int last, int flags)
{
    (void)first;
    (void)last;
    (void)flags;
    errno = ENOSYS;
    return -1;
}
