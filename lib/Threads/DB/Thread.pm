package Threads::DB::Thread;

use strict;
use warnings;

use parent 'Threads::DB';

__PACKAGE__->meta(
    table   => 'threads',
    columns => [
        qw/
          id
          user_id
          created
          updated
          last_activity
          slug
          title
          content
          replies_count
          views_count
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    generate_columns_methods => 1,
    relationships  => {
        user => {
            type  => 'many to one',
            class => 'Threads::DB::User',
            map   => {user_id => 'id'}
        },
        replies => {
            type  => 'one to many',
            class => 'Threads::DB::Reply',
            map   => {id => 'thread_id'}
        }
    }
);

sub create {
    my $self = shift;

    if (!$self->get_column('slug')) {
        $self->slug($self->_slug($self->get_column('title')));
    }

    if (!$self->get_column('last_activity')) {
        $self->last_activity(time);
    }

    return $self->SUPER::create;
}

sub update {
    my $self = shift;

    $self->slug($self->_slug($self->get_column('title')));

    return $self->SUPER::update;
}

sub _slug {
    my $self = shift;
    my ($title) = @_;

    my $slug = lc($title // '');

    $slug =~ s{\s+}{-}g;
    $slug =~ s{[^[:alnum:]\-]}{}g;
    $slug =~ s{-+}{-}g;
    $slug =~ s{^-}{};
    $slug =~ s{-$}{};

    return $slug;
}

1;
