package Threads::Action::DeleteReply;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::ObjectACL;
use Threads::DB::User;
use Threads::DB::Reply;
use Threads::DB::Notification;

sub run {
    my $self = shift;

    my $reply_id = $self->captures->{id};

    return $self->throw_not_found
      unless my $reply = Threads::DB::Reply->new(id => $reply_id)->load;

    my $user = $self->scope->user;

    return $self->throw_not_found
      unless Threads::ObjectACL->new->is_allowed($user, $reply, 'delete_reply');

    my $thread = $reply->related('thread');

    Threads::DB::Notification->table->delete(
        where => [reply_id => $reply->get_column('id')]);

    $reply->delete;

    $thread->replies_count($thread->count_related('replies'));
    $thread->update;

    return $self->redirect(
        'view_thread',
        id   => $thread->get_column('id'),
        slug => $thread->get_column('slug')
    );
}

1;
