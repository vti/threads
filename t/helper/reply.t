use strict;
use warnings;

use Test::More;
use TestLib;
use TestRequest;
use TestDB;

use Threads::DB::User;
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

    my $user = Threads::DB::User->new(email => 'foo@bar.com')->create;
    my $helper = _build_helper('tu.user' => $user);

    is $helper->is_thanked({id => 12, thanks_count => 1}), 0;
};

subtest 'returns true when thank found' => sub {
    TestDB->setup;

    my $user = Threads::DB::User->new(email => 'foo@bar.com')->create;
    Threads::DB::Thank->new(user_id => $user->id, reply_id => 12)->create;
    my $helper = _build_helper('tu.user' => $user);

    is $helper->is_thanked({id => 12, thanks_count => 1}), 1;
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
