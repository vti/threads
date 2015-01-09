use strict;
use warnings;

use Test::More;
use TestLib;

use Toks::Validator::MaxLength;

subtest 'return 0 when invalid' => sub {
    my $rule = _build_rule();

    is $rule->is_valid('1234', 3), 0;
    is $rule->is_valid('12345', 3), 0;
};

subtest 'return 1 when valid' => sub {
    my $rule = _build_rule();

    is $rule->is_valid('123', 3), 1;
    is $rule->is_valid('12', 3), 1;
};

sub _build_rule {
    Toks::Validator::MaxLength->new;
}

done_testing;
