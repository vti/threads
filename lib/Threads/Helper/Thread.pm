package Threads::Helper::Thread;

use strict;
use warnings;

use parent 'Tu::Helper';

use List::Util qw(first);
use Threads::DB::Tag;
use Threads::DB::Thread;

sub is_author {
    my $self = shift;
    my ($thread, $user) = @_;

    return 1 if $user && $user->{id} == $thread->{user_id};

    return 0;
}

sub find {
    my $self = shift;

    my $q         = $self->param('q')         || '';
    my $by        = $self->param('by')        || '';
    my $tag       = $self->param('tag')       || '';
    my $page      = $self->param('page')      || 1;
    my $page_size = $self->param('page_size') || 10;

    my @sort_by;
    if ($by eq 'popularity') {
        @sort_by = (replies_count => 'DESC', views_count => 'DESC');
    }
    else {
        @sort_by = (last_activity => 'DESC');
    }

    my @threads = Threads::DB::Thread->find(
        where     => $self->_prepare_where,
        order_by  => [@sort_by],
        page      => $page,
        page_size => $page_size,
        with      => ['user', 'editor']
    );

    @threads = map { $_->to_hash } @threads;

    my @ids  = map { $_->{id} } @threads;
    my @tags = map { $_->to_hash }
      Threads::DB::Tag->find(where => ['map_thread_tag.thread_id' => \@ids]);

    foreach my $thread (@threads) {
        $thread->{tags} = [];

        foreach my $tag (@tags) {
            push @{$thread->{tags}}, $tag
              if first { $_->{thread_id} == $thread->{id} }
            @{$tag->{map_thread_tag}};
        }
    }

    return @threads;
}

sub count {
    my $self = shift;

    return Threads::DB::Thread->table->count(where => $self->_prepare_where);
}

sub similar {
    my $self = shift;
    my ($thread) = @_;

    my @tags =
      Threads::DB::Tag->find(
        where => ['map_thread_tag.thread_id' => $thread->{id}]);
    return () unless @tags;

    return map { $_->to_hash } Threads::DB::Thread->find(
        where => [
            id        => {'!=' => $thread->{id}},
            'tags.id' => [map  { $_->id } @tags]
        ],
        group_by => 'id',
        limit    => 5
    );
}

sub _prepare_where {
    my $self = shift;

    my @where;

    my $user_id = $self->param('user_id');
    push @where, user_id => $user_id if $user_id;

    my $tag = $self->param('tag');
    push @where, 'tags.title' => $tag if $tag;

    my $q = $self->param('q');
    push @where,
      -or => ['title' => {like => "%$q%"}, 'content' => {like => "%$q%"}]
      if $q;

    return \@where;
}

1;
