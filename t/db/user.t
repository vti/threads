use strict;
use warnings;
use utf8;

use Test::More;
use TestDB;

use Threads::DB::Nonce;
use Threads::DB::User;

subtest 'return undef when no user_id in session' => sub {
    TestDB->setup;

    my $user = TestDB->build('User');

    ok !defined $user->load_auth;
};

subtest 'return undef when unknown nonce' => sub {
    TestDB->setup;

    my $user = TestDB->build('User');

    ok !defined $user->load_auth({id => 123});
};

subtest 'return undef when user not active' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User');

    my $nonce =
      Threads::DB::Nonce->new(user_id => $existing_user->id)->create;

    my $user = TestDB->build('User');

    my $loaded_user =
      $user->load_auth({id => $nonce->id});

    ok !$loaded_user;
};

subtest 'return user when found' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    my $nonce =
      Threads::DB::Nonce->new(user_id => $existing_user->id)->create;

    my $user = TestDB->build('User');

    my $loaded_user =
      $user->load_auth({id => $nonce->id});

    ok $loaded_user;
    is $loaded_user->id, $existing_user->id;
};

subtest 'deletes old nonce' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    my $nonce =
      Threads::DB::Nonce->new(user_id => $existing_user->id, created => 123)
      ->create;

    my $user = TestDB->build('User');

    my $options = {id => $nonce->id};
    $user->finalize_auth($options);

    ok !$nonce->load;
};

subtest 'creates new nonce' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    my $nonce =
      Threads::DB::Nonce->new(user_id => $existing_user->id, created => 123)
      ->create;

    my $user = TestDB->build('User');

    my $options = {id => $nonce->id};
    $user->finalize_auth($options);

    isnt $options->{id}, $nonce->id;
};

subtest 'not creates new nonce within timeout' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    my $nonce =
      Threads::DB::Nonce->new(user_id => $existing_user->id)->create;

    my $user = TestDB->build('User');

    my $options = {id => $nonce->id};
    $user->finalize_auth($options);

    is $options->{id}, $nonce->id;
};

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
