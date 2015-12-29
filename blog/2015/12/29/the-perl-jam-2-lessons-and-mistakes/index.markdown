---
tags: [ 'perl' ]
title: 'The Perl Jam 2: Lessons and Mistakes'
---
Its hard to be part of the Perl Community and see Netanel Rubin parading on stage and see him smack-talking Perl.

Objective Technical criticism should of course be welcomed, but I felt his presentation missed that mark.

I imagine its even harder for a person outside the Perl Community to witness his presentation and learn things that are objectively true from it, because a person who is unfamiliar
with Perl is unlikely to be able to differentiate between actual criticisms and glaring errors that Netanel made.

This may be easily lead the uninitiated to believe that Perl is some crazy language that is wildly different from all other dynamically typed languages, in both fundamental ways at the language level, and in its culture.

Netanel, did however, make some good points, its just hard to find them amongst the joking and mockery.

So I will attempt to dissect it as objectively as possible, so that we can fix what needs to be fixed, and then discard the hyperbole for what it is.

## The Facts: Things which may be actual problems.

### CGI Sucks and it's documented that Nobody Should use it.

Netanel did not identify this quirk as such, but it underlies a significant chunk of his presentation.

Both `CGI.pm` and the CGI protocol imply serious limitations on the security and performance of your Web Application, and has been recommended against by everyone worth listening to, and is even documented as such **IN CGI.pm itself**

> CGI.pm is no longer considered good practice for developing web applications, including quick prototyping and small web scripts. There are far better, cleaner, quicker, easier, safer, more scalable, more extensible, more modern alternatives available at this point in time.

The CGI protocol significantly blurs the lines between the Command Line interface, and the Web, in ways that prove to be detrimental, and can serve as an amplifier for bugs and security risks.

One of the attacks he demonstrates relies heavily on a behaviour in Perl that is deemed useful for command line programs: The ability for the caller ( that is, the user of the command line program ), to specify, by way of arguments, names of arbitrary programs to execute to retrieve their output.

This turns out to be a grave trap in a Web context, as HTTP `GET` Request parameters are passed to the CGI application as parameters to `@ARGV`, much like parameters on the command line.

And that means any code that happens to utilize that "execute arbitrary programs based on arguments in `@ARGV`" path ( either by intent, or by way of exploiting a bug ) is simply waiting for the day when some user on the internet can forge a request such as:

    http://example.org/fake.cgi?rm -rf /|

And maybe find enough magic spice to trigger the "be a command line and execute that" condition.

And this would clearly be bad.

But this risk exists because of the Command-Line-as-a-Web-Protocol design flaw.

#### How do we fix it?

We've been trying as a community to kill its use. But it still flourishes in many ways.

Every time you talk to the community, there will be somebody who will tell you not to use it.

Its documentation says not to use it.

We removed it from Perl already to discourage its use.

The only thing we can do here is be more vocal about how bad it is, and how nobody should use it.

Its had its time, and that time is long past. You should expect it to bite you.

But its not a good justification to say "Perl is Bad" because people refuse to stop using bad software written in it, despite the attempts of the community of that language trying to kill it.

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
