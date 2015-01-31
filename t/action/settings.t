use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::Action::Settings;

subtest 'update settings with checkbox' => sub {
    TestDB->setup;

    my $user   = TestDB->create('User');
    my $action = _build_action(
        req => POST(
            '/' => {email_notifications => 'on'}
        ),
        'tu.user' => $user
    );

    $action->run;

    $user->load;

    is $user->email_notifications, '1';
};

subtest 'redirects' => sub {
    TestDB->setup;

    my $user   = TestDB->create('User');
    my $action = _build_action(
        req => POST(
            '/' => {name => 'foo'}
        ),
        'tu.user' => $user
    );
    $action->mock('redirect');

    $action->run;

    my ($name) = $action->mocked_call_args('redirect');

    is $name, 'index';
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::Settings->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
