---
tags: [ 'perl', 'ioctl','syscall', 'unix','systems programming' ]
title: Fun with ioctl and syscall in Perl
---

Theres a seldom used and not amazingly documented section of Perl that few will
ever have a use for, and the first time you use it when you do, you'll find a bunch of headaches
you'll have to solve first.

I'm not pretending to be an expert here, but I've just worked (with much assistance from p5p) out enough to get these things working for me.

Typically, for portable maintainable code in Perl, you will probably avoid these functions, (and when you
dig deep into the details, you'll probably be more convinced), and you'd be better off implementing the related
code in XS, but the `syscall`,`fcntl` and `ioctl` functions can still be conveninent in constrained
conditions like you might encounter if you don't have a compiler handly.

And All of these functions come with a moderate amount of performance penalty incurred with calling them
from Perl Space, so they'll be significantly less performant than their equivalent XS code.

%= heading 2, q[Native C Calls from Perl Space]

There's 3 Primary functions I'll cover here that all share some aspects in common. 

- They're all bascially wrappers for similar functions available in C
- They all require being passed arguments which map to C equivalents.
- They all require some mechanism to derive certain "magic numbers" that the Kernel recognises.
- They all require some kind of manual data packing as part of the interface.
- All existing documentation talks about `h2ph` being recommended for its use, which is a bit of a missleading dead-end in reality.

%= heading 3, q[`syscall( NUMBER, LIST )`]

- [perldoc -f syscall](http://perldoc.perl.org/functions/syscall.html)

This function is mostly identical to [`man 2 syscall`](http://manpages.ubuntu.com/manpages/wily/en/man2/syscall.2.html), and it can be used to invoke any number of system calls.

For instance, with the right magic numbers you can query the Kernel for a high resolution clock,
the same otherwise provided by [`Time::HiRes`](https://metacpan.org/pod/Time::HiRes).

%= highlight C => include 'sysctl_01.c'

And there's a great volume of these syscalls you can use if you understand how,
taking a look in [`man 2 syscalls`](http://manpages.ubuntu.com/manpages/wily/en/man2/syscalls.2.html)

Sure, all of the items listed in `man 2 syscalls` are available natively in C, and in C,
calling the provided functions instead of using the syscall interface is surely preferred.

But in Perl, you might not necessarily have all those.

For instance, [`sched_yield`](http://manpages.ubuntu.com/manpages/wily/en/man2/sched_yield.2.html) might be something you want to do from Perl,
but there's no equivalent function for that (that I know of at least, though there are [3rd Party Extensions](https://metacpan.org/pod/POSIX::SchedYield))

All you need to know is how to call the equivalent of

%= highlight C => include 'sysctl_02.c'

And you've got that done.

%= heading 3, q[`ioctl( FILEHANDLE, NUMBER, SCALAR )`]

- [perldoc -f ioctl](http://perldoc.perl.org/functions/ioctl.html)

`ioctl()` is actually implemented in terms of `syscall()` under the hood, as you may have noticed in the `man 2 syscall` listing. `ioctl()` is mostly identical to [`man 2 ioctl`](http://manpages.ubuntu.com/manpages/wily/en/man2/ioctl.2.html), and it can be used to poke into APIs of devices attached on the other end of a `filehandle`, for instance:

- You can perform an ioctl() on an [`opendir`'d directory](http://manpages.ubuntu.com/manpages/wily/en/man3/opendir.3.html)
- You can perform an ioctl() on an [`open`'d file handle](http://manpages.ubuntu.com/manpages/wily/en/man2/open.2.html)
- You can perform an ioctl() on a STD Filehandle like `STDERR`/`STDOUT`/`STDIN`

