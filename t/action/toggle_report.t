use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Reply;
use Threads::DB::Report;
use Threads::Action::ToggleReport;

subtest 'returns 404 when unknown reply' => sub {
    TestDB->setup;

    my $action = _build_action(req => POST('/' => {}), captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'not creates report when same user' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(user_id => $user->id, thread_id => 123)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    ok exception {$action->run};

    my $report = Threads::DB::Report->find(first => 1);

    ok !$report;
};

subtest 'creates report' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(user_id => 123, thread_id => 123)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    my $report = Threads::DB::Report->find(first => 1);

    ok $report;
    is $report->user_id,  $user->id;
    is $report->reply_id, $reply->id;
};

subtest 'updates reports count when created' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(user_id => 123, thread_id => 123)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    $reply->load;

    is $reply->reports_count, 1;
};

subtest 'deletes report when exists' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(user_id => 123, thread_id => 123)->create;

    Threads::DB::Report->new(user_id => $user->id, reply_id => $reply->id)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    my $report = Threads::DB::Report->find(first => 1);

    ok !$report;
};

subtest 'updates reports count when deleted' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(user_id => 123, thread_id => 123)->create;

    Threads::DB::Report->new(user_id => $user->id, reply_id => $reply->id)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    $reply->load;

    is $reply->reports_count, 0;
};

subtest 'returns current count and state' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(user_id => 123, thread_id => 123)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    my ($json) = $action->run;

    is_deeply $json, {count => 1, state => 1};
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::ToggleReport->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
