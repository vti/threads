package Toks::Action::Logout;

use strict;
use warnings;

use parent 'Tu::Action';

use Plack::Session;

sub run {
    my $self = shift;

    my $session = Plack::Session->new($self->env);
    $session->expire;

    return $self->redirect('index');
}

1;
