package Toks::Action::TranslateMixin;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(loc);

sub loc {
    my $self = shift;

    my $handle = $self->env->{'tu.i18n.maketext'};
    return join ' ', @_ unless $handle;

    return $handle->loc(@_);
}

1;
