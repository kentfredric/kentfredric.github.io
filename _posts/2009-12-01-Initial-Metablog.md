---
layout: article
title:  Initial Metablog/The State of the blogsphere
tags: blogging, meta, software, web
---

Well, this is a new blog. One of the standard initiation rites is to write a blog about blogging<sup id="fromfoot1"><a href="#foot1">1</a></sup>


Instead of going on a fork about blogging techniques and whatnot, I'm just going to lament about the sad state of blogging platforms that don't suck and JustWork, and why I eventually chose Blogger.

* [Do It Yourself](#do_it_yourself)
* [\{\{ $InsertProjectNameHere }} Hosted On Your Own Server](#_insertprojectnamehere__hosted_on_your_own_server)
* [3rd Party Service](#3rd_party_service)

## Do It Yourself

People I've seen have this penchant to hard-code and rewrite their own blogs from scratch.

This concept to me is Made With Fail™.

Sure, you get exactly what you want, but you also have the blissfully joyful task of maintaining everything yourself, and making all the fun calls about how to handle commenting, aggregation, and all that sort of stuff, and its just too much work.

Doing that sort of stuff for a living is challenging enough, let alone having to do it for a living and yourself at the same time, which is just too much work.

## \{\{ $InsertProjectNameHere }} Hosted On Your Own Server

This is a substantially better option verses [Do It Yourself](#do_it_yourself) , you don't have to worry so much about code maintenance.

However, you still have to worry about host security, and how safe the code really is. After all, you're paying for that server, and have pissy entry-level grade database support[<sup>2</sup>](#foot2), and you sort of have the worry much of the time of keeping your host platform up-to-date and secure, and keeping your blogging software up to date and secure.

Additionally, the average designed-for-self-hosting project appears to have lots of associated stupidity, and the arbitrary hoop jumping install phase and arbitrary hoop jumping configuration, and the bizarre do-it-all-by-hand database setup stuff, which I'm really sick of, combined with the fact they often don't even have documentation or support for non-apache web-servers<sup id="fromfoot3"><a href="#foot3">3</a></sup>, or require some magically odd setup for apache which has since been deprecated by the distribution you're trying to install it on.

## 3rd Party Service

Eliminating the above 2 choices leaves me with only the logical conclusion of utilising some 3rd party service. This absolves me of the need to worry about the hosting and software requirements of the platform, and let their team of dedicated staff handle those problems.

Sure, there's the caveat of "if something doesn't work, you can't fix it yourself", but they know more about their software than I do. You get about as much benefit here as with {{$ProjectName}} built from code you don't grok, and don't have time to grok.

Then we go down to the list of features that matter to you:

1. DNS Support.

    Being able to map the Blog under your own site of choosing is a must have feature.  
    Some services charge for the luxury of doing this, others, its standard issue.

2. Free.

    This, is also important for me, if you can't get the most out of a service for free, its not worth it. Pay-for blogging services are a huge turnoff

3. All The Mundane things worked out for you.

    It should be easy by default, and you can just Start Using It, and have capacity for power later.

4. Feed Production.

    A must have: not everybody wants to be forced to browse your site via a web-browser, and feeds are much more convenient for them

5. Simple Advertisement Integration.

    I know ads are a bit nasty, but sometimes a guy isn't making enough money to get by on, and throwing up some much needed adverts can help contribute to some much needed denero. Simplicity is also important, because one day if I decide I want to change them, or rip them out all together, I want minimal migration pain.

6. Simple themes by default that look great.
  
    There's nothing worse than a site with a theme that screams "I was born in the geocities era." , and as a coder, not a graphic designer, my eye for style tends towards looking pretty brutal. As I'm not a designer, I want something that looks good, and requires none of my time to maintain it. 

7. No HTML Restrictions.

    Ideally, you should be able to avoid manually hacking html for the most part, but should you feel the need to extend it, there should be no limitations on how you can lay out stuff, theme it, and format it. Anything that puts restrictions on what I can put in the code or tries to "magic" my insertions into something else get epic beatings from me.

And now for the blogging services.

1. LiveJournal.

    I've been using this off and on for mundane stuff, but its hopeless for a blog of technical merit. Pointing somebody to your LJ blog invokes the whole "hurr" mental result. Its too arcane, too old, and over the top restrictive with decade old use models. It contravenes goals 1,2, 5, 6 and 7 in my experiences, it has this nasty "skin" oriented theme thing which sucks epically hard. And you have to be a premium member ( $$$ ) to get the maximum use out of it. The best you can do is get a semi-premium account by proliferating it with adverts that work for LiveJournal, not for you. You can't get a dns association without being a premium member. 

2. WordPress

    I don't want to go into this one, but eww. Whats not to hate about Wordpress?. Its far too noisy. Like LJ, it plunders you with adverts, and you have to pay to get rid of them. And it appears to me there's not much in the way of goal 1,5 and 7. The whole plugin architecture they have is just an abuse farm festering under the hood.

3. blogs.perl.org

    Too new, and hideously broken for me all the time. Apparently no support for proper per-domain blogs, and you're all like different bloggers using the same site. Sorry, signal to noise far too high for me. 

4. use.perl.org blogs

    Ugly as sin, user interface like a leather bag over the head. Hopeless RSS. No DNS. No themes. Overcomplicated. 

5. TypePad

    Pay for only. Won't even attempt to use it. Teired pricing for different features is a bigger turnoff still. I don't own a VISA, and don't want one, which makes it simply impossible to do anything that incurrs international payments ( I might cover this at a latter time ).

6. Vox

    This seems the best of breed with regard to the Perl options I've seen so far, but the interface is too heavy, too much chrome that can't be turned off, the site is so dizzying in complexity, that its not "Just a frickn blog" like I want, its a whole damned social blogging network thing, and that's awful. Its looking too much like its trying to be live journal. As for the desired features, I can't tell what it does, what features I really want, it doesn't appear to mention them , anywhere, and I'd only be able to work it out if I signed up. I highly doubt DNS control though.

So I've settled for Blogger. It just seems to suck less for the things I want to do.

### Footnotes

<p><sub id="foot1"><a href="#fromfoot1">1.</a> I'm now blogging about blogging about blogging, so meta-level just keeps growing.</sub></p>
<p><sub id="foot2"><a href="#fromfoot2">2.</a> That is, I'm betting you don't have replication and backups to high-heaven for your average self-hosted project.</sub></p>
<p><sub id="foot3"><a href="#fromfoot3">3.</a> Which is especially problematic if you cant even run apache because the bloated thing consumes all the available memory on your cheap XEN VPS, and then starts hardcore swapping to disk, and the site becomes inaccessible as soon as a crawler hits it.</sub></p>
