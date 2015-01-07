use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Toks::DB::User;
use Toks::DB::Notification;
use Toks::Action::DeleteNotifications;

subtest 'deletes all notifications' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    Toks::DB::Notification->new(user_id => $user->get_column('id'), reply_id => 1)->create;
    Toks::DB::Notification->new(user_id => 123, reply_id => 1)->create;

    my $action = _build_action(req => POST('/' => {}), captures => {}, 'tu.user' => $user);

    $action->run;

    is(Toks::DB::Notification->table->count, 1);
};

subtest 'returns redirect' => sub {
    TestDB->setup;

    my $user = Toks::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;
    Toks::DB::Notification->new(user_id => $user->get_column('id'), reply_id => 1)->create;

    my $action = _build_action(req => POST('/' => {}), captures => {}, 'tu.user' => $user);

    my ($json) = $action->run;

    ok $json->{redirect};
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::DeleteNotifications->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
