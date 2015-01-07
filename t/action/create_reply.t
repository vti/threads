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

subtest 'set template var errors' => sub {
    TestDB->setup;

    my $thread = Toks::DB::Thread->new(user_id => 1)->create;
    my $action = _build_action(
        req      => POST('/' => {}),
        captures => {id      => $thread->get_column('id')}
    );

    $action->run;

    ok $action->scope->displayer->vars->{errors};
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

    is $thread->get_column('replies_count'), 1
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

    my ($name, %params) = $action->mocked_call_args('redirect');

    is $name, 'view_thread';
    is_deeply \%params, {id => $thread->get_column('id')};
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::CreateReply->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
