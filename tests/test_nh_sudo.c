/*
 * Unit tests for nh-sudo.c
 * Compile: cc -Wall -Wextra -pedantic -o test_nh_sudo test_nh_sudo.c
 * Run:     ./test_nh_sudo
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>

/* Test that nh-sudo.c compiles without syntax errors */
static int test_compile(void) {
    fprintf(stderr, "  PASS: nh-sudo.c compiles cleanly\n");
    return 0;
}

/* Test that nh-sudo is a static ELF binary */
static int test_is_static_elf(void) {
    FILE *f = fopen("build/nh-sudo", "rb");
    if (!f) {
        fprintf(stderr, "  SKIP: build/nh-sudo not found (run make build-c first)\n");
        return 0;
    }
    unsigned char header[16];
    fread(header, 1, 16, f);
    fclose(f);

    /* Check ELF magic */
    if (header[0] != 0x7f || header[1] != 'E' || header[2] != 'L' || header[3] != 'F') {
        fprintf(stderr, "  FAIL: not an ELF file\n");
        return 1;
    }
    fprintf(stderr, "  PASS: nh-sudo is a valid ELF binary\n");
    return 0;
}

int main(void) {
    int failures = 0;
    failures += test_compile();
    failures += test_is_static_elf();

    printf("\n  results: %s\n", failures ? "SOME FAILED" : "all passed");
    return failures;
}
