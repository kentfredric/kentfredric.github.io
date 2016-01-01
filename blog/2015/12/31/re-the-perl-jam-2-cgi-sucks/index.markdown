---
tags:
  - 'perl'
title: 'Re: The Perl Jam 2: CGI Sucks'
---

I'm going to be posting a series of entries in response to [Netanel Rubin's Presentation: The Perl Jam 2](https://www.youtube.com/watch?v=eH_u3C2WwQ0), and this is the first of such entries.

As a whole, I felt he grossly miss-characterised Perl and its community, and made a few glaring errors in his presentation and a few leaps of logic.

Amongst his talk, he covered a handful of Real Bugs, but his presentation made it difficult to realise what they were objectively,
and his hyperbolic and rhetoric technique served not to educate, not to correct, but to mock.

I feel many of his criticisms would have been better addressed as actual bug reports, not a presentation conveying how software has bugs, and that with better clarity
and less rhetorical devices, the important parts of his presentation could have been covered in 5 minutes.

So this is an attempt at clarifying the mistakes in the presentation, and serve as a more objective response where we can unpack the relevant parts,
fix the actual problems, and educate our way past the cultural issues that lead people to make bad choices.

I will of course go into far more detail than is strictly necessary.

## CGI Sucks
### And its Documented that Nobody should use it

Netanel did not identify this quirk as such, but it underlies a significant chunk of his presentation.

Both `CGI.pm` and the CGI protocol imply serious limitations on the security and performance of your Web Application, 
and has been recommended against by everyone worth listening to, and is even documented as such
[**IN CGI.pm itself**](https://metacpan.org/pod/release/LEEJO/CGI-4.25/lib/CGI.pod#CGI.pm-HAS-BEEN-REMOVED-FROM-THE-PERL-CORE)

> CGI.pm is no longer considered good practice for developing web applications, including quick prototyping and small web scripts. 
There are far better, cleaner, quicker, easier, safer, more scalable, more extensible, more modern alternatives available at this point in time.

The CGI protocol significantly blurs the lines between the Command Line interface, and the Web, in ways that prove to be detrimental, 
and can serve as an amplifier for bugs and security risks.

One of the attacks he demonstrates relies heavily on a behaviour in Perl that is deemed useful for command line programs: The ability 
for the caller ( that is, the user of the command line program ), to specify, by way of arguments, names of arbitrary programs to execute to retrieve their output.

This turns out to be a grave trap in a Web context, as HTTP `GET` Request parameters are passed to the CGI application as parameters to `@ARGV`,
much like parameters on the command line.

And that means any code that happens to utilize that "execute arbitrary programs based on arguments in `@ARGV`" path
( either by intent, or by way of exploiting a bug ) is simply waiting for the day when some user on the internet can forge a request such as:

    http://example.org/fake.cgi?rm -rf /|

And maybe find enough magic spice to trigger the "be a command line and execute that" condition.

And this would clearly be bad.

But this risk exists because of the Command-Line-as-a-Web-Protocol design flaw.

## How do we fix it?

### Kill CGI
We've been trying as a community to kill its use. But it still flourishes in many ways.

Every time you talk to the community, there will be somebody who will tell you not to use it.

Its documentation says not to use it.

We removed it from Perl already to discourage its use.

The only thing we can do here is be more vocal about how bad it is, and how nobody should use it.

Its had its time, and that time is long past. You should expect it to bite you.

But its not a good justification to say "Perl is Bad" because people refuse to stop using bad software written in it,
despite the attempts of the community of that language trying to kill it.

### Use PSGI Instead

People should be strongly encouraged to use any other standardized recognised Framework, especially ones that are implemented
in terms of [PSGI](https://metacpan.org/pod/distribution/PSGI/PSGI.pod#SPECIFICATION) and have the option of running
on [Plack](https://metacpan.org/pod/Plack) or any other `PSGI` compatible server.

### PSGI Server in Core?

Perhaps we need to write a minimal subset of `Plack` and consider shipping it with Perl to encourage the use of `PSGI`.

This option is naturally contentious, because `Perl` very much eschews the "batteries included" mentality, and there are serious
consequences that occur when Perl includes too much software in itself, such as Linux vendors deeming those components not necessary
and making them not part of the base Perl installation, invalidating the whole point of them being there in the first place,
and adding the complications that come when users try to use things that their language documentation says should be there, but isn't.

But given how long `CGI.pm` lived in core, and given how there's a substantial amount of its use due in part to that fact, we may
need to consider incorporating competition to offset that problem.
