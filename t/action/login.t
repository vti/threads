use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Nonce;
use Threads::Action::Login;

subtest 'set template var errors' => sub {
    my $action = _build_action(req => POST('/' => {}));

    $action->run;

    ok $action->vars->{errors};
};

subtest 'set template error when invalid email' => sub {
    my $action =
      _build_action(req => POST('/' => {email => 'foo', password => 'bar'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Invalid email';
};

subtest 'set template error when unknown email' => sub {
    TestDB->setup;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Unknown credentials';
};

subtest 'set template error when wrong password' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'silly')
      ->create;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Unknown credentials';
};

subtest 'set template error when not active' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly',
    )->create;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Account not activated';
};

subtest 'set template error when blocked' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(
        email    => 'foo@bar.com',
        status   => 'blocked',
        password => 'silly',
    )->create;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Account blocked';
};

subtest 'set template error when other status' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(
        email    => 'foo@bar.com',
        status   => 'other',
        password => 'silly',
    )->create;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Account not active';
};

subtest 'calls login' => sub {
    TestDB->setup;

    my $auth = Test::MonkeyMock->new;
    $auth->mock(login => sub { });

    my $user = Threads::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly',
        status   => 'active'
    )->create;

    my $action = _build_action(
        req       => POST('/' => {email => 'foo@bar.com', password => 'silly'}),
        'tu.auth' => $auth
    );

    $action->run;

    ok $auth->mocked_called('login');
};

subtest 'creates nonce' => sub {
    TestDB->setup;

    my $auth = Test::MonkeyMock->new;
    $auth->mock(login => sub { });

    my $user = Threads::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly',
        status   => 'active'
    )->create;

    my $action = _build_action(
        req       => POST('/' => {email => 'foo@bar.com', password => 'silly'}),
        'tu.auth' => $auth
    );

    $action->run;

    my $nonce = Threads::DB::Nonce->find(first => 1);

    ok $nonce;
    is $nonce->get_column('user_id'), $user->get_column('id');
};

subtest 'redirect to root' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly',
        status   => 'active'
    )->create;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}));

    my $res = $action->run;

    is $res->code, 302;
};

sub _build_action {
    my (%params) = @_;

    $params{'tu.auth'} ||= do {
        my $auth = Test::MonkeyMock->new;
        $auth->mock(login => sub { });
    };

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::Login->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });

    return $action;
}

done_testing;
