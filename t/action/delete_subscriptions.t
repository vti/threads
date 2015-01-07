use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Toks::DB::User;
use Toks::DB::Subscription;
use Toks::Action::DeleteSubscriptions;

subtest 'deletes all subscriptions' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    Toks::DB::Subscription->new(user_id => $user->get_column('id'), thread_id => 1)->create;
    Toks::DB::Subscription->new(user_id => 123, thread_id => 1)->create;

    my $action = _build_action(req => POST('/' => {}), captures => {}, 'tu.user' => $user);

    $action->run;

    is(Toks::DB::Subscription->table->count, 1);
};

subtest 'returns redirect' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    Toks::DB::Subscription->new(user_id => $user->get_column('id'), thread_id => 1)->create;

    my $action = _build_action(req => POST('/' => {}), captures => {}, 'tu.user' => $user);

    my ($json) = $action->run;

    ok $json->{redirect};
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::DeleteSubscriptions->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
