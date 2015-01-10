#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$RealBin';

BEGIN {
    unshift @INC, "$RealBin/../lib";
    unshift @INC, "$_/lib" for glob "$RealBin/../contrib/*";
}

use Getopt::Long;
use String::CamelCase qw(camelize);
use Tu::Config;
use Tu::Loader;
use Threads::DB;

my $verbose;
my $dry_run;
GetOptions('verbose' => \$verbose, 'dry-run' => \$dry_run)
  or die("Error in command line arguments\n");

my $config =
  Tu::Config->new(mode => 1)->load("$RealBin/../config/config.yml");
Threads::DB->init_db(%{$config->{database}});

my $loader = Tu::Loader->new;

foreach my $job_name (@ARGV) {
    my $job_class = 'Threads::Job::' . camelize($job_name);
    $loader->try_load_class($job_class) or die "Can't find job '$job_name'";

    $job_class->new(
        config  => $config,
        dry_run => $dry_run,
        verbose => $verbose
    )->run;
}
