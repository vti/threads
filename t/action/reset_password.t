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
use Threads::Action::ResetPassword;
use Threads::Util qw(to_hex);

subtest 'return 404 when no confirmation token' => sub {
    TestDB->setup;

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
      Threads::DB::Confirmation->new(user_id => 123, type => 'reset_password')
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
        type    => 'reset_password'
    )->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->token});

    my $e = exception { $action->run };
    isa_ok($e, 'Tu::X::HTTP');
    is $e->code, '404';
};

subtest 'show reset password page' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'reset_password'
    )->create;
    my $action =
      _build_action(
        captures => {token => to_hex $confirmation->token});

    ok !$action->run;
};

subtest 'show validation errors' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'reset_password'
    )->create;
    my $action = _build_action(
        captures => {token   => to_hex $confirmation->token},
        req      => POST('/' => {})
    );

    $action->run;

    my $env = $action->env;
    ok $env->{'tu.displayer.vars'}->{errors};
};

subtest 'show validation errors when password do not match' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'reset_password'
    )->create;
    my $action = _build_action(
        captures => {token => to_hex $confirmation->token},
        req      => POST(
            '/' => {
                new_password              => 'foo',
                new_password_confirmation => 'bar'
            }
        )
    );

    $action->run;

    my $env = $action->env;
    is_deeply $env->{'tu.displayer.vars'}->{errors},
      {new_password => 'Password mismatch'};
};

subtest 'change user password' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'reset_password'
    )->create;
    my $action = _build_action(
        captures => {token => to_hex $confirmation->token},
        req      => POST(
            '/' => {new_password => 'foo', new_password_confirmation => 'foo'}
        )
    );

    $action->run;

    $user->load;

    ok $user->check_password('foo');
};

subtest 'deletes confirmation' => sub {
    TestDB->setup;

    my $user         = TestDB->create('User');
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'reset_password'
    )->create;
    my $action = _build_action(
        captures => {token => to_hex $confirmation->token},
        req      => POST(
            '/' => {new_password => 'foo', new_password_confirmation => 'foo'}
        )
    );

    $action->run;

    ok !$confirmation->load;
};

subtest 'deletes other confirmations' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'reset_password'
    )->create;
    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'reset_password'
    )->create;
    my $action = _build_action(
        captures => {token => to_hex $confirmation->token},
        req      => POST(
            '/' => {new_password => 'foo', new_password_confirmation => 'foo'}
        )
    );

    $action->run;

    is(Threads::DB::Confirmation->table->count, 0);
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::ResetPassword->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });

    return $action;
}

done_testing;
