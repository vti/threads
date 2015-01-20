use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::Action::Register;
use Threads::Action::Register::FakeField;

subtest 'set template var errors when fake field submitted' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST(
            '/' =>
              {email => 'foo@bar.com', password => 'silly', website => '123'}
        )
    );

    $action->run;

    ok $action->vars->{errors}->{website};
};

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
    my $services = $params{services} || _mock_services();

    my $action =
      Threads::Action::Register->new(env => $env, services => $services);

    $action->observe(Threads::Action::Register::FakeField->new);

    return $action;
}

done_testing;
