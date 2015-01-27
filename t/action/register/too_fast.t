use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::Action::Register;
use Threads::Action::Register::TooFast;

subtest 'set template var errors when no session' => sub {
    TestDB->setup;

    local $ENV{PLACK_ENV} = 'production';

    my $action = _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}));

    $action->run;

    is $action->vars->{errors}->{email}, 'Too fast';
};

subtest 'set template error when submitting too fast' => sub {
    TestDB->setup;

    local $ENV{PLACK_ENV} = 'production';

    my $action = _build_action(req => GET('/'));

    $action->run;

    my $session = $action->env->{'psgix.session'};

    ok $session->{too_fast};

    $action = _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}),
        'psgix.session' => $session
    );

    $action->run;

    is $action->vars->{errors}->{email}, 'Too fast';
};

subtest 'no errors when slow submitter' => sub {
    TestDB->setup;

    local $ENV{PLACK_ENV} = 'production';

    my $action = _build_action(req => GET('/'));

    $action->run;

    my $session = $action->env->{'psgix.session'};

    ok $session->{too_fast};

    $session->{too_fast} -= 5;

    $action = _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'silly'}),
        'psgix.session' => $session
    );

    $action->run;

    ok !$action->vars->{errors};
};

sub _mock_services {
    my (%params) = @_;

    my $services = Test::MonkeyMock->new;
    $services->mock(
        service => sub { {} },
        when    => sub { $_[1] eq 'config' }
    );

    my $mailer = Test::MonkeyMock->new;
    $mailer->mock(send => sub { });
    $services->mock(
        service => sub { $mailer },
        when    => sub { $_[1] eq 'mailer' }
    );

    return $services;
}

sub _build_action {
    my (%params) = @_;

    my $env      = $params{env}      || TestRequest->to_env(%params);
    my $services = $params{services} || _mock_services();

    my $action =
      Threads::Action::Register->new(env => $env, services => $services);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { });

    $action->observe(Threads::Action::Register::TooFast->new);

    return $action;
}

done_testing;
