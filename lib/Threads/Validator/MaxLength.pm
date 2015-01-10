package Threads::Validator::MaxLength;

use strict;
use warnings;

use parent 'Tu::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($value, $max_length) = @_;

    return 0 unless length $value <= $max_length;

    return 1;
}

1;
