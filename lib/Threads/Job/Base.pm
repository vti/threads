package Threads::Job::Base;

use strict;
use warnings;
use attrs 'dry_run', 'verbose', 'config' => sub { {} };

binmode STDOUT, ':utf8';

sub run { ... }

sub _config     { $_[0]->{config} }
sub _is_verbose { $_[0]->{verbose} || $_[0]->{dry_run} }
sub _is_dry_run { $_[0]->{dry_run} }

1;
