use 5.006;    # our
use strict;
use warnings;

package KENTNL::Heading;

# ABSTRACT: Generate Hyperref headings easily

# AUTHORITY

use Statocles::Base 'Class';
with 'Statocles::Plugin';

sub heading {
    my ( $self, $args, $size, $name, %opts ) = @_;
    my $heading = sprintf "h%d", $size;
    my $id = $opts{name}
      || do {
        my $copy = lc $name;
        $copy =~ s/\W+/_/g;
        $copy;
      };
    my @hypers = (
        qq[<a class="toplink" href="#top">^</a>],
        qq[<a class="permalink" href="\#$id">\x{2693}</a>],
    );
    return sprintf '<%1$s id="%2$s">%3$s</%1$s>', $heading, $id, join q[],
      ( $name, @hypers );
}

sub register {
    my ( $self, $site ) = @_;
    $site->theme->helper( heading => sub { $self->heading(@_) } );
}
1;

