---
layout: article
title: "Code Wanted: Abstract Syntax Tree to Perl Code compiler"
tags: ast,ideas,metaprogramming,perl
---
WANTED:

{% highlight perl %}
use AST::Assembler qw( :all );

# Code Generation Via AST.

my $code = context( 
  package_def('Foo', context(
        use_declaration('Moose'),
        call_sub('with', package => CURRENTCONTEXT, args => list( 'Some::Role' )),
        def_sub('bar', context( 
           def_var(['x','y','z'], 'context' => CURRENTCONTEXT),
           assign(['x','y','z',], STACK ),
           assign('z', add('x','y')),
           return('z'),
        ))
  ))
);

# AST Augmentation.
$code->find('def_sub')
     ->grep(sub{ $_[0] eq 'bar' })
     ->find('assign')
     ->grep(sub{ $_[0] eq 'z' })
     ->before(assign('x',sub(0,'x')));

my $codestr = $code->to_perl;
{% endhighlight %}
{% highlight perl linenos %}
package Foo;
use Moose;
with "Some::Role";
sub bar { 
  my ( $x,$y, $z);
  ($x,$y,$z) = (@_);
  $x = 0 - $x;  # inserted by augmentation.
  $z = ( $x + $y )
  return $z;
}
{% endhighlight %}
{% highlight perl %}
$code->optimise->to_perl
{% endhighlight %}
{% highlight perl linenos %}
package Foo;
use Moose;
with "Some::Role";
sub bar { 
  return ( ( 0 - $_[0] ) + $_[1] )
}
{% endhighlight %}
{% highlight perl %}
$code->find('package_def', [ 0 , 'eq' , 'Foo' ])
     ->child('context')
     ->append(callsub('bar',args=>list('1','2','3')));

$code->optimise->to_perl
{% endhighlight %}
{% highlight perl linenos %}
package Foo;
use Moose;
with "Some::Role";
sub bar { 
  return ( ( 0 - $_[0] ) + $_[1] )
}

( ( 0 - '1' ) + '2' )

{% endhighlight %}
Its just an insane starting point for code generation. Somebody run with it and make it not suck :)

Once we get a working AST to Perl code thing, maybe somebody can consider doing the inverse ;)
