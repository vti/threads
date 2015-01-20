package Threads::Validator::Captcha;

use strict;
use warnings;

use parent 'Tu::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($value) = @_;

    my $expected = $self->{args}->[0];

    return defined $value && defined $expected && $value eq $expected ? 1 : 0;
}

1;
