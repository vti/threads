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
        '+columns' =>
          [{-col => \'COUNT(map_thread_tag.tag_id)', -as => 'count'}],
        where    => [title    => {'like' => "%$q%"}],
        order_by => [\'count' => 'DESC'],
        group_by => 'id',
        with     => 'map_thread_tag',
        limit    => 10
    );

    return [map { $_->title } grep { $_->get_column('count') > 0 } @tags],
      type => 'json';
}

1;
