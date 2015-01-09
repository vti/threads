use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Toks::DB::User;
use Toks::DB::Confirmation;
use Toks::DB::Notification;
use Toks::DB::Subscription;
use Toks::Action::ConfirmDeregistration;

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

    my $confirmation = Toks::DB::Confirmation->new(user_id => 123)->create;
    my $action =
      _build_action(captures => {token => $confirmation->get_column('token')});

    my $e = exception { $action->run };
    isa_ok($e, 'Tu::X::HTTP');
    is $e->code, '404';
};

subtest 'removes user' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com')->create;
    my $confirmation =
      Toks::DB::Confirmation->new(user_id => $user->get_column('id'))->create;
    my $action =
      _build_action(captures => {token => $confirmation->get_column('token')});

    $action->run;

    $user->load;

    is $user->get_column('email'),    $user->get_column('id');
    is $user->get_column('password'), '';
    is $user->get_column('name'),     '';
    is $user->get_column('status'),   'deleted';
};

subtest 'logouts user' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com')->create;
    my $confirmation =
      Toks::DB::Confirmation->new(user_id => $user->get_column('id'))->create;

    my $auth   = _mock_auth();
    my $action = _build_action(
        captures  => {token => $confirmation->get_column('token')},
        'tu.auth' => $auth
    );

    $action->run;

    $user->load;

    ok $auth->mocked_called('logout');
};

subtest 'deletes user notifications' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com')->create;
    my $confirmation =
      Toks::DB::Confirmation->new(user_id => $user->get_column('id'))->create;
    my $action =
      _build_action(captures => {token => $confirmation->get_column('token')});

    Toks::DB::Notification->new(user_id => 123, reply_id => 1)->create;
    Toks::DB::Notification->new(
        user_id  => $user->get_column('id'),
        reply_id => 1
    )->create;

    $action->run;

    is(Toks::DB::Notification->table->count, 1);
};

subtest 'deletes user subscriptions' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com')->create;
    my $confirmation =
      Toks::DB::Confirmation->new(user_id => $user->get_column('id'))->create;
    my $action =
      _build_action(captures => {token => $confirmation->get_column('token')});

    Toks::DB::Subscription->new(user_id => 123, thread_id => 1)->create;
    Toks::DB::Subscription->new(
        user_id   => $user->get_column('id'),
        thread_id => 1
    )->create;

    $action->run;

    is(Toks::DB::Subscription->table->count, 1);
};

subtest 'delete confirmation' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com')->create;
    my $confirmation =
      Toks::DB::Confirmation->new(user_id => $user->get_column('id'))->create;
    my $action =
      _build_action(captures => {token => $confirmation->get_column('token')});

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

    my $action = Toks::Action::ConfirmDeregistration->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });

    return $action;
}

done_testing;
