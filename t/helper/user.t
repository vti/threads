use strict;
use warnings;

use Test::More;
use TestLib;

use Threads::Helper::User;

subtest 'returns name when available' => sub {
    my $helper = _build_helper();

    is $helper->display_name({name => 'foo', status => 'active'}), 'foo';
};

subtest 'returns deleted when user deleted' => sub {
    my $helper = _build_helper();

    is $helper->display_name({status => 'deleted'}), '<strike>deleted</strike>';
};

my $env = {};

sub _build_helper {
    Threads::Helper::User->new(env => $env);
}

done_testing;
