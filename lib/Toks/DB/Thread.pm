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
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
);

1;
