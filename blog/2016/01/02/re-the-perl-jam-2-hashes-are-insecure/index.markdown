---
tags:
  - 'perl'
  - 'the perl jam 2'
title: 'Re: The Perl Jam 2: Hashes are Insecure'
---

This is part 3 in a [series](/blog/tag/the-perl-jam-2) of responses to
[Netanel Rubin's Presentation: The Perl Jam 2](https://www.youtube.com/watch?v=eH_u3C2WwQ0),
for reasons explained in [Part 1](/blog/2015/12/31/re-the-perl-jam-2-cgi-sucks/)

In his original presentation, Netanel over focused on the assumption that we treat
Hashes and other arbitrary data structures as safe by default.

This is not really true, however, when watching him talk about it, I realised
he was right in a sense, just ... not how he imagined.

%=heading 2, "Hash Keys are a Potential Security Risk."

Under taint mode, strings from external sources are marked "tainted" until somebody manually untaints them.

And then any tainting-sensitive function calls can raise a fatal exception if they are passed sensitive data.

For instance, Take the following JSON file

%=code highlight JavaScript => begin
{ "DROP TABLES *": "DROP TABLES *" }
%end

Now, using the following script:
%=code highlight Perl => begin
use strict;
use warnings;
use JSON::MaybeXS;
use Path::Tiny qw( path );

my $structure = decode_json(path('/tmp/evil.json')->slurp_raw);
system("echo " . join q[], values %{$structure} );
%end

This example demonstrates that the JSON back-end faithfully preserved taintness
of the external data, and the code fails as expected.
%=code highlight bash => begin
$ env -i perl -T /tmp/json.pl
Insecure dependency in system while running with -T switch at /tmp/json.pl line 7.
%end

However, hash keys are inherently different:
%=code highlight diff => begin
- system("echo " . join q[], values %{$structure} );
+ system("echo " . join q[], keys   %{$structure} );
%end

And now we have a problem:

%=code highlight bash => begin
$ env -i perl -T /tmp/json.pl
DROP TABLES blog page site.yml static theme
%end

Now this is not necessarily a problem if you apply clean code practices.

As long as you make sure everything the user gave you is well sanitized, and you use Bound-Parameter style value passing to literally
every API you use, then you might be OK.

But Taint mode basically exists as a fall-back defense to guard against developers failing to vet all the inputs, so that if
you missed something, Perl still has an opportunity to save the day.

But people can also be needlessly lazy and rely entirely on Perl to save the day, when Perl is not psychic.

And worse, you can be using Taint mode, but you could either be unintentionally untainting sensitive data, or intentionally untaining data
but untainting it incorrectly, leaving exploitable code through to your system.

Here, "Value spent time in a Hash Key" transparently untaining data can leverage itself to be a weak point.

%= heading 2, q[How Do We Fix It]

%= heading 3, q[Considerations]

%= heading 4, q[Performance]

There's a big blocker inhibiting our ability to make Hash Keys retain taintedness.

And its based on how Hash data structures underly a significant proportion of the Perl Language.

Not only do Anonymous Hash References use Hashes as their underlying model, but so does the entire `package Foo::` namespace hierarchy,
which includes the symbol tables that methods and global variables are stored in.

Which means any changes we make to the Hash Data structure to preserve taint bits will incur a significant performance overhead under Taint Mode.

This would also risks a performance decrease for All Perl, even when *not* running in Taint Mode.

%= heading 4, q[Implementation Challenges]

How do we want this to behave?

%=code highlight Perl => begin
my $hash = {};
$hash->{ taint("Hello") } = "World";
$hash->{ "Hello" } = "Earth";

# Is $value tainted or not here?
my ($value,) = keys %{$hash};
# How many keys are there exactly anyway, should we consider a tainted key
# and its untainted companion to be identical or different keys?
my $n_keys = scalar keys %{$hash};
%=end

%= heading 4, q[Backwards Compatibility]

Because "Hash-Keys-Remove-Taint" has been a thing for so long, there is very likely code in production
that is intentionally relying on this behaviour.

How do we fix this without making a lot of existing and correct code suddenly become broken?

%= heading 3, q[Suggestions]

%= heading 4, q[Tainted Hashes]

I would probably propose an option that allows taintedness to become a property of a hash,
instead of merely a property of the strings contained in that hash.

Tools like JSON decoders would explicitly mark any hash constructed from tainted data to be implicitly
tainted, and then hash internals don't care about taintedness on a per-key/per-value level, and just re-tag
everything that came out of a tainted hash ( either by calls to keys or values ) became tainted by default.

But sadly, this doesn't mitigate the potential performance negatives of adding the feature, because
there still has to be an "Am I tainted? -> Return tainted value" stage, and that code path would still
have to be there for all the package/stash lookups.

You could probably bodge together something that approximates this with `tie`, but `tie` is almost always
more poison than cure.

%= heading 4, q[Lexically Applied Hash Tainting]

It seems possible to me that a pragma could be developed that doesn't affect the handling of Hashes intrinsically,
but lexically changes how hash-access OPs are compiled in its context.

And it seems to me you could leverage such a thing to only apply to hash access calls on variables, as opposed to on GLOBs ( Package/Stashes )

%=code highlight Perl => begin
use tainted::hashes;

Package::foo::method(); # Uses native Hash Access ops.

$ref->{key} # uses taint safe ops if tainting is enabled.
%end

You'd need to have some sort of semantics in play so you can handle the taintedness of hashes declared in other contexts,
for instance, you might assume any hash that hasn't been seen by a tainted::hashes pragma and hasn't been marked "Safe"
is inherently "Unsafe".

And then you could potentially "turn on" that feature by default in some future perl release under tainting,
or at least, turn it on as a feature with `use 5.${FUTURE}`.

%= heading 4, q[Call For Suggestions]

Clearly neither of those solutions are entirely elegant and may have serious road stops. And I honestly know almost
nothing about XS when it comes to the implementation details in Perl Guts to know what is possible and what isn't.

So if any readers out there have some good ideas, there's a P5P who's accepting patches if they seem reasonable and the technical
costs are affordable.

%= heading 2, q[Comments]

Please direct any feedback or corrections [to the Reddit thread](https://www.reddit.com/r/perl/comments/3zemb5/re_the_perl_jam_2_hashes_are_insecure/). Alternatively, message me on irc:

  - irc.perl.org u:kentnl
  - irc.freenode.org u:kent\n

Or if you want, you can [patch the blog yourself](https://github.com/kentfredric/kentfredric.github.io/pulls)
or [file a bug on it](https://github.com/kentfredric/kentfredric.github.io/issues)
