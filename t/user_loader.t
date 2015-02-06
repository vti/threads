use strict;
use warnings;
use utf8;

use Test::More;
use TestDB;

use Threads::DB::Nonce;
use Threads::DB::User;
use Threads::UserLoader;

subtest 'return undef when no user_id in session' => sub {
    TestDB->setup;

    my $loader = _build_user_loader();

    ok !defined $loader->load;
};

subtest 'return undef when unknown nonce' => sub {
    TestDB->setup;

    my $loader = _build_user_loader();

    ok !defined $loader->load({id => 123});
};

subtest 'return undef when user not active' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User');

    my $nonce = Threads::DB::Nonce->new(user_id => $existing_user->id)->create;

    my $loader = _build_user_loader();

    my $loaded_user = $loader->load({id => $nonce->id});

    ok !$loaded_user;
};

subtest 'return undef when not the latest nonce' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    my $nonce =
      Threads::DB::Nonce->new(user_id => $existing_user->id, created => 123)
      ->create;
    Threads::DB::Nonce->new(user_id => $existing_user->id)->create;

    my $loader = _build_user_loader();

    my $loaded_user = $loader->load({id => $nonce->id});

    ok !$loaded_user;
};

subtest 'allow old nonce for window time' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    my $nonce = Threads::DB::Nonce->new(user_id => $existing_user->id)->create;
    Threads::DB::Nonce->new(user_id => $existing_user->id)->create;

    my $loader = _build_user_loader();

    my $loaded_user = $loader->load({id => $nonce->id});

    ok $loaded_user;
};

subtest 'return user when found' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    my $nonce = Threads::DB::Nonce->new(user_id => $existing_user->id)->create;

    my $loader = _build_user_loader();

    my $loaded_user = $loader->load({id => $nonce->id});

    ok $loaded_user;
    is $loaded_user->id, $existing_user->id;
};

subtest 'deletes old nonces older then timeout' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    Threads::DB::Nonce->new(user_id => $existing_user->id, created => 123)
      ->create;
    my $nonce =
      Threads::DB::Nonce->new(user_id => $existing_user->id, created => 123)
      ->create;

    my $loader = _build_user_loader();

    my $options = {id => $nonce->id};
    $loader->finalize($options);

    is(Threads::DB::Nonce->table->count, 1);
};

subtest 'allows old nonce to exist for window time' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    Threads::DB::Nonce->new(user_id => $existing_user->id)->create;
    my $nonce = Threads::DB::Nonce->new(user_id => $existing_user->id)->create;

    my $loader = _build_user_loader();

    my $options = {id => $nonce->id};
    $loader->finalize($options);

    is(Threads::DB::Nonce->table->count, 2);
};

subtest 'creates new nonce' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    my $nonce =
      Threads::DB::Nonce->new(user_id => $existing_user->id, created => 123)
      ->create;

    my $loader = _build_user_loader();

    my $options = {id => $nonce->id};
    $loader->finalize($options);

    isnt $options->{id}, $nonce->id;
};

subtest 'not creates new nonce within timeout' => sub {
    TestDB->setup;

    my $existing_user = TestDB->create('User', status => 'active');

    my $nonce = Threads::DB::Nonce->new(user_id => $existing_user->id)->create;

    my $loader = _build_user_loader();

    my $options = {id => $nonce->id};
    $loader->finalize($options);

    is $options->{id}, $nonce->id;
};

sub _build_user_loader {
    Threads::UserLoader->new(@_);
}

done_testing;
