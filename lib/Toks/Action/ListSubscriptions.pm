package Toks::Action::ListSubscriptions;

use strict;
use warnings;

use parent 'Tu::Action';

sub run {
    my $self = shift;

    my $page = $self->req->param('page');
    $page = 1 unless $page && $page =~ m/^\d+$/;

    my $page_size = $self->service('config')->{pagers}->{subscriptions} || 10;

    $self->set_var(
        params => {
            page      => $page,
            page_size => $page_size
        }
    );

    return;
}

1;
