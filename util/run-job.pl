#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$RealBin';

BEGIN {
    unshift @INC, "$RealBin/../lib";
    unshift @INC, "$_/lib" for glob "$RealBin/../contrib/*";
}

use Fcntl qw(:flock);
use Getopt::Long;
use String::CamelCase qw(camelize);
use Tu::Config;
use Tu::Loader;
use Threads::DB;

my $verbose;
my $dry_run;
my $lock;
GetOptions('verbose' => \$verbose, 'dry-run' => \$dry_run, 'lock' => \$lock)
  or die("Error in command line arguments\n");

my $config = Tu::Config->new(mode => 1)->load("$RealBin/../config/config.yml");
Threads::DB->init_db(%{$config->{database}});

my $loader = Tu::Loader->new;

foreach my $job_name (@ARGV) {
    my $job_class = 'Threads::Job::' . camelize($job_name);
    $loader->try_load_class($job_class) or die "Can't find job '$job_name'";

    my $locked_fh = $lock ? _lock_class($job_class) : undef;

    $job_class->new(
        config  => $config,
        dry_run => $dry_run,
        verbose => $verbose
    )->run;

    _unlock_fh($locked_fh) if $lock;
}

sub _lock_class {
    my ($job_class) = @_;

    my $job_file = (join '/', split /::/, $job_class) . '.pm';

    my $file = $INC{$job_file};
    open my $fh, '<', $file or die $!;
    flock $fh, LOCK_EX | LOCK_NB or die "Job already running";

    return $fh;
}

sub _unlock_fh {
    my ($fh) = @_;

    close $fh;
}
