use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Subscription;
use Threads::Action::ToggleSubscription;

subtest 'returns 404 when unknown thread' => sub {
    TestDB->setup;

    my $action = _build_action(req => POST('/' => {}), captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'creates subscription' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    my $subscription = Threads::DB::Subscription->find(first => 1);

    ok $subscription;
    is $subscription->get_column('user_id'),   $user->get_column('id');
    is $subscription->get_column('thread_id'), $thread->get_column('id');
};

subtest 'creates subscription' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    my $subscription = Threads::DB::Subscription->find(first => 1);

    ok $subscription;
    is $subscription->get_column('user_id'),   $user->get_column('id');
    is $subscription->get_column('thread_id'), $thread->get_column('id');
};

subtest 'returns state when subscription created' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    my ($json) = $action->run;

    is $json->{state}, 1;
};

subtest 'removes subscription' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->get_column('id'))->create;
    Threads::DB::Subscription->new(
        user_id   => $user->get_column('id'),
        thread_id => $thread->get_column('id')
    )->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    my $subscription = Threads::DB::Subscription->find(first => 1);

    ok !$subscription;
};

subtest 'returns state when subscription deleted' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->get_column('id'))->create;
    Threads::DB::Subscription->new(
        user_id   => $user->get_column('id'),
        thread_id => $thread->get_column('id')
    )->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    my ($json) = $action->run;

    is $json->{state}, 0;
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::ToggleSubscription->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
