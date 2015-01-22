package Threads::Action::ReadReply;

use strict;
use warnings;

use parent 'Threads::Action';

use Threads::DB::User;
use Threads::DB::Reply;

sub run {
    my $self = shift;

    my $reply_id = $self->captures->{id};
    return $self->new_json_response(404)
      unless my $reply = Threads::DB::Reply->new(id => $reply_id)->load;

    my $user = $self->scope->user;

    Threads::DB::Notification->table->delete(
        where => [user_id => $user->id, reply_id => $reply->id]);

    return $self->new_json_response(200, {});
}

1;
