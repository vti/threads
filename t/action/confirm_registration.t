use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use Threads::DB::User;
use Threads::DB::Confirmation;
use Threads::Action::ConfirmRegistration;
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

    my $confirmation = Threads::DB::Confirmation->new(user_id => 123)->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->get_column('token')});

    my $e = exception { $action->run };
    isa_ok($e, 'Tu::X::HTTP');
    is $e->code, '404';
};

subtest 'return 404 when confirmation token too old' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->get_column('id'),
        created => 123,
        type    => 'register'
    )->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->get_column('token')});

    my $e = exception { $action->run };
    isa_ok($e, 'Tu::X::HTTP');
    is $e->code, '404';
};

subtest 'change user status' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->get_column('id'),
        type    => 'register'
    )->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->get_column('token')});

    $action->run;

    $user->load;

    is $user->get_column('status'), 'active';
};

subtest 'deletes confirmation' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->get_column('id'),
        type    => 'register'
    )->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->get_column('token')});

    $action->run;

    ok !$confirmation->load;
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::ConfirmRegistration->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });

    return $action;
}

done_testing;
