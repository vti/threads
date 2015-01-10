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
use Threads::DB::Reply;
use Threads::DB::Subscription;
use Threads::DB::Notification;
use Threads::Action::CreateReply;

subtest 'returns 404 when unknown thread' => sub {
    TestDB->setup;

    my $action = _build_action(req => POST('/' => {}), captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when unknown to' => sub {
    TestDB->setup;

    my $thread = Threads::DB::Thread->new(user_id => 1)->create;
    my $action = _build_action(
        req      => POST('/?to=123' => {}),
        captures => {id             => $thread->get_column('id')}
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'shows errors' => sub {
    TestDB->setup;

    my $thread = Threads::DB::Thread->new(user_id => 1)->create;
    my $action = _build_action(
        req      => POST('/' => {}),
        captures => {id      => $thread->get_column('id')}
    );

    my ($json) = $action->run;

    ok $json->{errors};
};

subtest 'shows errors when limits' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $services = _mock_services(config => {limits => {replies => {60 => 5}}});
    my $action = _build_action(
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user,
        services => $services
    );

    $action->run for 1 .. 10;

    is(Threads::DB::Reply->table->count, 5);
    is $action->vars->{errors}->{content}, 'Replying too often';
};

subtest 'creates reply with correct params' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    my $reply = Threads::DB::Reply->find(first => 1);

    ok $reply;
    is $reply->get_column('user_id'),   $user->get_column('id');
    is $reply->get_column('thread_id'), $thread->get_column('id');
    is $reply->get_column('content'),   'bar';
};

subtest 'creates reply with correct params when parent present' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->get_column('id'))->create;
    my $parent = Threads::DB::Reply->new(
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

    my $reply = Threads::DB::Reply->find(first => 1, order_by => [id => 'DESC']);

    is $reply->get_column('parent_id'), $parent->get_column('id');
};

subtest 'updates replies_count in thread' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->get_column('id'))->create;

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
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread = Threads::DB::Thread->new(
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
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );
    $action->mock('url_for');

    my ($json) = $action->run;

    my ($name) = $action->mocked_call_args('url_for');
    is $name, 'view_thread';

    ok $json->{redirect};
};

subtest 'does not notify thread author when same replier' => sub {
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
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    ok !Threads::DB::Notification->find(first => 1);
};

subtest 'notify subscribed users' => sub {
    TestDB->setup;

    my $thread_author =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $thread_author->get_column('id'))
      ->create;
    Threads::DB::Subscription->new(
        user_id   => $thread_author->get_column('id'),
        thread_id => $thread->get_column('id')
    )->create;

    my $user2 =
      Threads::DB::User->new(email => 'foo2@bar.com', password => 'bar')->create;
    Threads::DB::Subscription->new(
        user_id   => $user2->get_column('id'),
        thread_id => $thread->get_column('id')
    )->create;

    my $action = _build_action(
        req       => POST('/' => {content => 'bar'}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user2
    );

    $action->run;

    my $reply = Threads::DB::Reply->find(first => 1);
    my $notification = Threads::DB::Notification->find(first => 1);

    is(Threads::DB::Notification->table->count, 1);

    ok $notification;
    is $notification->get_column('user_id'),  $thread_author->get_column('id');
    is $notification->get_column('reply_id'), $reply->get_column('id');
};

subtest 'notify parent reply user' => sub {
    TestDB->setup;

    my $thread_author =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $thread_author->get_column('id'))
      ->create;

    my $user =
      Threads::DB::User->new(email => 'foo2@bar.com', password => 'bar')->create;

    my $parent_reply = Threads::DB::Reply->new(
        thread_id => $thread->get_column('id'),
        user_id   => $user->get_column('id')
    )->create;

    my $user2 =
      Threads::DB::User->new(email => 'foo3@bar.com', password => 'bar')->create;

    my $action = _build_action(
        req =>
          POST('/?to=' . $parent_reply->get_column('id') => {content => 'bar'}),
        captures  => {id => $thread->get_column('id')},
        'tu.user' => $user2
    );

    $action->run;

    my $reply = Threads::DB::Reply->find(first => 1, order_by => [id => 'DESC']);
    my $notification = Threads::DB::Notification->find(first => 1);

    is(Threads::DB::Notification->table->count, 1);

    ok $notification;
    is $notification->get_column('user_id'),  $user->get_column('id');
    is $notification->get_column('reply_id'), $reply->get_column('id');
};

subtest 'not notify parent reply user when same user' => sub {
    TestDB->setup;

    my $thread_author =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread =
      Threads::DB::Thread->new(user_id => $thread_author->get_column('id'))
      ->create;

    my $user =
      Threads::DB::User->new(email => 'foo2@bar.com', password => 'bar')->create;

    my $parent_reply = Threads::DB::Reply->new(
        thread_id => $thread->get_column('id'),
        user_id   => $user->get_column('id')
    )->create;

    my $action = _build_action(
        req =>
          POST('/?to=' . $parent_reply->get_column('id') => {content => 'bar'}),
        captures  => {id => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    my $reply = Threads::DB::Reply->find(first => 1, order_by => [id => 'DESC']);
    my $notification = Threads::DB::Notification->find(first => 1);

    is(Threads::DB::Notification->table->count, 0);
};

sub _mock_services {
    my (%params) = @_;

    my $services = Test::MonkeyMock->new;
    $services->mock(
        service => sub { $params{config} || {} },
        when => sub { $_[1] eq 'config' }
    );
    return $services;
}

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::CreateReply->new(
        env      => $env,
        services => $params{services} || _mock_services()
    );
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
