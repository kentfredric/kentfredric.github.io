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

around tag_pages => sub {
  my ( $orig, $self, $tagged_docs, @rest ) = @_;
  my (@pages) = $self->$orig( $tagged_docs, @rest );

  for my $tag ( keys %{$tagged_docs} ) {
    my (@tag_pages);
    my $epath = join '/', $self->url_root, 'tag', $self->_tag_url($tag), '';
    for my $page (@pages) {
      next unless $page->path =~ /^\Q$epath\E/;
      push @tag_pages, $page;
    }
    next unless @tag_pages;
    my ($index) = $tag_pages[0];    ## This seems really dodgy
    my ( @feed_pages, @feed_links );
    for my $feed ( sort keys %FULL_FEEDS ) {
      my $tag_file = $self->_tag_url($tag) . '.fulltext.' . $feed;

      my $page = Statocles::Page::List->new(
        app      => $self,
        pages    => $index->pages,
        path     => join( "/", $self->url_root, 'tag', $tag_file ),
        template => $self->site->theme->template(
          blog => $FULL_FEEDS{$feed}{template}
        ),
        links => {
          alternate => [
            $self->link(
              href  => $index->path,
              title => $tag,
              type  => $index->type,
            ),
          ],
        },
      );

      push @feed_pages, $page;
      push @feed_links,
        $self->link(
        text => $FULL_FEEDS{$feed}{text},
        href => $page->path->stringify,
        type => $page->type,
        );
    }
    for my $page (@tag_pages) {
      push @{ $page->_links->{feed} }, @feed_links;
    }
    push @pages, @feed_pages;
  }
  return @pages;
};

1;

