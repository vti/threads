package Toks::Action::Index;

use strict;
use warnings;

use parent 'Tu::Action';

use List::Util qw(first);
use Toks::DB::Thread;

sub run {
    my $self = shift;

    my $by = $self->req->param('by');
    $by = 'activity' unless $by && first { $by eq $_ } qw/activity popularity/;

    $self->set_var(params => {by => $by});

    return;
}

1;
