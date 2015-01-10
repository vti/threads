package Toks::Action::Index;

use strict;
use warnings;

use parent 'Tu::Action';

use List::Util qw(first);
use Toks::DB::Thread;
use Toks::DB::User;

sub run {
    my $self = shift;

    my $by = $self->req->param('by');
    $by = 'activity' unless $by && first { $by eq $_ } qw/activity popularity/;

    my $user_id = $self->req->param('user_id');
    $user_id = 1 unless $user_id && $user_id =~ m/^\d+$/;

    $self->throw_not_found
      if $user_id && !Toks::DB::User->new(id => $user_id)->load;

    my $page = $self->req->param('page');
    $page = 1 unless $page && $page =~ m/^\d+$/;

    my $page_size = $self->service('config')->{pagers}->{threads} || 10;

    $self->set_var(
        params => {
            by        => $by,
            user_id   => $user_id,
            page      => $page,
            page_size => $page_size
        }
    );

    return;
}

1;
