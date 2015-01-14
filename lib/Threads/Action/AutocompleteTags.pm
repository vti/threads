package Threads::Action::AutocompleteTags;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::DB::Tag;

sub run {
    my $self = shift;

    my $q = $self->req->param('term') || '';
    return [], type => 'json' unless $q;

    my @tags = Threads::DB::Tag->find(
        where    => [title => {'like' => "%$q%"}],
        order_by => [title => 'ASC']
    );

    return [map { $_->title } @tags], type => 'json';
}

1;
