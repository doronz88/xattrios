#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <sys/xattr.h>

#ifndef HEXDUMP_COLS
#define HEXDUMP_COLS 16
#endif

void hexdump(const char *prefix, void *mem, unsigned int len) {
  unsigned int i, j;

  for (i = 0; i < len + ((len % HEXDUMP_COLS) ? (HEXDUMP_COLS - len % HEXDUMP_COLS) : 0); i++) {
    /* print offset */
    if (i % HEXDUMP_COLS == 0) {
      printf("%s0x%06x: ", prefix, i);
    }

    /* print hex data */
    if (i < len) {
      printf("%02x ", 0xFF & ((char *)mem)[i]);
    } else {
      printf("   ");
    }

    /* print ASCII dump */
    if (i % HEXDUMP_COLS == (HEXDUMP_COLS - 1)) {
      for (j = i - (HEXDUMP_COLS - 1); j <= i; j++) {
        if (j >= len) {
          printf(" ");
        } else if (isprint(((char *)mem)[j])) {
          printf("%c", 0xFF & ((char *)mem)[j]);
        } else {
          printf(".");
        }
      }
      printf("\n");
    }
  }
}

bool isliteral(const char *buf, size_t size) {
  for (size_t i = 0; i < size; ++i) {
    if (!isprint(buf[i]) && buf[i] != '_') {
      return false;
    }
  }
  return true;
}

int main(int argc, char *argv[], char *envp[]) {
  if (argc < 2) {
    printf("%s <filename> [filename2] [filename3] [...]\n", argv[0]);
    return 1;
  }

  char **filenames = &argv[1];
  size_t file_count = argc - 1;

  for (size_t i = 0; i < file_count; ++i) {
    printf("=========================================\n");
    printf("Filename: %s\n", filenames[i]);

    char xattributes_names[1024] = {0};
    char value[1024] = {0};

    char *p_current = xattributes_names;
    if (listxattr(filenames[i], xattributes_names, sizeof(xattributes_names), 0) < 0) {
      printf("listxattr failed: %s\n", filenames[i]);
      continue;
    }

    while (strlen(p_current)) {
      printf("%s: ", p_current);

      ssize_t len = getxattr(filenames[i], p_current, value, sizeof(value), 0, 0);
      if (len < 0) {
        printf("getxattr failed\n");
        continue;
      }

      if (isliteral(value, len)) {
        printf("%s\n", value);
      } else {
        printf("\n");
        hexdump("    ", value, len);
      }

      p_current += strlen(p_current) + 1;
    }
  }

  return 0;
}
