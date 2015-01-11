package Threads::DB::DisposableEmailBlacklist;

use strict;
use warnings;

use parent 'Threads::DB';

__PACKAGE__->meta(
    table   => 'disposable_email_blacklist',
    columns => [
        qw/
          id
          domain
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    unique_keys    => ['domain'],
    generate_columns_methods => 1,
);

1;
