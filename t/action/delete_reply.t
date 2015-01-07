use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use Toks::DB::User;
use Toks::DB::Thread;
use Toks::DB::Reply;
use Toks::Action::DeleteReply;

subtest 'returns 404 when unknown reply' => sub {
    TestDB->setup;

    my $action = _build_action(captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when wrong user' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo', password => 'bar')->create;
    my $reply = Toks::DB::Reply->new(thread_id => 1, user_id => 2)->create;

    my $action = _build_action(
        captures  => {id => $reply->get_column('id')},
        'tu.user' => $user
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when reply is not empty' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo', password => 'bar')->create;
    my $reply =
      Toks::DB::Reply->new(thread_id => 1, user_id => $user->get_column('id'))
      ->create;
    $reply->create_related(
        'ansestors',
        thread_id => 1,
        user_id   => 1,
        content   => 'foo'
    );

    my $action = _build_action(
        captures  => {id => $reply->get_column('id')},
        'tu.user' => $user
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'deletes reply' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(user_id => 1)->create;
    my $reply = Toks::DB::Reply->new(
        thread_id => $thread->get_column('id'),
        user_id   => $user->get_column('id')
    )->create;

    my $action = _build_action(
        captures  => {id => $reply->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    ok !Toks::DB::Reply->find(first => 1);
};

subtest 'updates thread reply counter' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(user_id => 1, replies_count => 10)->create;
    my $reply = Toks::DB::Reply->new(
        thread_id => $thread->get_column('id'),
        user_id   => $user->get_column('id')
    )->create;

    my $action = _build_action(
        captures  => {id => $reply->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    $thread->load;

    is $thread->get_column('replies_count'), 0;
};

subtest 'redirects' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(user_id => 1)->create;
    my $reply = Toks::DB::Reply->new(
        thread_id => $thread->get_column('id'),
        user_id   => $user->get_column('id')
    )->create;

    my $action = _build_action(
        captures  => {id => $reply->get_column('id')},
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

    my $action = Toks::Action::DeleteReply->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
