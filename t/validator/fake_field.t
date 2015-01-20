use strict;
use warnings;

use Test::More;
use TestLib;

use Threads::Validator::FakeField;

subtest 'return 0 when invalid' => sub {
    my $rule = _build_rule();

    is $rule->is_valid('present'), 0;
};

subtest 'return 1 when valid' => sub {
    my $rule = _build_rule();

    is $rule->is_valid(undef), 1;
};

sub _build_rule {
    Threads::Validator::FakeField->new;
}

done_testing;
