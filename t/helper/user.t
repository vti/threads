use strict;
use warnings;

use Test::More;
use TestLib;

use Toks::Helper::User;

subtest 'returns name when available' => sub {
    my $helper = _build_helper();

    is $helper->display_name({name => 'foo', status => 'active'}), 'foo';
};

subtest 'escapes name characters' => sub {
    my $helper = _build_helper();

    is $helper->display_name({name => '<foo', status => 'active'}), '&lt;foo';
};

subtest 'returns User<id> when name not available' => sub {
    my $helper = _build_helper();

    is $helper->display_name({id => 123, status => 'active'}), 'User123';
};

subtest 'returns deleted when user deleted' => sub {
    my $helper = _build_helper();

    is $helper->display_name({status => 'deleted'}), '<strike>deleted</strike>';
};

my $env = {};

sub _build_helper {
    Toks::Helper::User->new(env => $env);
}

done_testing;
