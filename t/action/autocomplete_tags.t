use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestRequest;
use TestDB;

use HTTP::Request::Common;
use Threads::DB::Thread;
use Threads::Action::AutocompleteTags;

subtest 'returns empty array when no tags' => sub {
    my $action = _build_action(req => GET('/'));

    my ($json) = $action->run;

    is_deeply $json, [];
};

subtest 'returns actions sorted by popularity' => sub {
    TestDB->setup;

    Threads::DB::Thread->new(
        user_id => 1,
        title   => 'foo',
        tags    => [{title => 'z-popular'}, {title => 'rare'}]
    )->create;
    Threads::DB::Thread->new(
        user_id => 1,
        title   => 'foo',
        tags    => [{title => 'z-popular'}]
    )->create;
    Threads::DB::Thread->new(
        user_id => 1,
        title   => 'foo',
        tags    => [{title => 'z-popular'}]
    )->create;
    Threads::DB::Thread->new(
        user_id => 1,
        title   => 'foo',
        tags    => [{title => 'rare'}]
    )->create;

    my $action = _build_action(req => GET('/?term=r'));

    my ($json) = $action->run;

    is_deeply $json, [qw/z-popular rare/];
};

subtest 'not includes zero tags' => sub {
    TestDB->setup;

    Threads::DB::Tag->new(title => 'zero')->create;

    Threads::DB::Thread->new(
        user_id => 1,
        title   => 'foo',
        tags    => [{title => 'foo'}, {title => 'bar'}]
    )->create;

    my $action = _build_action(req => GET('/?term=r'));

    my ($json) = $action->run;

    is_deeply $json, [qw/bar/];
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::AutocompleteTags->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
