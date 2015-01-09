use strict;
use warnings;

use Test::More;
use TestDB;
use TestLib;

use Toks::DB::DisposableEmailBlacklist;
use Toks::Validator::NotDisposableEmail;

subtest 'return 0 when invalid' => sub {
    TestDB->setup;

    Toks::DB::DisposableEmailBlacklist->new(domain => 'mailinator.com')
      ->create;

    my $rule = _build_rule();

    is $rule->is_valid('foo@mailinator.com'), 0;
};

subtest 'return 1 when valid' => sub {
    TestDB->setup;

    my $rule = _build_rule();

    is $rule->is_valid('foo@mailinator.com'), 1;
};

sub _build_rule {
    Toks::Validator::NotDisposableEmail->new;
}

done_testing;
