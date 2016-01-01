---
tags: [ 'perl' ]
title: 'The Perl Jam 2: Lessons and Mistakes'
---

### `<"ARGV">` is evil

This is on the list of things that Netanel would have best served the Perl community by filing a bug when he discovered it.

    use strict;
    use warnings;

    @ARGV=( 'echo exploited|' );  # Pretend this came in through a CGI Request Parameters

    my $filehandle = magical_function(); # This function should return a filehandle, but the user did something
                                         # to trick magical_function to return the string "ARGV"
    
    while (<$filehandle>) {              # TRAP
      print $_;
    }

As long as `$filehandle` is in fact a FileHandle, nothing weird happens.

However, when $filehandle is a *string*, Perl does something it typically shouldn't: It treats the string as a *description* of a filehandle.

So for instance, if somebody had done:

    # NOTE: OLD STYLE CODE, DO NOT USE
    open *WAT, '-|', 'echo exploited|';

    my $filehandle = "WAT";

    while(<$filehandle>) {  }

Perl behaves as if you'd written:

    # NOTE: OLD STYLE CODE, DO NOT USE
    open *WAT, '-|', 'echo exploited|';

    my $filehandle = "WAT";

    while(<WAT>) {  }

In other Perl structures, this sort of transformation would be the kind of forbidden behaviour `strict` guards against:

    use strict; 
    use warnings;

    open *WAT, '|-', 'cat';
    my $handle = 'WAT';

    print { $handle } "Hi there"; # Can't use string ("WAT") as a symbol ref while "strict refs" in use

But the special value `ARGV` gets additionally complicated because it is "Magic" to `<>`

>     ARGV    The special filehandle that iterates over command-line filenames
>             in @ARGV. Usually written as the null filehandle in the angle
>             operator "<>". Note that currently "ARGV" only has its magical
>             effect within the "<>" operator; elsewhere it is just a plain
>             filehandle corresponding to the last file opened by "<>". In
>             particular, passing "\*ARGV" as a parameter to a function that
>             expects a filehandle may not cause your function to automatically
>             read the contents of all the files in @ARGV.

And that feature is implemented in terms of:

    foreach my $file ( @ARGV ) {
        open my $fh, $file;
    }

And that invokes the 2-arg-open magic, which means

    open my $fh, "echo hello |"

Excutes `echo hello` and emits its output into the filehandle `$fh`.

This specific feature is just one of those conveniences that makes a lot of sense on the command line where you can trust the person who populated
`@ARGV` is also you.

It allows you do to neat things like

      echo foo | perl ./script.pl - ./source_file_2                             # read all of stdin, then read a file when stdin is empty 
      perl ./script.pl ./sourcefile_1 ./source_file_2                           # read all of file one, then all of file 2
      perl ./script.pl ./source_file_1 ./source_file_2 'gzcat ./source_file_3|' # read all of files 1 and 2, and then read source file 3 while decompressing it

But this feature makes **NO** sense when you're on the internet using CGI, and the person passing your command line arguments is some person with an HTTP Client.

So on the Web using CGI, `strict` not doing its job escalates the problem to a security hole.

#### How do we fix it?

1. `use strict` really aught to imply `strict` here, and `<"ANYTHING">` should subsequently be a strictures error. Adding that change however risks
    breaking existing code with real world usecases, so a painful deprecation cycle might be necessary somehow.

2. A deeper question is wether or not the ARGV iterator is something that should be deemed "Sane" in 2015. I've clearly demonstrate it *can* be useful,
  but its also easy to demonstrate how it *can* pose a security risk in the event anyone is foolish enough to use `<>` or `<ARGV>` without fully realising
  the consequences. And this can be hard to even realise is a problem in a code security review.

  Were it me, given the lethality of those features, I would be wanting to deprecate both of those outside `perl -e`, which I believe is its primary usecase
  anyway, because it eliminates the need for multiple layers of quoting and lots of painful explicit calls to `open()`, which would grossly burden somebody
  who is simply trying to string together a short oneliner.

        perl -e 'while(<>) { print $_ }' 'file_a.txt' 'gzcat file_b.txt|' '-'

  This code without the magic of `<>` and `ARGV` gives you a significant amount of code to write.
  So much in fact, that simply thinking about what it would take made me give up even tempting to write one as an example in Perl, so instead,
  an equivalent in bash will have to suffice:

        cat file_a.txt <( gzcat file_b.txt ) /dev/stdin

  Maybe we can develop a pragma that regulates what 2-arg `open` ( and its effective internals in ARGV ) are permitted to do?
  ie:

        use Safe::Open2; # 2-arg-open assumes *all* arguments are filenames
        use Safe::Open2 qw/stdio/; # as with ^, but allows - based STDIO access
        use Safe::Open2 qw/exec stdio/; # allows pipe-exec and stdio

  I don't honestly know, and its messy, becuase you can't really afford to turn it on/off on a per-module basis, because the security
  risk has global implications regardless of where you write it, as its fundementally dealing with the gateway perl uses to interact with the rest
  of the operating system.

  So something with only lexical effect would be still born, but something with global effect could cause spooky action at a distance,
  because `ARGV` is implicitly global in nature, and unresolvably so.

  But either way

  - It makes sense to have this feature when you **know** you're working in a command line directly in a secure environement
  - It makes much less sense to a have this feature when you're not intending to work with the command line, or you're dealing with mixed environment security
