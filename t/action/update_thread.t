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
use Toks::Action::UpdateThread;

subtest 'returns 404 when unknown thread' => sub {
    TestDB->setup;

    my $action = _build_action(captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when wrong user' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(user_id => 999)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'set template var errors' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread =
      Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    ok $action->scope->displayer->vars->{errors};
};

subtest 'updates thread with correct params' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(
        user_id => $user->get_column('id'),
        title   => 'foo',
        content => 'bar'
    )->create;

    my $action = _build_action(
        req => POST('/' => {title => 'bar', content => 'foo'}),
        captures  => {id => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    $thread->load;

    is $thread->get_column('title'),     'bar';
    is $thread->get_column('content'),   'foo';
    isnt $thread->get_column('updated'), 0;
};

subtest 'updates last_activity' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(
        user_id       => $user->get_column('id'),
        title         => 'foo',
        content       => 'bar',
        last_activity => 123
    )->create;

    my $action = _build_action(
        req => POST('/' => {title => 'bar', content => 'foo'}),
        captures  => {id => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    $thread->load;

    isnt $thread->get_column('last_activity'), 123;
};

subtest 'redirects after update' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(
        user_id => $user->get_column('id'),
        title   => 'foo',
        content => 'bar'
    )->create;

    my $action = _build_action(
        req => POST('/' => {title => 'bar', content => 'foo'}),
        captures  => {id => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->mock('redirect');

    $action->run;

    my ($name) = $action->mocked_call_args('redirect');

    is $name, 'view_thread';
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::UpdateThread->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
