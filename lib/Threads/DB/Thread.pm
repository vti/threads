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
          editor_id
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
        editor => {
            type  => 'many to one',
            class => 'Threads::DB::User',
            map   => {editor_id => 'id'}
        },
        replies => {
            type  => 'one to many',
            class => 'Threads::DB::Reply',
            map   => {id => 'thread_id'}
        },
        map_thread_tag => {
            type  => 'one to many',
            class => 'Threads::DB::MapThreadTag',
            map   => {id => 'thread_id'}
        },
        tags => {
            type      => 'many to many',
            map_class => 'Threads::DB::MapThreadTag',
            map_from  => 'thread',
            map_to    => 'tag'
        },
    }
);

sub create {
    my $self = shift;

    if (!$self->slug) {
        $self->slug($self->_slug($self->title));
    }

    if (!$self->last_activity) {
        $self->last_activity(time);
    }

    return $self->SUPER::create;
}

sub update {
    my $self = shift;

    $self->slug($self->_slug($self->title));

    return $self->SUPER::update;
}

sub to_hash {
    my $self = shift;

    my $hash = $self->SUPER::to_hash;

    if ($self->is_related_loaded('tags')) {
        $hash->{tags_list} = join ', ', map {$_->title} $self->related('tags');
    }

    return $hash;
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
