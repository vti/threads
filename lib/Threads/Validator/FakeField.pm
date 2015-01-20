package Threads::Validator::FakeField;

use strict;
use warnings;

use parent 'Tu::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($value) = @_;

    return 0 if defined $value && length $value;

    return 1;
}

1;
