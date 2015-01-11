use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Reply;
use Threads::DB::Subscription;
use Threads::Action::DeleteThread;

subtest 'returns 404 when unknown thread' => sub {
    TestDB->setup;

    my $action = _build_action(captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when wrong user' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Threads::DB::Thread->new(user_id => 2)->create;

    my $action = _build_action(
        captures  => {id => $thread->id},
        'tu.user' => $user
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when thread is not empty' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Threads::DB::Thread->new(user_id => $user->id)->create;
    Threads::DB::Reply->new(
        user_id   => $user->id,
        thread_id => $thread->id
    )->create;

    my $action = _build_action(
        captures  => {id => $thread->id},
        'tu.user' => $user
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'deletes thread' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Threads::DB::Thread->new(user_id => $user->id)->create;

    my $action = _build_action(
        captures  => {id => $thread->id},
        'tu.user' => $user
    );

    $action->run;

    ok !Threads::DB::Thread->find(first => 1);
};

subtest 'deletes thread subscriptions' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Threads::DB::Thread->new(user_id => $user->id)->create;

    Threads::DB::Subscription->new(
        user_id   => $user->id,
        thread_id => $thread->id
    )->create;

    Threads::DB::Subscription->new(
        user_id   => $user->id,
        thread_id => 999
    )->create;

    my $action = _build_action(
        captures  => {id => $thread->id},
        'tu.user' => $user
    );

    $action->run;

    is(Threads::DB::Subscription->table->count, 1);
};

subtest 'redirects' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Threads::DB::Thread->new(user_id => $user->id)->create;

    my $action = _build_action(
        captures  => {id => $thread->id},
        'tu.user' => $user
    );

    $action->mock('redirect');

    $action->run;

    my ($name) = $action->mocked_call_args('redirect');

    is $name, 'index';
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::DeleteThread->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
