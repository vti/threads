use strict;
use warnings;

use Test::More;
use TestLib;

use Threads::Validator::Tags;

subtest 'return 0 when invalid' => sub {
    my $rule = _build_rule();

    is $rule->is_valid('   '), 0;
    is $rule->is_valid(',,,---'), 0;
    is $rule->is_valid('hi!'), 0;
    is $rule->is_valid('1,2,3,4,5,6,7,8,9,10,11'), 0;
    is $rule->is_valid('1' x 100), 0;
};

subtest 'return 1 when valid' => sub {
    my $rule = _build_rule();

    is $rule->is_valid('foo, bar, baz'), 1;
    is $rule->is_valid('dbix::class'), 1;
    is $rule->is_valid('hell-there'), 1;
};

sub _build_rule {
    Threads::Validator::Tags->new;
}

done_testing;
