use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use JSON qw(decode_json);
use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Reply;
use Threads::DB::Thank;
use Threads::Action::ThankReply;

subtest 'returns 404 when unknown reply' => sub {
    TestDB->setup;

    my $action = _build_action(req => POST('/' => {}), captures => {});

    my $res = $action->run;

    is $res->code, 404;
};

subtest 'creates thank log' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(thread_id => 1, user_id => 999)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    my $thank = Threads::DB::Thank->find(first => 1);

    ok $thank;
    is $thank->user_id,  $user->id;
    is $thank->reply_id, $reply->id;
};

subtest 'returns current count' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(thread_id => 1, user_id => 999)->create;
    for (67 .. 70) {
        Threads::DB::Thank->new(
            user_id  => $_,
            reply_id => $reply->id
        )->create;
    }

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    is decode_json($res->body)->{count}, 5;
};

subtest 'returns current true state' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(thread_id => 1, user_id => 999)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    is decode_json($res->body)->{state}, 1;
};

subtest 'returns current false state' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(thread_id => 1, user_id => 999)->create;
    Threads::DB::Thank->new(
        user_id  => $user->id,
        reply_id => $reply->id
    )->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    is decode_json($res->body)->{state}, 0;
};

subtest 'updates reply thank count' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Threads::DB::Reply->new(thread_id => 1, user_id => 999)->create;
    for (67 .. 70) {
        Threads::DB::Thank->new(
            user_id  => $_,
            reply_id => $reply->id
        )->create;
    }

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    $reply->load;

    is $reply->thanks_count, 5;
};

subtest 'toggles when exists' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply =
      Threads::DB::Reply->new(thread_id => 1, user_id => 33)
      ->create;
    Threads::DB::Thank->new(
        user_id  => $user->id,
        reply_id => $reply->id
    )->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    $action->run;

    $reply->load;

    is(Threads::DB::Thank->table->count, 0);
    is $reply->thanks_count, 0;
};

subtest 'not found when same user' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply =
      Threads::DB::Reply->new(thread_id => 1, user_id => $user->id)
      ->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->id},
        'tu.user' => $user
    );

    my $res = $action->run;

    is $res->code, 404;

    is(Threads::DB::Thank->table->count, 0);
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::ThankReply->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
