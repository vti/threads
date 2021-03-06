use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use JSON qw(decode_json);
use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Notification;
use Threads::DB::Thread;
use Threads::DB::Reply;
use Threads::Action::UpdateReply;

subtest 'returns 404 when unknown reply' => sub {
    TestDB->setup;

    my $action = _build_action(captures => {});

    my $res = $action->run;

    is $res->code, 404;
};

subtest 'returns 404 when wrong user' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    my $reply = Threads::DB::Reply->new(thread_id => 123, user_id => 999)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    is $res->code, 404;
};

subtest 'returns 404 when has ansestors' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    my $reply = Threads::DB::Reply->new(thread_id => 123, user_id => $user->id)->create;
    $reply->create_related('ansestors', thread_id => 123, user_id => 123);

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    is $res->code, 404;
};

subtest 'shows errors' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    my $reply =
      Threads::DB::Reply->new(thread_id => 1, user_id => $user->id)
      ->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    ok decode_json($res->body)->{errors};
};

subtest 'updates reply with correct params' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    my $thread =
      Threads::DB::Thread->new(user_id => $user->id)->create;
    my $reply = Threads::DB::Reply->new(
        user_id   => $user->id,
        thread_id => $thread->id,
        title     => 'foo',
        content   => 'bar'
    )->create;

    my $action = _build_action(
        req       => POST('/' => {content => 'foo'}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    $reply->load;

    is $reply->content, 'foo';
    isnt $reply->updated, 0;
};

subtest 'notifies mentioned users' => sub {
    TestDB->setup;

    my $thread_user = TestDB->create('User', name => 'foo');
    my $thread =
      Threads::DB::Thread->new(user_id => $thread_user->id)->create;

    my $user = TestDB->create('User', name => 'user', email => 'user@bar.com');
    my $reply = Threads::DB::Reply->new(
        user_id   => $user->id,
        thread_id => $thread->id,
        title     => 'foo',
        content   => 'bar'
    )->create;

    my $action = _build_action(
        req => POST('/' => {content => '@foo'}),
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    my $notification = Threads::DB::Notification->find(
        first => 1,
        where => [reply_id => $reply->id, user_id => $thread_user->id]
    );

    ok $notification;
};

subtest 'redirects after update' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    my $thread =
      Threads::DB::Thread->new(user_id => $user->id)->create;
    my $reply = Threads::DB::Reply->new(
        user_id   => $user->id,
        thread_id => $thread->id,
        title     => 'foo',
        content   => 'bar'
    )->create;

    my $action = _build_action(
        req => POST('/' => {title => 'bar', content => 'foo'}),
        captures  => {id => $reply->id},
        'tu.user' => $user
    );

    $action->mock('url_for');

    my $res = $action->run;

    my ($name) = $action->mocked_call_args('url_for');

    is $name, 'view_thread';

    ok decode_json($res->body)->{redirect};
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::UpdateReply->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
