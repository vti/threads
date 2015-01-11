use strict;
use warnings;
use utf8;

use Test::More;
use TestDB;

use Threads::ObjectACL;
use Threads::DB::User;
use Threads::DB::Thread;

subtest 'denies when not author' => sub {
    TestDB->setup;

    my $user   = TestDB->create('User');
    my $thread = TestDB->create('Thread', user_id => 123);
    my $acl    = _build_acl();

    ok !$acl->is_allowed($user, $thread, 'update_thread');
};

subtest 'allows when ok' => sub {
    TestDB->setup;

    my $user   = TestDB->create('User');
    my $thread = TestDB->create('Thread', user_id => $user->id);
    my $acl    = _build_acl();

    ok $acl->is_allowed($user, $thread, 'update_thread');
};

subtest 'denies when unknown action' => sub {
    TestDB->setup;

    my $user   = TestDB->create('User');
    my $thread = TestDB->create('Thread', user_id => $user->id);
    my $acl    = _build_acl();

    ok !$acl->is_allowed($user, $thread, 'unknown_action');
};

sub _build_acl { Threads::ObjectACL->new(@_) }

done_testing;
