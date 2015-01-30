package Threads::Action::TranslateMixin;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(loc);

sub loc {
    my $self = shift;

    my $handle = $self->env->{'plack.i18n.handle'};
    return join ' ', @_ unless $handle;

    return $handle->loc(@_);
}

1;
