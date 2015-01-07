package Toks::DB::Thank;

use strict;
use warnings;

use parent 'Toks::DB';

use Digest::MD5 ();

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
);

1;
