package Threads::Validator::Tags;

use strict;
use warnings;

use parent 'Tu::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($value) = @_;

    return 0 unless $value =~ m/^[[:alnum:],-: ]+$/;

    my @tags = grep { $_ ne '' && /\w/ } split /,/, $value;

    return 0 unless @tags && @tags <= 10;

    return 1;
}

1;
