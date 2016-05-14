#include <unistd.h>
#include <stdio.h>
#include <sys/syscall.h>
#include <sys/time.h>

int main() {
  struct timeval buf;
  syscall(SYS_gettimeofday, &buf);
  printf("SYSCALL_NO:    %d\n", SYS_gettimeofday);
  printf("seconds:      %ld\n", buf.tv_sec      );
  printf("microseconds: %ld\n", buf.tv_usec     );
}
