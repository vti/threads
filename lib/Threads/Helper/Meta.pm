package Threads::Helper::Meta;

use strict;
use warnings;

use parent 'Tu::Helper';

sub set {
    my $self = shift;
    my ($key, $value) = @_;

    $self->{meta}->{$key} = $value;

    return '';
}

sub get {
    my $self = shift;
    my ($key) = @_;

    return $self->{meta}->{$key};
}

1;
