package Threads::DB::MapThreadTag;

use strict;
use warnings;

use parent 'Threads::DB';

__PACKAGE__->meta(
    table   => 'map_thread_tag',
    columns => [
        qw/
          thread_id
          tag_id
          /
    ],
    primary_key              => [qw/thread_id tag_id/],
    generate_columns_methods => 1,
    relationships            => {
        thread => {
            type  => 'many to one',
            class => 'Threads::DB::Thread',
            map   => {thread_id => 'id'}
        },
        tag => {
            type  => 'many to one',
            class => 'Threads::DB::Tag',
            map   => {tag_id => 'id'}
        },
    }
);

1;
