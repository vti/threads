use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use Toks::Action::Logout;

subtest 'expire session' => sub {
    my $env     = TestRequest->to_env;
    my $session = Plack::Session->new($env);
    $session->set(user_id => 1);

    my $action = _build_action(env => $env);

    $action->run;

    is_deeply $action->env->{'psgix.session'}, {};
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::Logout->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });

    return $action;
}

done_testing;
