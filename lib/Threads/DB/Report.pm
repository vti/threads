package Threads::DB::Report;

use strict;
use warnings;

use base 'Threads::DB';

__PACKAGE__->meta(
    table   => 'reports',
    columns => [
        qw/
          id
          created
          user_id
          reply_id
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    generate_columns_methods => 1,
    relationships  => {
        reply => {
            type  => 'many to one',
            class => 'Threads::DB::Reply',
            map   => {parent_id => 'id'}
        },
        user => {
            type  => 'many to one',
            class => 'Threads::DB::User',
            map   => {user_id => 'id'}
        }
    }
);

1;
