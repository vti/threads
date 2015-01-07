package Toks::DB::Notification;

use strict;
use warnings;

use parent 'Toks::DB';

use Digest::MD5 ();

__PACKAGE__->meta(
    table   => 'notifications',
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
    unique_keys => [qw/user_id reply_id/],
    relationships => {
        reply => {
            type  => 'many to one',
            class => 'Toks::DB::Reply',
            map   => {reply_id => 'id'}
        },
    }
);

1;
