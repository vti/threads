use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Toks::DB::User;
use Toks::DB::Thread;
use Toks::DB::Reply;
use Toks::DB::Thank;
use Toks::Action::ThankReply;

subtest 'returns 404 when unknown reply' => sub {
    TestDB->setup;

    my $action = _build_action(req => POST('/' => {}), captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'creates thank log' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Toks::DB::Reply->new(thread_id => 1, user_id => 999)->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    my $thank = Toks::DB::Thank->find(first => 1);

    ok $thank;
    is $thank->get_column('user_id'),  $user->get_column('id');
    is $thank->get_column('reply_id'), $reply->get_column('id');
};

subtest 'returns current count' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Toks::DB::Reply->new(thread_id => 1, user_id => 999)->create;
    for (67 .. 70) {
        Toks::DB::Thank->new(
            user_id  => $_,
            reply_id => $reply->get_column('id')
        )->create;
    }

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->get_column('id')},
        'tu.user' => $user
    );

    my ($json) = $action->run;

    is $json->{count}, 5;
};

subtest 'updates reply thank count' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply = Toks::DB::Reply->new(thread_id => 1, user_id => 999)->create;
    for (67 .. 70) {
        Toks::DB::Thank->new(
            user_id  => $_,
            reply_id => $reply->get_column('id')
        )->create;
    }

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    $reply->load;

    is $reply->get_column('thanks_count'), 5;
};

subtest 'toggles when exists' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply =
      Toks::DB::Reply->new(thread_id => 1, user_id => 33)
      ->create;
    Toks::DB::Thank->new(
        user_id  => $user->get_column('id'),
        reply_id => $reply->get_column('id')
    )->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    $reply->load;

    is(Toks::DB::Thank->table->count, 0);
    is $reply->get_column('thanks_count'), 0;
};

subtest 'not create when same user' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply =
      Toks::DB::Reply->new(thread_id => 1, user_id => $user->get_column('id'))
      ->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->get_column('id')},
        'tu.user' => $user
    );

    $action->run;

    is(Toks::DB::Thank->table->count, 0);
};

subtest 'returns count when exists' => sub {
    TestDB->setup;

    my $user =
      Toks::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;
    my $reply =
      Toks::DB::Reply->new(thread_id => 1, user_id => $user->get_column('id'))
      ->create;
    Toks::DB::Thank->new(
        user_id  => $user->get_column('id'),
        reply_id => $reply->get_column('id')
    )->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        captures  => {id      => $reply->get_column('id')},
        'tu.user' => $user
    );

    my ($json) = $action->run;

    ok $json->{count};
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::ThankReply->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
