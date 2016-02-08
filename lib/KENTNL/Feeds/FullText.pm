use 5.006;    # our
use strict;
use warnings;

package KENTNL::Feeds::FullText;

# ABSTRACT: Add fulltext rss feeds to a blog

# AUTHORITY

use Statocles::Base 'Role';
use Statocles::Page::List ();

my %FULL_FEEDS = (
  rss => {
    text     => 'RSS FullText',
    template => 'fulltext.rss',
  },
  atom => {
    text     => 'Atom FullText',
    template => 'fulltext.atom',
  },
);

around index => sub {
  my ( $orig, $self, @arg ) = @_;
  my (@pages) = $self->$orig(@arg);
  return unless @pages;
  my $index = $pages[0];
  my (@feed_pages);
  my (@feed_links);
  for my $feed ( sort keys %FULL_FEEDS ) {
    my $page = Statocles::Page::List->new(
      app   => $self,
      pages => $index->pages,
      path  => $self->url_root . '/fulltext.' . $feed,
      template =>
        $self->site->theme->template( blog => $FULL_FEEDS{$feed}{template} ),
      links => {
        alternate => [
          $self->link(
            href  => $index->path,
            title => 'index',
            type  => $index->type,
          )
        ]
      }
    );
    push @feed_pages, $page;
    push @feed_links,
      $self->link(
      text => $FULL_FEEDS{$feed}{text},
      href => $page->path->stringify,
      type => $page->type,
      );
  }
  for my $page (@pages) {
    my $links = $page->_links;
    next if not exists $links->{feed};
    next if not defined $links->{feed};
    next if 'ARRAY' ne ref $links->{feed};
    next unless @{ $links->{feed} };
    push @{ $links->{feed} }, @feed_links;
  }
  return ( @pages, @feed_pages );
};


1;

