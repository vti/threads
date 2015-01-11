package Threads::DB::Tag;

use strict;
use warnings;

use base 'Threads::DB';

__PACKAGE__->meta(
    table   => 'tags',
    columns => [
        qw/
          id
          title
          /
    ],
    primary_key              => 'id',
    auto_increment           => 'id',
    unique_keys              => 'title',
    generate_columns_methods => 1,
    relationships            => {
        map_thread_tag => {
            type  => 'one to many',
            class => 'Threads::DB::MapThreadTag',
            map   => {id => 'tag_id'}
        },
        threads => {
            type      => 'many to many',
            map_class => 'Threads::DB::MapThreadTag',
            map_from  => 'tag',
            map_to    => 'thread'
        },
    }
);

1;
