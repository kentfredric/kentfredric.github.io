#include <unistd.h>
#include <stdio.h>
#include <sys/syscall.h>

int main() {
  syscall(SYS_sched_yield);
}
