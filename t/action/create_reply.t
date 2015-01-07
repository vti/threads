use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Toks::DB::User;
use Toks::DB::Thread;
use Toks::DB::Reply;
use Toks::DB::Subscription;
use Toks::DB::Notification;
use Toks::Action::CreateReply;

subtest 'returns 404 when unknown thread' => sub {
    TestDB->setup;

    my $action = _build_action(req => POST('/' => {}), captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when unknown to' => sub {
    TestDB->setup;

    my $thread = Toks::DB::Thread->new(user_id => 1)->create;
    my $action = _build_action(
        req      => POST('/?to=123' => {}),
        captures => {id             => $thread->get_column('id')}
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'throws 404 on errors' => sub {
    TestDB->setup;

    my $thread = Toks::DB::Thread->new(user_id => 1)->create;
    my $action = _build_action(
        req      => POST('/' => {}),
        captures => {id      => $thread->get_column('id')}
    );

    my $e = exception { $action->run };

    is $e->code, 400;
};

subtest 'creates reply with correct params' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    my $reply = Toks::DB::Reply->find(first => 1);

    ok $reply;
    is $reply->get_column('user_id'),   $user->get_column('id');
    is $reply->get_column('thread_id'), $thread->get_column('id');
    is $reply->get_column('content'),   'bar';
};

subtest 'creates reply with correct params when parent present' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;
    my $parent = Toks::DB::Reply->new(
        user_id   => $user->get_column('id'),
        thread_id => $thread->get_column('id')
    )->create;

    my $action = _build_action(
        req => POST(
            '/?to=' . $parent->get_column('id') => {content => 'bar'}
        ),
        captures  => {id => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    my $reply = Toks::DB::Reply->find(first => 1, order_by => [id => 'DESC']);

    is $reply->get_column('parent_id'), $parent->get_column('id');
};

subtest 'updates replies_count in thread' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    $thread->load;

    is $thread->get_column('replies_count'), 1;
};

subtest 'updates last_activity in thread' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(
        user_id       => $user->get_column('id'),
        last_activity => '123'
    )->create;
    my $last_activity = $thread->get_column('last_activity');

    my $action = _build_action(
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    $thread->load;

    isnt $thread->get_column('last_activity'), $last_activity;
};

subtest 'redirects to thread view' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );
    $action->mock('redirect');

    $action->run;

    my ($name) = $action->mocked_call_args('redirect');

    is $name, 'view_thread';
};

subtest 'does not notify thread author when same replier' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;
    Toks::DB::Subscription->new(
        user_id   => $user->get_column('id'),
        thread_id => $thread->get_column('id')
    )->create;

    my $action = _build_action(
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    ok !Toks::DB::Notification->find(first => 1);
};

subtest 'notify subscribed users' => sub {
    TestDB->setup;

    my $thread_author =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Toks::DB::Thread->new(user_id => $thread_author->get_column('id'))
      ->create;
    Toks::DB::Subscription->new(
        user_id   => $thread_author->get_column('id'),
        thread_id => $thread->get_column('id')
    )->create;

    my $user2 =
      Toks::DB::User->new(email => 'foo2@bar.com', password => 'bar')->create;
    Toks::DB::Subscription->new(
        user_id   => $user2->get_column('id'),
        thread_id => $thread->get_column('id')
    )->create;

    my $action = _build_action(
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user2
    );

    $action->run;

    my $reply = Toks::DB::Reply->find(first => 1);
    my $notification = Toks::DB::Notification->find(first => 1);

    is(Toks::DB::Notification->table->count, 1);

    ok $notification;
    is $notification->get_column('user_id'),  $thread_author->get_column('id');
    is $notification->get_column('reply_id'), $reply->get_column('id');
};

subtest 'notify parent reply user' => sub {
    TestDB->setup;

    my $thread_author =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Toks::DB::Thread->new(user_id => $thread_author->get_column('id'))
      ->create;

    my $user =
      Toks::DB::User->new(email => 'foo2@bar.com', password => 'bar')->create;

    my $parent_reply = Toks::DB::Reply->new(
        thread_id => $thread->get_column('id'),
        user_id   => $user->get_column('id')
    )->create;

    my $user2 =
      Toks::DB::User->new(email => 'foo3@bar.com', password => 'bar')->create;

    my $action = _build_action(
        req =>
          POST('/?to=' . $parent_reply->get_column('id') => {content => 'bar'}),
        captures  => {id => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    my $reply = Toks::DB::Reply->find(first => 1, order_by => [id => 'DESC']);
    my $notification = Toks::DB::Notification->find(first => 1);

    is(Toks::DB::Notification->table->count, 1);

    ok $notification;
    is $notification->get_column('user_id'),  $user->get_column('id');
    is $notification->get_column('reply_id'), $reply->get_column('id');
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::CreateReply->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
