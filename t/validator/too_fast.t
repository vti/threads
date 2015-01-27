use strict;
use warnings;

use Test::More;
use TestLib;

use Threads::Validator::TooFast;

subtest 'return 0 when no session' => sub {
    my $rule = _build_rule(args => [{'psgix.session' => {}}]);

    is $rule->is_valid('value'), 0;
};

subtest 'return 0 when too fast' => sub {
    my $rule = _build_rule(args => [{'psgix.session' => {too_fast => time}}]);

    is $rule->is_valid('value'), 0;
};

subtest 'return 1 when not too fast' => sub {
    my $rule = _build_rule(args => [{'psgix.session' => {too_fast => 123}}]);

    is $rule->is_valid('value'), 1;
};

sub _build_rule {
    Threads::Validator::TooFast->new(@_);
}

done_testing;
