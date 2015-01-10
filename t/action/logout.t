use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use Threads::DB::Nonce;
use Threads::Action::Logout;

subtest 'calls logout' => sub {
    TestDB->setup;

    my $nonce = Threads::DB::Nonce->new(user_id => 1)->create;

    my $auth = Test::MonkeyMock->new;
    $auth->mock(logout => sub { });
    $auth->mock(session => sub { { id => $nonce->get_column('id') } });

    my $env = TestRequest->to_env('tu.auth' => $auth);

    my $action = _build_action(env => $env);

    $action->run;

    ok $auth->mocked_called('logout');
};

subtest 'deletes nonce' => sub {
    TestDB->setup;

    my $nonce = Threads::DB::Nonce->new(user_id => 1)->create;

    my $auth = Test::MonkeyMock->new;
    $auth->mock(logout => sub { });
    $auth->mock(session => sub { { id => $nonce->get_column('id') } });

    my $env = TestRequest->to_env('tu.auth' => $auth);

    my $action = _build_action(env => $env);

    $action->run;

    ok !$nonce->load;
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::Logout->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
