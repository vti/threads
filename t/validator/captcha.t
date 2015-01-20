use strict;
use warnings;

use Test::More;
use TestLib;

use Threads::Validator::Captcha;

subtest 'return 0 when invalid' => sub {
    my $rule = _build_rule(args => ['expected']);

    is $rule->is_valid('got'), 0;
};

subtest 'return 1 when valid' => sub {
    my $rule = _build_rule(args => ['expected']);

    is $rule->is_valid('expected'), 1;
};

sub _build_rule {
    Threads::Validator::Captcha->new(@_);
}

done_testing;
