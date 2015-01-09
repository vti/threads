use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use Toks::Action::Logout;

subtest 'calls logout' => sub {
    my $auth = Test::MonkeyMock->new;
    $auth->mock(logout => sub { });

    my $env = TestRequest->to_env('tu.auth' => $auth);

    my $action = _build_action(env => $env);

    $action->run;

    ok $auth->mocked_called('logout');
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::Logout->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
