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

1;
