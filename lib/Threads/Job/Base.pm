package Threads::Job::Base;

use strict;
use warnings;

binmode STDOUT, ':utf8';

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{dry_run} = $params{dry_run};
    $self->{verbose} = $params{verbose};
    $self->{config}  = $params{config} || {};

    return $self;
}

sub run { ... }

sub _is_verbose { $_[0]->{verbose} || $_[0]->{dry_run} }
sub _is_dry_run { $_[0]->{dry_run} }

1;
