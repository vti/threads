package Toks::Validator::MinLength;

use strict;
use warnings;

use parent 'Tu::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($value, $min_length) = @_;

    return 0 unless length $value >= $min_length;

    return 1;
}

1;
