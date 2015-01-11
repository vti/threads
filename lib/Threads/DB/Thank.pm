package Threads::DB::Thank;

use strict;
use warnings;

use parent 'Threads::DB';

__PACKAGE__->meta(
    table   => 'thanks',
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
);

1;
