use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use Toks::DB::User;
use Toks::DB::Thread;
use Toks::Action::DeleteThread;

subtest 'returns 404 when unknown thread' => sub {
    TestDB->setup;

    my $action = _build_action(captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when wrong user' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(user_id => 2)->create;

    my $action = _build_action(
        captures  => {id => $thread->get_column('id')},
        'tu.user' => $user
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'deletes thread' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        captures  => {id => $thread->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    ok !Toks::DB::Thread->find(first => 1);
};

subtest 'redirects' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo', password => 'bar')->create;
    my $thread = Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;

    my $action = _build_action(
        captures  => {id => $thread->get_column('id')},
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

    my $action = Toks::Action::DeleteThread->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
