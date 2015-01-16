package Threads::Action::AutocompleteTags;

use strict;
use warnings;

use parent 'Threads::Action';

use Threads::DB::Tag;

sub run {
    my $self = shift;

    my $q = $self->req->param('term') || '';
    return $self->new_json_response(200, []) unless $q;

    my @tags = Threads::DB::Tag->find(
        '+columns' =>
          [{-col => \'COUNT(map_thread_tag.tag_id)', -as => 'count'}],
        where    => [title    => {'like' => "%$q%"}],
        order_by => [\'count' => 'DESC'],
        group_by => 'id',
        with     => 'map_thread_tag',
        limit    => 10
    );

    return $self->new_json_response(200,
        [map { $_->title } grep { $_->get_column('count') > 0 } @tags]);
}

1;
