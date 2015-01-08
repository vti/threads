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

    my $page = $self->req->param('page');
    $page = 1 unless $page && $page =~ m/^\d+$/;

    my $page_size = 10;

    $self->set_var(
        params => {
            by        => $by,
            page      => $page,
            page_size => $page_size
        }
    );

    return;
}

1;
