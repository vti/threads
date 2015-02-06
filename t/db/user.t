use strict;
use warnings;
use utf8;

use Test::More;
use TestDB;

use Threads::DB::Nonce;
use Threads::DB::User;

subtest 'hashes password' => sub {
    TestDB->setup;

    isnt(Threads::DB::User->new->hash_password('foo', 'salt'), 'foo');
};

subtest 'hashes unicode password' => sub {
    TestDB->setup;

    isnt(Threads::DB::User->new->hash_password('привет', 'salt'), 'привет');
};

subtest 'hashes password on create' => sub {
    TestDB->setup;

    my $user = TestDB->create('User', password => 'bar');

    isnt $user->password, 'bar';
    isnt $user->salt, '';
};

subtest 'checks password' => sub {
    TestDB->setup;

    my $user = TestDB->create('User', password => 'bar');

    ok $user->check_password('bar');
    ok !$user->check_password('baz');
};

subtest 'updates password' => sub {
    TestDB->setup;

    my $user = TestDB->create('User', password => 'old');

    $user->update_password('new');

    ok !$user->check_password('old');
    ok $user->check_password('new');
};

subtest 'changes salt on update' => sub {
    TestDB->setup;

    my $user = TestDB->create('User', password => 'old');

    my $old_salt = $user->salt;
    $user->update_password('new');
    my $new_salt = $user->salt;

    isnt $old_salt, $new_salt;
};

sub _build_user {
    Threads::DB::User->new(@_);
}

done_testing;
