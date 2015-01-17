use strict;
use warnings;

use Test::More;
use TestDB;

use Threads::DB::Confirmation;
use Threads::Util qw(to_hex);

subtest 'creates with token' => sub {
    TestDB->setup;

    my $confirmation = TestDB->create('Confirmation', user_id => 1);

    isnt $confirmation->token, '';
};

subtest 'finds fresh token' => sub {
    TestDB->setup;

    my $confirmation =
      TestDB->create('Confirmation', user_id => 1, type => 'register');

    ok $confirmation->find_fresh_by_token(to_hex $confirmation->token,
        'register');
};

subtest 'not finds old token' => sub {
    TestDB->setup;

    my $confirmation = TestDB->create(
        'Confirmation',
        user_id => 1,
        created => 123,
        type    => 'register'
    );

    ok !$confirmation->find_fresh_by_token($confirmation->token,
        'register');
};

subtest 'finds fresh token by user id' => sub {
    TestDB->setup;

    my $confirmation =
      TestDB->create('Confirmation', user_id => 1, type => 'register');

    ok $confirmation->find_fresh_by_user_id(1, 'register');
};

subtest 'checks if confirmation is expired' => sub {
    TestDB->setup;

    my $confirmation =
      TestDB->create('Confirmation', user_id => 1, type => 'register');

    $confirmation = $confirmation->find_by_token(to_hex $confirmation->token, 'register');

    ok !$confirmation->is_expired;
};

subtest 'not finds unknown token' => sub {
    TestDB->setup;

    ok !Threads::DB::Confirmation->find_fresh_by_token(123, 'type');
};

done_testing;
