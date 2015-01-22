use strict;
use warnings;

use Test::More;
use TestLib;
use TestRequest;
use TestDB;

use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Notification;
use Threads::Helper::Reply;

subtest 'returns false when no thank count' => sub {
    TestDB->setup;

    my $helper = _build_helper();

    is $helper->is_thanked({id => 12, thanks_count => 0}), 0;
};

subtest 'returns false when no user' => sub {
    TestDB->setup;

    my $helper = _build_helper();

    is $helper->is_thanked({id => 12, thanks_count => 1}), 0;
};

subtest 'returns false when user anonymous' => sub {
    TestDB->setup;

    my $helper = _build_helper('tu.user' => TestUser->new(role => 'anonymous'));

    is $helper->is_thanked({id => 12, thanks_count => 1}), 0;
};

subtest 'returns false when no thanks' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    my $helper = _build_helper('tu.user' => $user);

    is $helper->is_thanked({id => 12, thanks_count => 1}), 0;
};

subtest 'returns true when thank found' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');
    Threads::DB::Thank->new(user_id => $user->id, reply_id => 12)->create;
    my $helper = _build_helper('tu.user' => $user);

    is $helper->is_thanked({id => 12, thanks_count => 1}), 1;
};

subtest 'returns replies with undread flags' => sub {
    TestDB->setup;

    my $user = TestDB->create('User');

    my $thread = TestDB->create('Thread', user_id => 123);
    my $reply = $thread->create_related('replies', user_id => 123);
    my $notification = TestDB->create(
        'Notification',
        reply_id => $reply->id,
        user_id  => $user->id
    );

    my $helper = _build_helper('tu.user' => $user);

    my @replies = $helper->find_by_thread($thread->to_hash);

    is $replies[0]->{unread}, 1;
};

my $env;

sub _build_helper {
    my (%params) = @_;

    $env = $params{env} || TestRequest->to_env(%params);

    Threads::Helper::Reply->new(env => $env);
}

done_testing;

package TestUser;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{role} = $params{role};

    return $self;
}

sub id   { shift->{id} }
sub role { shift->{role} }

1;
