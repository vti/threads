use strict;
use warnings;

use Test::More;
use TestLib;

use Threads::Validator::Readable;

subtest 'return 0 when invalid' => sub {
    my $rule = _build_rule();

    is $rule->is_valid('   '), 0;
    is $rule->is_valid(',,,---'), 0;
};

subtest 'return 1 when valid' => sub {
    my $rule = _build_rule();

    is $rule->is_valid('  fo   o'), 1;
};

sub _build_rule {
    Threads::Validator::Readable->new;
}

done_testing;
