use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;
use HTTP::Request::Common;

use Threads::DB::User;
use Threads::Action::ChangePassword;

subtest 'validation error when wrong old password' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'silly');

    my $action = _build_action(
        req => POST(
            '/' => {
                old_password              => 'foo',
                new_password              => 'bar',
                new_password_confirmation => 'bar',
            }
        ),
        'tu.user' => $user
    );

    $action->run;

    is_deeply $action->vars->{errors}, {old_password => 'Invalid password'};
};

subtest 'validation error when new passwords do not match' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    my $action = _build_action(
        req => POST(
            '/' => {
                old_password              => 'silly',
                new_password              => 'bar',
                new_password_confirmation => 'baz',
            }
        ),
        'tu.user' => $user
    );

    $action->run;

    is_deeply $action->vars->{errors}, {new_password => 'Password mismatch'};
};

subtest 'change user password' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    my $action = _build_action(
        req => POST(
            '/' => {
                old_password              => 'silly',
                new_password              => 'bar',
                new_password_confirmation => 'bar',
            }
        ),
        'tu.user' => $user
    );

    $action->run;

    $user->load;

    ok $user->check_password('bar');
};

sub _build_action {
    my (%params) = @_;

    my $env = TestRequest->to_env(%params);

    my $action = Threads::Action::ChangePassword->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });

    return $action;
}

done_testing;
