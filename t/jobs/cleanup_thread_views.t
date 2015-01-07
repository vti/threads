use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;

use Toks::DB::View;
use Toks::Job::CleanupThreadViews;

subtest 'not delete todays views' => sub {
    TestDB->setup;

    _create_view();

    my $job = _build_job();
    $job->run;

    is(Toks::DB::View->table->count, 1);
};

subtest 'delete old views' => sub {
    TestDB->setup;

    _create_view(created => time - 7 * 24 * 3600);

    my $job = _build_job();
    $job->run;

    is(Toks::DB::View->table->count, 0);
};

subtest 'do not delete when dry-run' => sub {
    TestDB->setup;

    _create_view(created => time - 7 * 24 * 3600);

    my $job = _build_job(dry_run => 1);
    $job->run;

    is(Toks::DB::View->table->count, 1);
};

sub _create_view {
    Toks::DB::View->new(user_id => 1, thread_id => 1, @_)->create;
}

sub _build_job {
    my (%params) = @_;

    return Toks::Job::CleanupThreadViews->new(%params);
}

done_testing;
