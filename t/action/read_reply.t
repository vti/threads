use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use JSON qw(decode_json);
use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Reply;
use Threads::DB::Notification;
use Threads::Action::ReadReply;

subtest 'returns 404 when unknown reply' => sub {
    TestDB->setup;

    my $action = _build_action(captures => {});

    my $res = $action->run;

    is $res->code, 404;
};

subtest 'deletes notification' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    my $reply = Threads::DB::Reply->new(thread_id => 1, user_id => 2)->create;
    TestDB->create(
        'Notification',
        reply_id => $reply->id,
        user_id  => $user->id
    );

    my $action = _build_action(
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    is(Threads::DB::Notification->table->count, 0);
};

subtest 'returns zero unread count' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    my $reply = Threads::DB::Reply->new(thread_id => 1, user_id => 2)->create;
    TestDB->create(
        'Notification',
        reply_id => $reply->id,
        user_id  => $user->id
    );

    my $action = _build_action(
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    is decode_json($res->body)->{count}, 0;
};

subtest 'returns unread count' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    my $reply = Threads::DB::Reply->new(thread_id => 1, user_id => 2)->create;
    TestDB->create('Notification', reply_id => $_, user_id => $user->id)
      for 1 .. 5;

    my $action = _build_action(
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    is decode_json($res->body)->{count}, 4;
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::ReadReply->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
