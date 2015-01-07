use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use Toks::DB::User;
use Toks::DB::Thread;
use Toks::DB::Subscription;
use Toks::Helper::Subscription;

subtest 'returns false when not subscribed' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'password')
      ->create;
    my $helper = _build_helper('tu.user' => $user);

    ok !$helper->is_subscribed({id => 123});
};

subtest 'returns true when subscribed' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'password')
      ->create;
    Toks::DB::Subscription->new(
        user_id   => $user->get_column('id'),
        thread_id => 123
    )->create;
    my $helper = _build_helper('tu.user' => $user);

    ok $helper->is_subscribed({id => 123});
};

my $env;

sub _build_helper {
    $env = TestRequest->to_env(@_);
    Toks::Helper::Subscription->new(env => $env);
}

done_testing;
