use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Toks::DB::User;
use Toks::DB::Confirmation;
use Toks::Action::Register;

subtest 'returns nothing on GET' => sub {
    my $action = _build_action();

    ok !defined $action->run;
};

subtest 'set template var errors' => sub {
    my $action = _build_action(req => POST('/' => {}));

    $action->run;

    my $env = $action->env;

    ok $env->{'tu.displayer.vars'}->{errors};
};

subtest 'set template error when invalid email' => sub {
    my $action =
      _build_action(req => POST('/' => {email => 'foo', password => 'bar'}));

    $action->run;

    my $env = $action->env;

    is $env->{'tu.displayer.vars'}->{errors}->{email}, 'Invalid email';
};

subtest 'set template error when email exists' => sub {
    TestDB->setup;

    Toks::DB::User->new(email => 'foo@bar.com')->create;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}));

    $action->run;

    my $env = $action->env;

    is $env->{'tu.displayer.vars'}->{errors}->{email}, 'User exists';
};

subtest 'create user with correct params' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}),
        'tu.displayer.vars' => {lang => 'ru'}
    );

    $action->run;

    my $user = Toks::DB::User->find(first => 1);

    ok $user;
    is $user->get_column('status'),     'new';
    is $user->get_column('email'),      'foo@bar.com';
    is $user->get_column('name'),       'foo';
    isnt $user->get_column('password'), 'bar';
    like $user->get_column('created'),  qr/^\d+$/;
};

subtest 'create confirmation token with correct params' => sub {
    TestDB->setup;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}));

    $action->run;

    my $confirmation = Toks::DB::Confirmation->find(first => 1);

    ok $confirmation;
    is $confirmation->get_column('user_id'),
      Toks::DB::User->find(first => 1)->get_column('id');
    like $confirmation->get_column('token'), qr/^[a-z0-9]+$/i;
};

subtest 'send email' => sub {
    TestDB->setup;

    my $mailer = _mock_mailer();

    my $action = _build_action(
        req    => POST('/' => {email => 'foo@bar.com', password => 'bar'}),
        mailer => $mailer
    );

    $action->run;

    my (%mail) = $mailer->mocked_call_args('send');
    is_deeply \%mail,
      {
        headers =>
          [To => 'foo@bar.com', Subject => 'Registration confirmation'],
        body => ''
      };
};

sub _mock_mailer {
    my $mailer = Test::MonkeyMock->new;
    $mailer->mock(send => sub { });

    return $mailer;
}

sub _build_action {
    my (%params) = @_;

    my $env    = $params{env}    || TestRequest->to_env(%params);
    my $mailer = $params{mailer} || _mock_mailer();

    my $action = Toks::Action::Register->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });
    $action->mock(mailer => sub { $mailer });

    return $action;
}

done_testing;
