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

subtest 'sets captcha to session on get' => sub {
    TestDB->setup;

    my $action = _build_action();

    $action->run;

    my $env = $action->env;

    is $env->{'psgix.session'}->{captcha}, 2;
};

subtest 'set template var errors when no captcha' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST(
            '/' => {email => 'foo@bar.com', password => 'silly'}
        )
    );

    $action->run;

    $action->env;

    ok $action->vars->{errors}->{captcha};
};

subtest 'set template var errors when wrong captcha' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST(
            '/' => {email => 'foo@bar.com', password => 'silly', captcha => '3'}
        )
    );

    $action->run;

    $action->env;

    ok $action->vars->{errors}->{captcha};
};

subtest 'shows success when valid captcha' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST(
            '/' => {email => 'foo@bar.com', password => 'silly', captcha => '2'}
        )
    );

    ok !$action->vars->{errors};
};

sub _mock_services {
    my (%params) = @_;

    my $services = Test::MonkeyMock->new;
    $services->mock(
        service => sub { $params{config} || {
                captcha => [
                    {text => '1 + 1 = ?', answer => 2}
                ]
            } },
        when => sub { $_[1] eq 'config' }
    );

    return $services;
}

sub _mock_mailer {
    my $mailer = Test::MonkeyMock->new;
    $mailer->mock(send => sub { });

    return $mailer;
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
