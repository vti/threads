package Toks::Helper::Config;

use strict;
use warnings;

use parent 'Tu::Helper';

sub config {
    my $self = shift;

    return $self->service('config');
}

1;
