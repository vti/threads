use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::Action::AdminToggleBlocked;

subtest 'returns 404 when unknown user' => sub {
    TestDB->setup;

    my $action = _build_action(req => POST('/' => {}), captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when same user' => sub {
    TestDB->setup;

    my $user   = TestDB->create('User');
    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $user->id},
        'tu.user' => $user
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns 404 when user has unexpected status' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $blocked_user = TestDB->create(
        'User',
        name   => 'blocked',
        email  => 'blocked@bar.com',
        status => 'new'
    );
    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $blocked_user->id},
        'tu.user' => $user
    );

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'block user if not blocked' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $blocked_user = TestDB->create(
        'User',
        name   => 'blocked',
        email  => 'blocked@bar.com',
        status => 'active'
    );
    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $blocked_user->id},
        'tu.user' => $user
    );

    $action->run;

    $blocked_user->load;

    is $blocked_user->status, 'blocked';
};

subtest 'unblock user if blocked' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $blocked_user = TestDB->create(
        'User',
        name   => 'blocked',
        email  => 'blocked@bar.com',
        status => 'blocked'
    );
    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $blocked_user->id},
        'tu.user' => $user
    );

    $action->run;

    $blocked_user->load;

    is $blocked_user->status, 'active';
};

subtest 'redirects' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $blocked_user = TestDB->create(
        'User',
        name   => 'blocked',
        email  => 'blocked@bar.com',
        status => 'active'
    );
    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $blocked_user->id},
        'tu.user' => $user
    );

    $action->mock('redirect');

    $action->run;

    my ($name, $params) = $action->mocked_call_args('redirect');

    is $name, 'admin_list_users';
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::AdminToggleBlocked->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
