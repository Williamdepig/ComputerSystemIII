#include "ctype.h"

int isalnum(int c) {
  return isalpha(c) || isdigit(c);
}

int isalpha(int c) {
  return islower(c) || isupper(c);
}

int iscntrl(int c) {
  return (c >= 0 && c <= 0x1f) || c == 0x7f;
}

int isdigit(int c) {
  return c >= '0' && c <= '9';
}

int isgraph(int c) {
  return c >= 0x21 && c <= 0x7e;
}

int islower(int c) {
  return c >= 'a' && c <= 'z';
}

int isprint(int c) {
  return c >= 0x20 && c <= 0x7e;
}

int ispunct(int c) {
  return isprint(c) && !isalnum(c) && !isspace(c);
}

int isspace(int c) {
  return c == ' ' || (c >= '\t' && c <= '\r');
}

int isupper(int c) {
  return c >= 'A' && c <= 'Z';
}

int isxdigit(int c) {
  return isdigit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
}

int isascii(int c) {
  return c >= 0 && c <= 0x7f;
}

int isblank(int c) {
  return c == ' ' || c == '\t';
}

int tolower(int c) {
  if (isupper(c)) {
    return c + ('a' - 'A');
  }
  return c;
}

int toupper(int c) {
  if (islower(c)) {
    return c - ('a' - 'A');
  }
  return c;
}
