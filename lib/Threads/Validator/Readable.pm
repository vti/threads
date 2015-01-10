package Threads::Validator::Readable;

use strict;
use warnings;

use parent 'Tu::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($value) = @_;

    $value =~ s/[^[:alnum:]]//g;

    return 1 if length $value >= 3;

    return 0;
}

1;
