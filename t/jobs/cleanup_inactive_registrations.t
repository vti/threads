use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;

use Threads::DB::User;
use Threads::Job::CleanupInactiveRegistrations;

subtest 'not delete active registrations' => sub {
    TestDB->setup;

    _create_user(status => 'active');

    my $job = _build_job();
    $job->run;

    is(Threads::DB::User->table->count, 1);
};

subtest 'not delete new not active registrations' => sub {
    TestDB->setup;

    _create_user(status => 'new');

    my $job = _build_job();
    $job->run;

    is(Threads::DB::User->table->count, 1);
};

subtest 'delete old not active registrations' => sub {
    TestDB->setup;

    _create_user(status => 'new', created => time - 7 * 24 * 3600);

    my $job = _build_job();
    $job->run;

    is(Threads::DB::User->table->count, 0);
};

subtest 'do not delete when dry-run' => sub {
    TestDB->setup;

    _create_user(status => 'new', created => time - 7 * 24 * 3600);

    my $job = _build_job(dry_run => 1);
    $job->run;

    is(Threads::DB::User->table->count, 1);
};

sub _create_user { TestDB->create('User', email => int(rand(100)), @_) }

sub _build_job {
    my (%params) = @_;

    return Threads::Job::CleanupInactiveRegistrations->new(%params);
}

done_testing;
