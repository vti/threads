use strict;
use warnings;
use utf8;

use Test::More;
use Test::MonkeyMock;
use TestDB;

use Toks::DB::Nonce;
use Toks::DB::User;

subtest 'return undef when no user_id in session' => sub {
    TestDB->setup;

    my $user = _build_user();

    ok !defined $user->load_auth;
};

subtest 'return undef when unknown nonce' => sub {
    TestDB->setup;

    my $user = _build_user();

    ok !defined $user->load_auth({id => 123});
};

subtest 'return undef when user not active' => sub {
    TestDB->setup;

    my $existing_user = Toks::DB::User->new(email => 'foo@bar.com')->create;

    my $nonce =
      Toks::DB::Nonce->new(user_id => $existing_user->get_column('id'))->create;

    my $user = _build_user();

    my $loaded_user =
      $user->load_auth({id => $nonce->get_column('id')});

    ok !$loaded_user;
};

subtest 'return user when found' => sub {
    TestDB->setup;

    my $existing_user =
      Toks::DB::User->new(email => 'foo@bar.com', status => 'active')->create;

    my $nonce =
      Toks::DB::Nonce->new(user_id => $existing_user->get_column('id'))->create;

    my $user = _build_user();

    my $loaded_user =
      $user->load_auth({id => $nonce->get_column('id')});

    ok $loaded_user;
    is $loaded_user->get_column('id'), $existing_user->get_column('id');
};

subtest 'deletes old nonce' => sub {
    TestDB->setup;

    my $existing_user =
      Toks::DB::User->new(email => 'foo@bar.com', status => 'active')->create;

    my $nonce =
      Toks::DB::Nonce->new(user_id => $existing_user->get_column('id'))->create;

    my $user = _build_user();

    my $options = {id => $nonce->get_column('id')};
    $user->load_auth($options);

    ok !$nonce->load;
};

subtest 'creates new nonce' => sub {
    TestDB->setup;

    my $existing_user =
      Toks::DB::User->new(email => 'foo@bar.com', status => 'active')->create;

    my $nonce =
      Toks::DB::Nonce->new(user_id => $existing_user->get_column('id'))->create;

    my $user = _build_user();

    my $options = {id => $nonce->get_column('id')};
    $user->load_auth($options);

    isnt $options->{id}, $nonce->get_column('id');
};

subtest 'hashes password' => sub {
    TestDB->setup;

    isnt(Toks::DB::User->new->hash_password('foo'), 'foo');
};

subtest 'hashes unicode password' => sub {
    TestDB->setup;

    isnt(Toks::DB::User->new->hash_password('привет'), 'привет');
};

sub _build_user {
    Toks::DB::User->new(@_);
}

done_testing;
