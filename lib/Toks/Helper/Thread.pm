package Toks::Helper::Thread;

use strict;
use warnings;

use parent 'Tu::Helper';

use Toks::DB::Thread;

sub find {
    my $self = shift;

    my @threads = Toks::DB::Thread->find(order_by => [created => 'DESC']);

    return map { $_->to_hash } @threads;
}

1;
