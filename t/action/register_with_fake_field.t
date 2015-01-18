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

subtest 'set template var errors when fake field submitted' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST(
            '/' => {email => 'foo@bar.com', password => 'silly', website => '123'}
        )
    );

    $action->run;

    ok $action->vars->{errors}->{email};
};

sub _mock_services {
    my (%params) = @_;

    my $services = Test::MonkeyMock->new;
    $services->mock(
        service => sub { {} },
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
