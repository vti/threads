use strict;
use warnings;

use Test::More;
use TestLib;

use Threads::Validator::Email;

subtest 'return 0 when invalid' => sub {
    my $rule = _build_rule();

    is $rule->is_valid('foo'), 0;
};

subtest 'return 1 when valid' => sub {
    my $rule = _build_rule();

    is $rule->is_valid('foo@bar.com'), 1;
};

sub _build_rule {
    Threads::Validator::Email->new;
}

done_testing;
