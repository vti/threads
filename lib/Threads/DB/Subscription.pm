package Threads::DB::Subscription;

use strict;
use warnings;

use parent 'Threads::DB';

__PACKAGE__->meta(
    table   => 'subscriptions',
    columns => [
        qw/
          id
          created
          user_id
          thread_id
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    relationships => {
        thread => {
            type  => 'many to one',
            class => 'Threads::DB::Thread',
            map   => {thread_id => 'id'}
        },
    }
);

1;
