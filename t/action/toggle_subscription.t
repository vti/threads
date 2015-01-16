use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use JSON qw(decode_json);
use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Subscription;
use Threads::Action::ToggleSubscription;

subtest 'returns 404 when unknown thread' => sub {
    TestDB->setup;

    my $action = _build_action(req => POST('/' => {}), captures => {});

    my $res = $action->run;

    is $res->code, 404;
};

subtest 'creates subscription' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->id)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->id},
        'tu.user' => $user
    );

    $action->run;

    my $subscription = Threads::DB::Subscription->find(first => 1);

    ok $subscription;
    is $subscription->user_id,   $user->id;
    is $subscription->thread_id, $thread->id;
};

subtest 'creates subscription' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->id)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->id},
        'tu.user' => $user
    );

    $action->run;

    my $subscription = Threads::DB::Subscription->find(first => 1);

    ok $subscription;
    is $subscription->user_id,   $user->id;
    is $subscription->thread_id, $thread->id;
};

subtest 'returns state when subscription created' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->id)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    is decode_json($res->body)->{state}, 1;
};

subtest 'removes subscription' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->id)->create;
    Threads::DB::Subscription->new(
        user_id   => $user->id,
        thread_id => $thread->id
    )->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->id},
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
      Threads::DB::Thread->new(user_id => $user->id)->create;
    Threads::DB::Subscription->new(
        user_id   => $user->id,
        thread_id => $thread->id
    )->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    is decode_json($res->body)->{state}, 0;
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::ToggleSubscription->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
