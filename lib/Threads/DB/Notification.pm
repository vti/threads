package Threads::DB::Notification;

use strict;
use warnings;

use parent 'Threads::DB';

__PACKAGE__->meta(
    table   => 'notifications',
    columns => [
        qw/
          id
          created
          user_id
          reply_id
          is_sent
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    unique_keys => [qw/user_id reply_id/],
    generate_columns_methods => 1,
    relationships => {
        reply => {
            type  => 'many to one',
            class => 'Threads::DB::Reply',
            map   => {reply_id => 'id'}
        },
    }
);

1;
