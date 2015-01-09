package Toks::Action::Logout;

use strict;
use warnings;

use parent 'Tu::Action';

sub run {
    my $self = shift;

    $self->scope->auth->logout($self->env);

    return $self->redirect('index');
}

1;
