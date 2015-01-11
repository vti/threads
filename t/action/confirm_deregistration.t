use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Confirmation;
use Threads::DB::Notification;
use Threads::DB::Subscription;
use Threads::Action::ConfirmDeregistration;
use Threads::Util qw(to_hex);

subtest 'return 404 when confirmation token not found' => sub {
    my $action = _build_action(captures => {});

    my $e = exception { $action->run };
    isa_ok($e, 'Tu::X::HTTP');
    is $e->code, '404';
};

subtest 'return 404 when confirmation not found' => sub {
    TestDB->setup;

    my $action = _build_action(captures => {token => '123'});

    my $e = exception { $action->run };
    isa_ok($e, 'Tu::X::HTTP');
    is $e->code, '404';
};

subtest 'return 404 when user not found' => sub {
    TestDB->setup;

    my $confirmation =
      Threads::DB::Confirmation->new(user_id => 123, type => 'deregister')
      ->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->token});

    my $e = exception { $action->run };
    isa_ok($e, 'Tu::X::HTTP');
    is $e->code, '404';
};

subtest 'return 404 when expired token' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        created => 123,
        type    => 'deregister'
    )->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->token});

    my $e = exception { $action->run };
    isa_ok($e, 'Tu::X::HTTP');
    is $e->code, '404';
};

subtest 'removes user' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'deregister'
    )->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->token});

    $action->run;

    $user->load;

    is $user->email,    $user->id;
    is $user->password, '';
    is $user->name,     '';
    is $user->status,   'deleted';
};

subtest 'logouts user' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'deregister'
    )->create;

    my $auth   = _mock_auth();
    my $action = _build_action(
        captures  => {token => to_hex $confirmation->token},
        'tu.auth' => $auth
    );

    $action->run;

    $user->load;

    ok $auth->mocked_called('logout');
};

subtest 'deletes user notifications' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'deregister'
    )->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->token});

    Threads::DB::Notification->new(user_id => 123, reply_id => 1)->create;
    Threads::DB::Notification->new(
        user_id  => $user->id,
        reply_id => 1
    )->create;

    $action->run;

    is(Threads::DB::Notification->table->count, 1);
};

subtest 'deletes user subscriptions' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'deregister'
    )->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->token});

    Threads::DB::Subscription->new(user_id => 123, thread_id => 1)->create;
    Threads::DB::Subscription->new(
        user_id   => $user->id,
        thread_id => 1
    )->create;

    $action->run;

    is(Threads::DB::Subscription->table->count, 1);
};

subtest 'delete confirmation' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'deregister'
    )->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->token});

    $action->run;

    ok !$confirmation->load;
};

sub _mock_auth {
    my $auth = Test::MonkeyMock->new;
    $auth->mock(logout => sub { });
    return $auth;
}

sub _build_action {
    my (%params) = @_;

    $params{'tu.auth'} ||= _mock_auth();

    my $env = TestRequest->to_env(%params);

    my $action = Threads::Action::ConfirmDeregistration->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });

    return $action;
}

done_testing;
