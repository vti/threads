package Threads::Action::ReadReply;

use strict;
use warnings;

use parent 'Threads::Action';

use Threads::DB::Reply;
use Threads::DB::Notification;

sub run {
    my $self = shift;

    my $reply_id = $self->captures->{id};

    return $self->new_json_response(404)
      unless my $reply = Threads::DB::Reply->new(id => $reply_id)->load;

    my $user = $self->scope->user;

    Threads::DB::Notification->table->delete(
        where => [user_id => $user->id, reply_id => $reply->id]);

    my $unread_count =
      Threads::DB::Notification->table->count(where => [user_id => $user->id]);

    return $self->new_json_response(200, {count => $unread_count});
}

1;
