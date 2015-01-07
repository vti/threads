package Toks::DB::Thread;

use strict;
use warnings;

use parent 'Toks::DB';

__PACKAGE__->meta(
    table   => 'threads',
    columns => [
        qw/
          id
          user_id
          created
          slug
          title
          content
          replies_count
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    relationships  => {
        user => {
            type  => 'many to one',
            class => 'Toks::DB::User',
            map   => {user_id => 'id'}
        },
        replies => {
            type  => 'one to many',
            class => 'Toks::DB::Reply',
            map   => {id => 'thread_id'}
        }
    }
);

sub create {
    my $self = shift;

    if (!$self->get_column('slug')) {
        $self->set_column(slug => $self->_slug($self->get_column('title')));
    }

    return $self->SUPER::create;
}

sub update {
    my $self = shift;

    $self->set_column(slug => $self->_slug($self->get_column('title')));

    return $self->SUPER::update;
}

sub _slug {
    my $self = shift;
    my ($title) = @_;

    my $slug = lc($title // '');

    $slug =~ s{\s+}{-}g;
    $slug =~ s{[^[:alnum:]\-]}{}g;
    $slug =~ s{-+}{-}g;

    return $slug;
}

1;
