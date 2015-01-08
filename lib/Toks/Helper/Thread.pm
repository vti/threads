package Toks::Helper::Thread;

use strict;
use warnings;

use parent 'Tu::Helper';

use Toks::DB::Thread;

sub find {
    my $self = shift;

    my $by   = $self->param('by')   || '';
    my $page = $self->param('page') || 1;
    my $page_size = $self->param('page_size') || 10;

    my @sort_by;
    if ($by eq 'popularity') {
        @sort_by = (replies_count => 'DESC', views_count => 'DESC');
    }
    else {
        @sort_by = (last_activity => 'DESC');
    }

    my @threads = Toks::DB::Thread->find(
        order_by  => [@sort_by],
        page      => $page,
        page_size => $page_size,
        with      => 'user'
    );

    return map { $_->to_hash } @threads;
}

sub count {
    my $self = shift;

    return Toks::DB::Thread->table->count;
}

1;
