use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;

use Threads::DB::View;
use Threads::Job::CleanupThreadViews;

subtest 'not delete todays views' => sub {
    TestDB->setup;

    _create_view();

    my $job = _build_job();
    $job->run;

    is(Threads::DB::View->table->count, 1);
};

subtest 'delete old views' => sub {
    TestDB->setup;

    _create_view(created => time - 7 * 24 * 3600);

    my $job = _build_job();
    $job->run;

    is(Threads::DB::View->table->count, 0);
};

subtest 'do not delete when dry-run' => sub {
    TestDB->setup;

    _create_view(created => time - 7 * 24 * 3600);

    my $job = _build_job(dry_run => 1);
    $job->run;

    is(Threads::DB::View->table->count, 1);
};

sub _create_view {
    Threads::DB::View->new(user_id => 1, thread_id => 1, @_)->create;
}

sub _build_job {
    my (%params) = @_;

    return Threads::Job::CleanupThreadViews->new(%params);
}

done_testing;
