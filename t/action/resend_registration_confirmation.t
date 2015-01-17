use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Confirmation;
use Threads::Action::ResendRegistrationConfirmation;

subtest 'returns nothing on GET' => sub {
    my $action = _build_action();

    ok !defined $action->run;
};

subtest 'set template var errors' => sub {
    my $action = _build_action(req => POST('/' => {}));

    $action->run;

    ok $action->vars->{errors};
};

subtest 'set template error when unknown email' => sub {
    TestDB->setup;

    my $action =
      _build_action(req => POST('/' => {email => 'foo@bar.com', password => 'bar'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Unknown credentials';
};

subtest 'set template error when wrong password' => sub {
    TestDB->setup;

    TestDB->create('User');

    my $action =
      _build_action(req => POST('/' => {email => 'foo@bar.com', password => 'bar'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Unknown credentials';
};

subtest 'set template error when not need for confirmation' => sub {
    TestDB->setup;

    TestDB->create('User', status => 'active');

    my $action =
      _build_action(req => POST('/' => {email => 'foo@bar.com', password => 'silly'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Account does not need activation';
};

subtest 'set template error when confirmation not expired' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    TestDB->create('Confirmation', user_id => $user->id, type => 'register');

    my $action =
      _build_action(req => POST('/' => {email => 'foo@bar.com', password => 'silly'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Old confirmation not expired. Try later';
};

subtest 'deletes old confirmation' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    my $old_confirmation = TestDB->create('Confirmation', user_id => $user->id, type => 'register', created => 123);

    my $action = _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}),
    );

    $action->run;

    ok !$old_confirmation->load;
};

subtest 'creates new confirmation' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');

    my $action = _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}),
    );

    $action->run;

    my $confirmation = Threads::DB::Confirmation->find(first => 1);

    ok $confirmation;
    is $confirmation->user_id, $user->id;
    isnt $confirmation->token, '';
    is $confirmation->type,    'register';
};

subtest 'sends email' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');

    my $mailer = _mock_mailer();

    my $action = _build_action(
        req    => POST('/' => {email => 'foo@bar.com', password => 'silly'}),
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

subtest 'redirects to success' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');

    my $mailer = _mock_mailer();

    my $action = _build_action(
        req    => POST('/' => {email => 'foo@bar.com', password => 'silly'}),
        mailer => $mailer
    );

    my $res = $action->run;

    is $res->code, 302;
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
      Threads::Action::ResendRegistrationConfirmation->new(env => $env, services => $services);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });
    $action->mock(mailer => sub { $mailer });

    return $action;
}

done_testing;
