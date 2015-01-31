use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Confirmation;
use Threads::Action::Register;

subtest 'returns nothing on GET' => sub {
    my $action = _build_action();

    ok !defined $action->run;
};

subtest 'set template var errors' => sub {
    my $action = _build_action(req => POST('/' => {}));

    $action->run;

    ok $action->vars->{errors};
};

subtest 'set template error when invalid name' => sub {
    my $action =
      _build_action(req => POST('/' => {name => '&#', email => 'foo', password => 'bar'}));

    $action->run;

    is $action->vars->{errors}->{name}, 'Invalid name';
};

subtest 'set template error when invalid email' => sub {
    my $action =
      _build_action(req => POST('/' => {name => 'foo', email => 'foo', password => 'bar'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Invalid email';
};

subtest 'set template error when name exists' => sub {
    TestDB->setup;

    TestDB->create('User', name => 'foo');

    my $action = _build_action(
        req => POST(
            '/' => {name => 'foo', email => 'foo@bar.com', password => 'bar'}
        )
    );

    $action->run;

    is $action->vars->{errors}->{name}, 'User exists';
};

subtest 'set template error when email exists' => sub {
    TestDB->setup;

    TestDB->create('User', email => 'foo@bar.com');

    my $action = _build_action(
        req => POST(
            '/' => {name => 'foo2', email => 'foo@bar.com', password => 'bar'}
        )
    );

    $action->run;

    is $action->vars->{errors}->{email}, 'User exists';
};

subtest 'create user with correct params' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST(
            '/' => {name => 'foo', email => 'foo@bar.com', password => 'bar'}
        ),
        'tu.displayer.vars' => {lang => 'ru'}
    );

    $action->run;

    my $user = Threads::DB::User->find(first => 1);

    ok $user;
    is $user->status,     'new';
    is $user->email,      'foo@bar.com';
    isnt $user->password, 'bar';
    like $user->created,  qr/^\d+$/;
};

subtest 'create user with name from email' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST(
            '/' => {name => 'foo', email => 'foo@bar.com', password => 'bar'}
        ),
        'tu.displayer.vars' => {lang => 'ru'}
    );

    $action->run;

    my $user = Threads::DB::User->find(first => 1);

    is $user->name, 'foo';
};

subtest 'create confirmation token with correct params' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST(
            '/' => {name => 'foo', email => 'foo@bar.com', password => 'bar'}
        )
    );

    $action->run;

    my $confirmation = Threads::DB::Confirmation->find(first => 1);

    ok $confirmation;
    is $confirmation->user_id, Threads::DB::User->find(first => 1)->id;
    isnt $confirmation->token, '';
    is $confirmation->type,    'register';
};

subtest 'sends email' => sub {
    TestDB->setup;

    my $mailer = _mock_mailer();

    my $action = _build_action(
        req => POST(
            '/' => {name => 'foo', email => 'foo@bar.com', password => 'bar'}
        ),
        mailer => $mailer
    );

    $action->run;

    my ($template, %params) = $action->mocked_call_args('render');
    is $template, 'email/confirmation_required';
    is $params{vars}{email},   'foo@bar.com';
    like $params{vars}{token}, qr/^[a-f0-9]+$/;

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

sub _mock_services {
    my (%params) = @_;

    my $services = Test::MonkeyMock->new;
    $services->mock(
        service => sub { {} },
        when    => sub { $_[1] eq 'config' }
    );

    return $services;
}

sub _build_action {
    my (%params) = @_;

    my $env      = $params{env}      || TestRequest->to_env(%params);
    my $mailer   = $params{mailer}   || _mock_mailer();
    my $services = $params{services} || _mock_services();

    my $action =
      Threads::Action::Register->new(env => $env, services => $services);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });
    $action->mock(mailer => sub { $mailer });

    return $action;
}

done_testing;
