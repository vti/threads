package Toks::DB::DisposableEmailBlacklist;

use strict;
use warnings;

use parent 'Toks::DB';

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
);

1;
