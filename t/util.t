use strict;
use warnings;

use Test::More;

use Threads::Util qw(gentoken from_hex to_hex);

subtest 'generates token' => sub {
    my $token = gentoken(32);

    is length $token, 32;
};

subtest 'hex and binary' => sub {
    my $token = gentoken(32);

    is $token, from_hex to_hex $token;
};

done_testing;
