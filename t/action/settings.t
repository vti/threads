use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Toks::DB::User;
use Toks::Action::Settings;

subtest 'update settings' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    my $action = _build_action(
        req => POST(
            '/' => {name => 'foo'}
        ),
        'tu.user' => $user
    );

    $action->run;

    $user->load;

    is $user->get_column('name'), 'foo';
};

subtest 'show validation error when name exists' => sub {
    TestDB->setup;

    Toks::DB::User->new(
        email    => 'foo2@bar.com',
        name     => 'exists',
        password => 'silly'
    )->create;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    my $action = _build_action(
        req => POST(
            '/' => {name => 'exists'}
        ),
        'tu.user' => $user
    );

    $action->run;

    is $action->vars->{errors}->{name}, 'Name already exists';
};

subtest 'update settings with same name' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(
        email    => 'foo@bar.com',
        name     => 'foo',
        password => 'silly'
    )->create;
    my $action = _build_action(
        req => POST(
            '/' => {name => 'foo'}
        ),
        'tu.user' => $user
    );

    $action->run;

    ok !$action->vars->{errors};
};

subtest 'redirects' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    my $action = _build_action(
        req => POST(
            '/' => {name => 'foo'}
        ),
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

    my $action = Toks::Action::Settings->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
