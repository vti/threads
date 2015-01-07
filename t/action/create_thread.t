use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Toks::DB::User;
use Toks::DB::Thread;
use Toks::DB::Subscription;
use Toks::Action::CreateThread;

subtest 'returns nothing on GET' => sub {
    my $action = _build_action();

    ok !defined $action->run;
};

subtest 'set template var errors' => sub {
    my $action = _build_action(req => POST('/' => {}));

    $action->run;

    $action->env;

    ok $action->scope->displayer->vars->{errors};
};

subtest 'creates thread with correct params' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;

    my $action = _build_action(
        req       => POST('/' => {title => 'This is a title, with ?# symbols', content => 'bar'}),
        'tu.user' => $user
    );

    $action->run;

    my $thread = Toks::DB::Thread->find(first => 1);

    ok $thread;
    is $thread->get_column('user_id'),   $user->get_column('id');
    is $thread->get_column('slug'),   'this-is-a-title-with-symbols';
    is $thread->get_column('title'),   'This is a title, with ?# symbols';
    is $thread->get_column('content'), 'bar';
};

subtest 'redirects to thread view' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;

    my $action = _build_action(
        req       => POST('/' => {title => 'foo', content => 'bar'}),
        'tu.user' => $user
    );

    $action->mock('redirect');

    $action->run;

    my ($name) =  $action->mocked_call_args('redirect');

    is $name, 'view_thread';
};

subtest 'creates subscription' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;

    my $action = _build_action(
        req       => POST('/' => {title => 'foo', content => 'bar'}),
        'tu.user' => $user
    );

    $action->mock('redirect');

    $action->run;

    my $thread = Toks::DB::Thread->find(first => 1);
    my $subscription = Toks::DB::Subscription->find(first => 1);

    ok $subscription;
    is $subscription->get_column('user_id'), $user->get_column('id');
    is $subscription->get_column('thread_id'), $thread->get_column('id');
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::CreateThread->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
