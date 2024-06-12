#include "syscall.h"
#include "string.h"
#include "stdio.h"

#define WAIT_TIME 0x0FFFFFFF

void wait(unsigned int n) {
  for (volatile unsigned int i = 0; i < n; i++)
    ;
}

/*
 * Test your `Page Fault Handler` using the following `main`s
 */
/* PFH main #1 */
// unsigned long global_increment = 0;
// int main(void) {
//   register const unsigned long current_sp asm("sp");
//   while (1) {
//     printf("\e[44m[U]\e[0m pid: %d, sp is %lx, increment: %lu\n", getpid(), current_sp, global_increment++);
//     wait(WAIT_TIME);
//   }

//   return 0;
// }

/* PFH main #2 */
// const int val = 0x12345678;
// char global_placeholder[0x2000];
// unsigned long global_increment = 0;

// int main(void) {
//   while (1) {
//     printf("\e[44m[U]\e[0m pid: %d, val = 0x%x, increment: %lu\n", getpid(), val, global_increment++);
//     wait(WAIT_TIME);
//   }
// }

/*
 * Test your `fork` using the following `main`s
 */
/* Fork main #1 */
// int global_variable = 0;

// int main(void) {
//   // int local_variable = 0;
//   int pid;

//   pid = fork();
//   printf("\e[44m[U]\e[0m [PID = %d] fork returns %d\n", getpid(), pid);

//   if (pid == 0) {
//     while (1) {
//       printf("[U-CHILD] pid: %d is running! global: %d\n", getpid(), global_variable++);
//       wait(WAIT_TIME);
//     }
//   } else {
//     while (1) {
//       printf("[U-PARENT] pid: %d is running! global: %d\n", getpid(), global_variable++);
//       wait(WAIT_TIME);
//     }
//   }
//   return 0;
// }

// /* Fork main #2 */
// int global_variable = 0;
// char placeholder[8192];

// int main(void) {
//   int pid;

//   for (int i = 0; i < 3; i++) {
//     printf("[U] pid: %d is running! global_variable: %d\n", getpid(), global_variable++);
//   }

//   placeholder[4096] = 'S';
//   placeholder[4097] = 'y';
//   placeholder[4098] = 's';
//   placeholder[4099] = '3';
//   placeholder[4100] = '-';
//   placeholder[4101] = 'L';
//   placeholder[4102] = 'a';
//   placeholder[4103] = 'b';
//   placeholder[4104] = '5';
//   placeholder[4105] = '\0';

//   pid = fork();

//   if (pid == 0) {
//     printf("[U-CHILD] pid: %d is running! Message: %s (0x%x)\n", getpid(), &placeholder[4096], &placeholder[4096]);
//     while (1) {
//       printf("[U-CHILD] pid: %d is running! global_variable: %d\n", getpid(), global_variable++);
//       wait(WAIT_TIME);
//     }
//   } else {
//     printf("[U-PARENT] pid: %d is running! Message: %s (0x%x)\n", getpid(), &placeholder[4096], &placeholder[4096]);
//     while (1) {
//       printf("[U-PARENT] pid: %d is running! global_variable: %d\n", getpid(), global_variable++);
//       wait(WAIT_TIME);
//     }
//   }
//   return 0;
// }

/* Fork main #3 */
int global_variable = 0;

int main(void) {
  printf("\e[44m[U]\e[0m [PID = %d] is running! global_variable: %d\n", getpid(), global_variable++);
  fork();
  fork(); // multiple references to one page

  printf("\e[44m[U]\e[0m [PID = %d] is running! global_variable: %d\n", getpid(), global_variable++);
  fork();

  while (1) {
    printf("\e[44m[U]\e[0m [PID = %d] is running! global_variable: %d\n", getpid(), global_variable++);
    wait(WAIT_TIME);

    if (getpid() == 3 && global_variable == 3) {
      execve("now_this_can_be_any_string", NULL, NULL);
    }

    if (getpid() == 4 && global_variable == 4) {
      exit(getpid() << 3);
    }

    if (getpid() == 5 && global_variable == 5) {
      printf("Killing process 1\n");
      kill(1, 9);
    }
  }
}

/* Fork main #4 */
// #define LARGE 1024

// int global_variable = 0;
// unsigned long something_large_here[LARGE] = {0};

// int fib(int times) {
//   if (times <= 2) {
//     return 1;
//   } else {
//     return fib(times - 1) + fib(times - 2);
//   }
// }

// int main(void) {
//   for (int i = 0; i < LARGE; i++) {
//     something_large_here[i] = i;
//   }

//   int pid = fork();
//   printf("\e[44m[U]\e[0m fork returns %d\n", pid);

//   // char buf[20];
//   // printf("read a line:\n");
//   // fgets(buf, 20, stdin);
//   // printf("read: %s\n", buf);

//   const char *const str = pid == 0 ? "CHILD" : "PARENT";

//   while (1) {
//     printf("\e[44m[U-\e[34;47m%s\e[39;44m]\e[0m [PID = %d] fib(%d) = %d, arr[%d] = %lu\n", str, getpid(),
//            global_variable, fib(global_variable), LARGE - 1 - global_variable,
//            something_large_here[LARGE - 1 - global_variable]);
//     global_variable++;
//     wait(WAIT_TIME);
//   }
// }
