package Toks::Action::DeleteReply;

use strict;
use warnings;

use parent 'Tu::Action';

use Toks::DB::User;
use Toks::DB::Reply;

sub run {
    my $self = shift;

    my $reply_id = $self->captures->{id};

    return $self->throw_not_found
      unless my $reply = Toks::DB::Reply->new(id => $reply_id)->load;

    my $user = $self->scope->user;

    return $self->throw_not_found
      unless $user->get_column('id') == $reply->get_column('user_id');

    return $self->throw_not_found
      if $reply->count_related('ansestors');

    my $thread = $reply->related('thread');

    $reply->delete;

    $thread->set_column(
        replies_count => $thread->count_related('replies'));
    $thread->update;

    return $self->redirect('view_thread', id => $thread->get_column('id'));
}

1;
