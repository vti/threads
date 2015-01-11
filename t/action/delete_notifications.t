use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Notification;
use Threads::Action::DeleteNotifications;

subtest 'deletes all notifications' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    Threads::DB::Notification->new(user_id => $user->id, reply_id => 1)->create;
    Threads::DB::Notification->new(user_id => 123, reply_id => 1)->create;

    my $action = _build_action(req => POST('/' => {}), captures => {}, 'tu.user' => $user);

    $action->run;

    is(Threads::DB::Notification->table->count, 1);
};

subtest 'returns redirect' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    Threads::DB::Notification->new(user_id => $user->id, reply_id => 1)->create;

    my $action = _build_action(req => POST('/' => {}), captures => {}, 'tu.user' => $user);

    my ($json) = $action->run;

    ok $json->{redirect};
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::DeleteNotifications->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
