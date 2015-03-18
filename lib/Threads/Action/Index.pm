package Threads::Action::Index;

use strict;
use warnings;

use parent 'Tu::Action';

use List::Util qw(first);
use Threads::DB::Thread;
use Threads::DB::User;
use Threads::DB::Tag;

sub run {
    my $self = shift;

    my $by = $self->req->param('by');
    $by = 'activity' unless $by && first { $by eq $_ } qw/activity popularity/;

    my $q = $self->req->param('q');

    my $user_id = $self->req->param('user_id');
    $user_id = undef unless $user_id && $user_id =~ m/^\d+$/;

    $self->throw_not_found
      if $user_id && !Threads::DB::User->new(id => $user_id)->load;

    my $tag = $self->req->param('tag');
    $self->throw_not_found
      if $tag && !Threads::DB::Tag->new(title => $tag)->load;

    my $page = $self->req->param('page');
    $page = 1 unless $page && $page =~ m/^\d+$/;

    my $page_size = $self->service('config')->{pagers}->{threads} || 10;

    $self->set_var(
        params => {
            q         => $q,
            by        => $by,
            tag       => $tag,
            user_id   => $user_id,
            page      => $page,
            page_size => $page_size
        }
    );

    return;
}

1;
