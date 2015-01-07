package Toks::Helper::Thread;

use strict;
use warnings;

use parent 'Tu::Helper';

use Toks::DB::Thread;

sub find {
    my $self = shift;

    my $by = $self->param('by') || '';

    my @sort_by;
    if ($by eq 'popularity') {
        @sort_by = (replies_count => 'DESC', views_count => 'DESC');
    }
    else {
        @sort_by = (last_activity => 'DESC');
    }

    my @threads = Toks::DB::Thread->find(
        order_by => [@sort_by],
        with     => 'user'
    );

    return map { $_->to_hash } @threads;
}

1;
