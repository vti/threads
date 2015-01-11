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
use Threads::DB::Notification;
use Threads::Action::DeleteReply;

subtest 'returns 404 when unknown reply' => sub {
    TestDB->setup;

    my $action = _build_action(captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when wrong user' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(thread_id => 1, user_id => 2)->create;

    my $action = _build_action(
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when reply is not empty' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $reply =
      Threads::DB::Reply->new(thread_id => 1, user_id => $user->id)
      ->create;
    $reply->create_related(
        'ansestors',
        thread_id => 1,
        user_id   => 1,
        content   => 'foo'
    );

    my $action = _build_action(
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'deletes reply' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Threads::DB::Thread->new(user_id => 1)->create;
    my $reply = Threads::DB::Reply->new(
        thread_id => $thread->id,
        user_id   => $user->id
    )->create;

    my $action = _build_action(
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    ok !Threads::DB::Reply->find(first => 1);
};

subtest 'deletes reply notifications' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Threads::DB::Thread->new(user_id => 1)->create;
    my $reply = Threads::DB::Reply->new(
        thread_id => $thread->id,
        user_id   => $user->id
    )->create;

    Threads::DB::Notification->new(
        user_id  => $user->id,
        reply_id => $reply->id
    )->create;
    Threads::DB::Notification->new(
        user_id  => $user->id,
        reply_id => 999
    )->create;

    my $action = _build_action(
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    is(Threads::DB::Notification->table->count, 1);
};

subtest 'updates thread reply counter' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Threads::DB::Thread->new(user_id => 1, replies_count => 10)->create;
    my $reply = Threads::DB::Reply->new(
        thread_id => $thread->id,
        user_id   => $user->id
    )->create;

    my $action = _build_action(
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    $thread->load;

    is $thread->replies_count, 0;
};

subtest 'redirects' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Threads::DB::Thread->new(user_id => 1)->create;
    my $reply = Threads::DB::Reply->new(
        thread_id => $thread->id,
        user_id   => $user->id
    )->create;

    my $action = _build_action(
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    $action->mock('redirect');

    $action->run;

    my ($name, %params) = $action->mocked_call_args('redirect');

    is $name, 'view_thread';
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::DeleteReply->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
