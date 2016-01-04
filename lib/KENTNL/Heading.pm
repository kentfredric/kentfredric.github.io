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

sub footnote {
    my ( $self, $args, $text ) = @_;
    my $footnote_stash = ( $args->{self}->{x_footnotes} ||= [] );
    my $human_no = 1 + scalar @{$footnote_stash};
    push @{$footnote_stash}, $text;
    return
qq[<a class="footnote_ref" id="from_footnote_${human_no}" href="#footnote_${human_no}">$human_no</a>];
}

sub footnotes {
    my ( $self, $args, ) = @_;
    my $footnote_stash = ( $args->{self}->{x_footnotes} ||= [] );
    my @out;
    for my $footnote_no ( 0 .. $#{$footnote_stash} ) {
        my $human_no = $footnote_no + 1;
        push @out,
qq[<p class="footnote"><a id="footnote_${human_no}" href="#from_footnote_${human_no}">${human_no}.</a> ]
          . $footnote_stash->[$footnote_no]
          . qq[</p>];
    }
    return join q[], @out;
}

sub register {
    my ( $self, $site ) = @_;
    $site->theme->helper( heading   => sub { $self->heading(@_) } );
    $site->theme->helper( footnote  => sub { $self->footnote(@_) } );
    $site->theme->helper( footnotes => sub { $self->footnotes(@_) } );
}
1;

