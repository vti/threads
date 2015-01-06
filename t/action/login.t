use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Toks::DB::User;
use Toks::Action::Login;

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
      Toks::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Unknown credentials';
};

subtest 'set template error when not active' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly',
    )->create;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Account not activated';
};

subtest 'set session' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly',
        status   => 'active'
    )->create;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}));

    $action->run;

    is_deeply $action->env->{'psgix.session'},
      {user_id => $user->get_column('id')};
};

subtest 'redirect to root' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(
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

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::Login->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });

    return $action;
}

done_testing;
